import SwiftUI
import Charts

internal enum Frequency : Int, CaseIterable {
    case daily = 365, monthly = 12, yearly = 1
}

struct SimpleCompoundInterest: View {
    @State var principal: Double = 0
    @State var contributions: Double = 0
    @State var years: Double = 0
    @State var annualRate: Double = 0
    @State var result: String = "£0.00"
    @State var selectedFrequency: Frequency = Frequency.yearly
    @State var points: [Point] = [Point(x:1, y:2)]
    
    var body: some View {
        ScrollView {
            Spacer()
            
            GrowthChart(points: $points)
            
            let resultText = Text("\(result)")
                .foregroundColor(Color(.primary))
                .bold()
            
            VStack(spacing: 20) {
                Text("You would have \(resultText)")
                
                VStack(spacing: 30) {
                    FrequencyPicker(selectedFrequency: $selectedFrequency)
                    
                    AmountInputView(amount: $principal, label: "How much do you have now?")
                    
                    AmountInputView(amount: $contributions, label: "How much will you save each month?")
                                    
                    AmountInputView(amount: $years, label: "How long will you save for?")
                    
                    AmountInputView(amount: $annualRate, label: "Interest Rate")
                    
                    Button("Calculate") {
                        let localResult = compoundInterest2(
                            principal: principal,
                            annualRate: annualRate,
                            years: years,
                            timesCompounded: selectedFrequency.rawValue,
                            contribution: contributions
                        )
                        
                        let formattedResult = localResult.formatted(.number.precision(.fractionLength(2)))
                        
                        result = "£\(formattedResult)"
                        
                        points = [Point(x:0, y:0), Point(x:Int(years), y:Int(localResult))]
                        
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .bold()
                    .background(Color(.primary))
                    .clipShape(Capsule())
                    .foregroundStyle(.white)
                }
                
            }
        }.navigationTitle("Regular Saving")
            .padding(.all)
        
    }
}

struct FrequencyPicker: View {
    @Binding var selectedFrequency: Frequency
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Compounding rate")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(white: 0.2))
            
            Picker("Please choose a color", selection: $selectedFrequency) {
                ForEach(Frequency.allCases, id: \.self) {
                    let i = switch $0 {
                    case .daily: "Daily"
                    case .monthly: "Monthly"
                        case .yearly: "Yearly"
                    }
                    
                    Text("\(i)")
                        .foregroundStyle(.green)
                }
            }.pickerStyle(.segmented)
        }
    }
}

func compoundInterest(principal: Double, annualRate: Double, years: Double, timesCompounded: Int) -> Double {
    let r_n = (annualRate / 100) / Double(timesCompounded)
    let n_t = Double(timesCompounded) * years
    
    return principal * pow(1 + r_n, n_t)
}

/// Calculates the future value of an investment with monthly contributions and compound interest.
///
/// This function uses the formula:
/// $FV = P(1 + r/n)^{nt} + PMT \times \frac{(1 + r/n)^{nt} - 1}{r/n}$
///
/// - Parameters:
///   - principal: The starting balance or initial deposit ($P$).
///   - monthlyContribution: The amount added at the end of every month ($PMT$).
///   - annualRate: The yearly interest rate as a decimal (e.g., 0.05 for 5%).
///   - years: The duration of the investment in years ($t$).
/// - Returns: The total future value ($FV$) rounded to two decimal places.
func compoundInterest2(principal: Double, annualRate: Double, years: Double, timesCompounded: Int, contribution: Double) -> Double {
    let r_n = (annualRate / 100) / Double(timesCompounded)
    let n_t = Double(timesCompounded) * years
    let initialDeposit = principal * pow(1 + r_n, n_t)
    let monthlyContributions = (contribution * ((pow(1 + r_n, n_t) - 1)) / r_n)
    
    print("\(initialDeposit)")
    print("\(monthlyContributions)")
    
    return initialDeposit + monthlyContributions
    
}
