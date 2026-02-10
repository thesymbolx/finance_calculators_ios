import Charts
import SwiftUI

fileprivate enum Frequency: Int, CaseIterable {
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
    @State fileprivate var selectedFrequency: Frequency = Frequency.yearly

    var body: some View {
        ScrollView {
            Spacer()

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
                        prependSymbol: "£",
                        onChanged: { _, _ in }
                    )

                    AmountInputView(
                        amount: $monthlyContribution,
                        label: "How much will you save each month?",
                        prependSymbol: "£",
                        onChanged: { _, _ in }
                    )

                    AmountInputView(
                        amount: $annualInterest,
                        label: "Interest Rate",
                        prependSymbol: "£",
                        onChanged: { _, _ in }
                    )
                    
                    NumberInputView(
                        amount: $noYears,
                        label: "How long will you save for?",
                        prependSymbol: "Y",
                        onChanged: { _, _ in }
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
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .bold()
                    .background(Color(.secondary))
                    .clipShape(Capsule())
                    .foregroundStyle(.white)
                }

            }
        }.navigationTitle("Compound Interest Calculator")
            .padding(.all)

    }
}

struct FrequencyPicker: View {
    @Binding fileprivate var selectedFrequency: Frequency

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
private func compoundInterestWithContribution(
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
    //Have to use doubles as the power function does not work well with decimals
    let principal = Double(truncating: principal as NSNumber)
    let annualInterest = Double(truncating: annualInterest as NSNumber) / 100.0
    let compoundFrequency = Double(compoundFrequency)
    let noYears = Double(noYears)
    let monthlyContribution = Double(truncating: monthlyContribution as NSNumber)
    
    let periodicRate = annualInterest / compoundFrequency
    let totalPeriods = compoundFrequency * noYears
    let growthFactor = pow(1 + periodicRate, totalPeriods)

    let principalGrowth = principal * growthFactor

    let numerator = pow(1 + periodicRate, compoundFrequency * noYears) - 1
    let demoninator = pow(1 + periodicRate, compoundFrequency / 12) - 1
        
    let contributionGrowth =
        monthlyContribution * (numerator / demoninator)


    return Decimal(principalGrowth + contributionGrowth)

}
