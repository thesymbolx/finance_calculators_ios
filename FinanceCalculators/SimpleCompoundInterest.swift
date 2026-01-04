import SwiftUI
import Charts


struct SimpleCompoundInterest: View {
    @State var principal: Double = 0
    @State var years: Double = 0
    @State var annualRate: Double = 0
    @State var result: Double = 0.0
    
    var body: some View {
        ScrollView {
            Spacer()
            
            MyChart()
            
            
            VStack(spacing: 10) {
                Text("You would have \(Text("\(result)").foregroundColor(.green))")
                
                AmountInputView(amount: $principal, label: "How much do you have now?")
                                
                AmountInputView(amount: $years, label: "How long will you save for?")
                
                AmountInputView(amount: $annualRate, label: "Interest Rate")
                
                Button("Calculate") {
                        result = compoundInterest(
                            principal: principal,
                            annualRate: annualRate,
                            years: years,
                            noTimeCompounded: 1
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

/**
            
 */
func compoundInterest(principal: Double, annualRate: Double, years: Double, noTimeCompounded: Int) -> Double {
    let annualRate = annualRate / 100
    let years_noTimeCompounded = years * Double(noTimeCompounded)
    
    return principal * pow(1 + annualRate, years_noTimeCompounded)
}
