import SwiftUI
import Charts

internal enum Frequency : Int, CaseIterable {
    case daily = 365, monthly = 12, yearly = 1
}

struct SimpleCompoundInterest: View {
    @State var principal: Double = 0
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
                                    
                    AmountInputView(amount: $years, label: "How long will you save for?")
                    
                    AmountInputView(amount: $annualRate, label: "Interest Rate")
                    
                    Button("Calculate") {
                        let localResult = compoundInterest(
                            principal: principal,
                            annualRate: annualRate,
                            years: years,
                            timesCompounded: selectedFrequency.rawValue
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
