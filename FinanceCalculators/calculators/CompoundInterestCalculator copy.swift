import Charts
import SwiftUI

struct Dale: View {
    @State var principal: Decimal = 0
    @State var monthlyContribution: Decimal = 0
    @State var noYears: Int = 0
    @State var annualInterest: Decimal = 0
    @State var result: String = "£0.00"
    @State var points: [Point] = [Point(x: 1, y: 2)]

    var body: some View {
        ScrollView {
            Spacer()

            GrowthChart(points: $points)

            let resultText = Text("\(result)")
                .foregroundColor(Color(.primary))
                .bold()

            VStack() {
                Spacer()
                Text("You would have \(resultText)")
                    .padding(.vertical)

                VStack(spacing: 30) {
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
                        let localResult = compoundInterestMonthly(
                            principal: principal,
                            annualInterest: annualInterest,
                            noYears: noYears,
                            monthlyContribution: monthlyContribution
                        )

                        let formattedResult = localResult.total.formatted(
                            .number.precision(.fractionLength(2))
                        )

                        result = "£\(formattedResult)"

                        points = toPoint(balancePerMonth: localResult.balancePerMonth)

                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .bold()
                    .background(Color(.primary))
                    .clipShape(Capsule())
                    .foregroundStyle(.white)
                }

            }
        }.navigationTitle("Compound Interest Calculator")
            .padding(.all)

    }
}

private func compoundInterestMonthly(
    principal: Decimal,
    annualInterest: Decimal,
    noYears: Int,
    monthlyContribution: Decimal
) -> (balancePerMonth: [Decimal], total: Decimal) {
    var balancePerMonth: [Decimal] = []
    var daysInMonths = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    let dailyInterestRate = (annualInterest / 100) / 365
    var total = principal
    
    for year in 1...noYears {
        if isLeapYear(year) {
            daysInMonths[1] = 29
        } else {
            daysInMonths[1] = 28
        }
        
        daysInMonths.forEach { day in
            total += monthlyContribution
            total += (total * dailyInterestRate) * Decimal(day)
            balancePerMonth.append(total)
        }
    }
    
    return (balancePerMonth, total)
}

private func isLeapYear(_ year: Int) -> Bool {
    return year.isMultiple(of: 4) && (!year.isMultiple(of: 100) || year.isMultiple(of: 400))
}

private func toPoint(balancePerMonth: [Decimal]) -> [Point] {
    var points: [Point] = []
    
    let handler = NSDecimalNumberHandler(
        roundingMode: .plain,
        scale: 2,
        raiseOnExactness: false,
        raiseOnOverflow: false,
        raiseOnUnderflow: false,
        raiseOnDivideByZero: false
    )
    
    balancePerMonth.enumerated().forEach { index, balance in
        let rounded = NSDecimalNumber(decimal: balance).rounding(accordingToBehavior: handler)
        
        points.append(.init(x: Double(index), y: Double(rounded)))
    }
    
    return points
}




