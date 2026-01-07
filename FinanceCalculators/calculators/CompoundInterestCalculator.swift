import Charts
import SwiftUI

internal enum Frequency: Int, CaseIterable {
    case daily = 365
    case monthly = 12
    case yearly = 1
}

struct CompoundInterestCalculator: View {
    @State var principal: Decimal = 0
    @State var monthlyContribution: Decimal = 0
    @State var noYears: Int = 0
    @State var annualInterest: Decimal = 0
    @State var result: String = "£0.00"
    @State var selectedFrequency: Frequency = Frequency.yearly
    @State var points: [Point] = [Point(x: 1, y: 2)]

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

                    AmountInputView(
                        amount: $principal,
                        label: "How much do you have now?",
                        prependSymbol: "£"
                    )

                    AmountInputView(
                        amount: $monthlyContribution,
                        label: "How much will you save each month?",
                        prependSymbol: "£"
                    )

                    AmountInputView(
                        amount: $annualInterest,
                        label: "Interest Rate",
                        prependSymbol: "£"
                    )
                    
                    NumberInputView(
                        amount: $noYears,
                        label: "How long will you save for?"
                    )

                    Button("Calculate") {
                        let localResult = compoundInterestWithContribution2(
                            principal: principal,
                            annualInterest: annualInterest,
                            noYears: noYears,
                            compoundFrequency: selectedFrequency.rawValue,
                            monthlyContribution: monthlyContribution
                        )

                        let formattedResult = localResult.formatted(
                            .number.precision(.fractionLength(2))
                        )

                        result = "£\(formattedResult)"

                        points = [
                            Point(x: 0, y: 0),
                            Point(
                                x: Double(noYears),
                                y: NSDecimalNumber(decimal: localResult)
                                    .doubleValue
                            ),
                        ]

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
                    let i =
                        switch $0 {
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

/// Calculates the future value of an investment.
///
/// **Formula**
/// `FV = P(1 + r/n)^(nt) + PMT * ((1 + r/n)^(nt) - 1) / (r/n)`
///
/// - Parameters:
///   - principal: Initial deposit (P)
///   - annualInterest: Annual interest rate (e.g. 5.5 for 5.5%) (r)
///   - noYears: Duration in years (t)
///   - compoundFrequency: Number of compounding periods per year (n)
///   - monthlyContribution: Monthly contribution (PMT)
///
/// - Returns: Future value rounded to two decimal places.
func compoundInterestWithContribution(
    principal: Decimal,
    annualInterest: Decimal,
    noYears: Int,
    compoundFrequency: Int,
    monthlyContribution: Decimal
) -> Decimal {
    let annualInterest = annualInterest / 100
    let periodicRate = annualInterest / Decimal(compoundFrequency)
    let totalPeriods = compoundFrequency * noYears
    let growthFactor = pow(1 + periodicRate, totalPeriods)

    //Compound Interest on Principal: P(1 + r/n)^{nt}
    let principalGrowth = principal * growthFactor

    //Compound Interest on contributions: P(1 + r/n)^{nt}
    let contributionGrowth =
        monthlyContribution * ((growthFactor - 1) / periodicRate)

    print("\(principalGrowth)")
    print("\(contributionGrowth)")

    return principalGrowth + contributionGrowth

}

func compoundInterestWithContribution2(
    principal: Decimal,
    annualInterest: Decimal,
    noYears: Int,
    compoundFrequency: Int,
    monthlyContribution: Decimal
) -> Decimal {
    let principal = Double(truncating: principal as NSNumber)
    let annualInterest = Double(truncating: annualInterest as NSNumber) / 100.0
    let compoundFrequency = Double(compoundFrequency)
    let noYears = Double(noYears)
    let monthlyContribution = Double(truncating: monthlyContribution as NSNumber)
    
    

    let periodicRate = annualInterest / compoundFrequency
    let totalPeriods = compoundFrequency * noYears
    let growthFactor = pow(1 + periodicRate, totalPeriods)

    //Compound Interest on Principal: P(1 + r/n)^{nt}
    let principalGrowth = principal * growthFactor

    //Compound Interest on contributions: P(1 + r/n)^{nt}
    
    
    let numerator = pow(1 + annualInterest / compoundFrequency, compoundFrequency * noYears) - 1
    let demoninator = pow(1 + periodicRate, compoundFrequency / 12) - 1
        
    let contributionGrowth =
        monthlyContribution * (numerator / demoninator)


    return Decimal(principalGrowth + contributionGrowth)

}



func compoundInterestWithContribution3(
    principal: Decimal,
    annualInterest: Decimal,
    noYears: Int,
    compoundFrequency: Int,
    monthlyContribution: Decimal
) -> Decimal {
    
    // Convert to Double for power calculations
    let r = Double(truncating: annualInterest as NSNumber) / 100.0
    let n = Double(compoundFrequency)
    let t = Double(noYears)
    let pmt = Double(truncating: monthlyContribution as NSNumber)
    let p = Double(truncating: principal as NSNumber)
    
    // 1. Calculate the standard Base Growth Factor: (1 + r/n)
    let baseFactor = 1.0 + (r / n)
    
    // 2. Principal Growth: P * (BaseFactor)^(n*t)
    let principalGrowth = p * pow(baseFactor, n * t)
    
    // 3. Contribution Growth:
    // Numerator: (BaseFactor)^(n*t) - 1
    // Denominator: (BaseFactor)^(n/12) - 1  <-- This adjusts for the monthly payments
    let numerator = pow(baseFactor, n * t) - 1.0
    let denominator = pow(baseFactor, n / 12.0) - 1.0
    
    let contributionGrowth = pmt * (numerator / denominator)
    
    return Decimal(principalGrowth + contributionGrowth)
}



func fuck(
    principal: Decimal,
    annualInterest: Decimal,
    noYears: Int,
    compoundFrequency: Int,
    monthlyContribution: Decimal
) -> Decimal {
    let principal = Double(truncating: principal as NSNumber)
    let r = Double(truncating: annualInterest as NSNumber) / 100.0
    let n = Double(compoundFrequency)
    let t = Double(noYears)
    let monthlyContribution = Double(truncating: monthlyContribution as NSNumber)
    
    

    let periodicRate = r / n
    let totalPeriods = n * t
    let growthFactor = pow(1 + periodicRate, totalPeriods)

    //Compound Interest on Principal: P(1 + r/n)^{nt}
    let principalGrowth = principal * growthFactor

    //Compound Interest on contributions: P(1 + r/n)^{nt}
    
    
    let numerator = pow(1 + (r / n), n * t)
    let demoninator = pow(1 + (r / n), n / 12)
    let contributionGrowth = monthlyContribution * (numerator / demoninator)


    return Decimal(principalGrowth + contributionGrowth)

}



func you(
    principal: Decimal,
    annualInterest: Decimal,
    noYears: Int,
    compoundFrequency: Int,
    monthlyContribution: Decimal
) -> Decimal {
    
    // Convert to Double for power calculations
    let r = Double(truncating: annualInterest as NSNumber) / 100.0
    let n = Double(compoundFrequency)
    let t = Double(noYears)
    let pmt = Double(truncating: monthlyContribution as NSNumber)
    let p = Double(truncating: principal as NSNumber)
    
    // 1. Calculate the standard Base Growth Factor: (1 + r/n)
    let baseFactor = 1.0 + (r / n)
    
    // 2. Principal Growth: P * (BaseFactor)^(n*t)
    let principalGrowth = p * pow(baseFactor, n * t)
    
    // 3. Contribution Growth:
    // Numerator: (BaseFactor)^(n*t) - 1
    // Denominator: (BaseFactor)^(n/12) - 1  <-- This adjusts for the monthly payments
    let numerator = pow(1.0 + (r / n), n * t) - 1.0
    let denominator = pow(1.0 + (r / n), n / 12.0) - 1.0
    
    let contributionGrowth = pmt * (numerator / denominator)
    
    return Decimal(principalGrowth + contributionGrowth)
}
