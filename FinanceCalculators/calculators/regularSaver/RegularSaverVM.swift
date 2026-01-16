import Combine
import SwiftUI

struct AmountModel {
    var total: Decimal
    var graphPoints: [Point]
}

@Observable
class RegularSaverVM {
    var amount: AmountModel = AmountModel(total: 0, graphPoints: [])

    func compoundInterestMonthly(
        principal: Decimal,
        annualInterest: Decimal,
        noYears: Int,
        monthlyContribution: Decimal
    ) {
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
        
        amount = AmountModel(
            total: total,
            graphPoints: toPoint(balancePerYear: balancePerYear)
        )
    }

    private func isLeapYear(_ year: Int) -> Bool {
        return year.isMultiple(of: 4)
            && (!year.isMultiple(of: 100) || year.isMultiple(of: 400))
    }

    private func toPoint(balancePerYear: [[Decimal]]) -> [Point] {
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
            if balancePerYear.count > 1 {
                balancePerYear.map {
                    $0.max() ?? 0
                }
            } else {
                Array(balancePerYear.joined())
            }

        flat.enumerated().forEach { index, balance in
            let roundedY = NSDecimalNumber(decimal: balance).rounding(
                accordingToBehavior: handler
            )

            points.append(.init(x: Double(index), y: roundedY as Decimal))
        }

        return points
    }

}
