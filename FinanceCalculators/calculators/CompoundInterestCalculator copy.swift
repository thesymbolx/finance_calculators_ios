import Charts
import SwiftUI

struct Dale: View {
    @State var principal: Decimal = 0
    @State var monthlyContribution: Decimal = 0
    @State var noYears: Int = 0
    @State var annualInterest: Decimal = 0
    @State var result: String = "£0.00"
    @State var points: [Point] = []

    @State private var scrollPosition: Int? = 0

    var body: some View {
        ScrollView {

            VStack {
                VStack {
                    Spacer()
                    GrowthChart(points: $points)
                }
                .zIndex(0)
                .visualEffect { content, proxy in
                    let minY = proxy.frame(in: .named("SCROLL")).minY
                    return content.offset(y: minY < 0 ? -minY * 0.5 : 0)

                }

                VStack {
                    Spacer()
                    Text(
                        "You would have \( Text("\(result)").foregroundColor(Color(.primary)).bold())"
                    )
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

                            withAnimation(.linear) {
                                scrollPosition = 0
                            }

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

                            let localPoints = toPoint(
                                balancePerMonth: localResult.balancePerYear
                            )
                            points = localPoints
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .bold()
                        .background(Color(.primary))
                        .clipShape(Capsule())
                        .foregroundStyle(.white)
                    }

                }
                .background(.white)
                .zIndex(1)
            }
            .scrollTargetLayout()
        }
        .coordinateSpace(name: "SCROLL")
        .scrollPosition(id: $scrollPosition)
        .navigationTitle("Compound Interest Calculator")
        .padding(.all)

    }
}

private func compoundInterestMonthly(
    principal: Decimal,
    annualInterest: Decimal,
    noYears: Int,
    monthlyContribution: Decimal
) -> (balancePerYear: [[Decimal]], total: Decimal) {
    var balancePerYear: [[Decimal]] = []
    var daysInMonths = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    let dailyInterestRate = (annualInterest / 100) / 365
    var total = principal

    for year in 1...noYears {
        var balancePerMonth: [Decimal] = []

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

        balancePerYear.append(balancePerMonth)
    }

    return (balancePerYear, total)
}

private func isLeapYear(_ year: Int) -> Bool {
    return year.isMultiple(of: 4)
        && (!year.isMultiple(of: 100) || year.isMultiple(of: 400))
}

private func toPoint(balancePerMonth: [[Decimal]]) -> [Point] {
    var points: [Point] = []

    let handler = NSDecimalNumberHandler(
        roundingMode: .plain,
        scale: 2,
        raiseOnExactness: false,
        raiseOnOverflow: false,
        raiseOnUnderflow: false,
        raiseOnDivideByZero: false
    )

    let flat =
        if balancePerMonth.count > 1 {
            balancePerMonth.map {
                $0.max() ?? 0
            }
        } else {
            Array(balancePerMonth.joined())
        }

    flat.enumerated().forEach { index, balance in
        let roundedY = NSDecimalNumber(decimal: balance).rounding(
            accordingToBehavior: handler
        )

        points.append(.init(x: Double(index), y: roundedY as Decimal))
    }

    return points
}
