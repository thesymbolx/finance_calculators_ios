import SwiftUI
import Charts


struct RegularSavingView: View {
    @State var principal: Double = 0
    @State var monthlyDeposit: Double = 0
    @State var years: Double = 0
    @State var annualRate: Double = 0
    @State var result: Double = 0.0
    
    var tally: Int = 0
    
    
    var body: some View {
        ScrollView {
            Spacer()
            
            MyChart()
            
            
            VStack(spacing: 10) {
                Text("You would have \(Text("\(result)").foregroundColor(.green))")
                
                AmountInputView(amount: $principal, label: "How much do you have now?")
                
                AmountInputView(amount: $monthlyDeposit, label: "How much will you save each month?")
                
                AmountInputView(amount: $years, label: "How long will you save for?")
                
                AmountInputView(amount: $annualRate, label: "Interest Rate")
                
                Button("Calculate") {
                        result = calculate(
                            principal: principal,
                            monthlyDeposit: monthlyDeposit,
                            annualRate: annualRate,
                            years: years
                        )
            
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.green)
                .clipShape(Capsule())
                .foregroundStyle(.white)
                
                
            }
        }.navigationTitle("Regular Saving")
            .padding(.all)
        
    }

    
    func calculate(principal: Double, monthlyDeposit: Double, annualRate: Double, years: Double) -> Double {
        print("\(principal), \(monthlyDeposit), \(annualRate), \(years)")
        
        let n: Double = 12 // Compounding frequency (monthly)
        let r_n = annualRate / n // Periodic interest rate
        let nt = n * years // Total number of periods
        
        // 1. Growth of the initial principal: P(1 + r/n)^(nt)
        let principalGrowth = principal * pow(1 + r_n, nt)
        
        // 2. Growth of the monthly deposits: PMT * [((1 + r/n)^(nt) - 1) / (r/n)]
        let depositGrowth = monthlyDeposit * ((pow(1 + r_n, nt) - 1) / r_n)
        
        print(principalGrowth)
        
        return principalGrowth + depositGrowth
    }
    
    struct MyChart: View {
        // 1. Create a simple data model
        struct Point: Identifiable {
            let id = UUID()
            let x: Int
            let y: Int
        }
        
        // 2. Do all your math here, outside the body
        var calculatedData: [Point] {
            var tally = 0
            return (1...10).map { i in
                tally += Int.random(in: 0..<6)
                return Point(x: i, y: i + tally)
            }
        }
        
        var body: some View {
            Chart {
                // 3. The body only handles "Display"
                ForEach(calculatedData) { point in
                    LineMark(
                        x: .value("X", point.x),
                        y: .value("Y", point.y)
                    ).foregroundStyle(.green)
                }
            }.frame(height: 300)
        }
    }
    
}
