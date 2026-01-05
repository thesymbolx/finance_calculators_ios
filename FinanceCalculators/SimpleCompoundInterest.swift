import SwiftUI
import Charts


struct SimpleCompoundInterest: View {
    @State var principal: Double = 0
    @State var years: Double = 0
    @State var annualRate: Double = 0
    @State var result: String = "£0.00"
    
    var body: some View {
        ScrollView {
            Spacer()
            
            GrowthChart()
            
            VStack(spacing: 10) {
                Text("You would have \(Text("\(result)").foregroundColor(Color(.primary)))")
                
                AmountInputView(amount: $principal, label: "How much do you have now?")
                                
                AmountInputView(amount: $years, label: "How long will you save for?")
                
                AmountInputView(amount: $annualRate, label: "Interest Rate")
                
                Button("Calculate") {
                    let formattedResult = compoundInterest(
                        principal: principal,
                        annualRate: annualRate,
                        years: years,
                        timesCompounded: 1
                    ).formatted(.number.precision(.fractionLength(2)))
                    
                    
                    result = "£\(formattedResult)"
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.primary))
                .clipShape(Capsule())
                .foregroundStyle(.white)
                
                
            }
        }.navigationTitle("Regular Saving")
            .padding(.all)
        
    }
}

/**
            
 */
func compoundInterest(principal: Double, annualRate: Double, years: Double, timesCompounded: Int) -> Double {
    let r_n = (annualRate / 100) / Double(timesCompounded)
    let n_t = Double(timesCompounded) * years
    
    return principal * pow(1 + r_n, n_t)
}
