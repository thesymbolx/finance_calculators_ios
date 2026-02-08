import Combine
import Foundation
import SwiftUI

extension Decimal {
    func rounded(_ scale: Int, _ mode: NSDecimalNumber.RoundingMode) -> Decimal
    {
        var result = Decimal()
        var source = self
        NSDecimalRound(&result, &source, scale, mode)
        return result
    }
}

@Observable
class RegularSaverVM: ObservableObject {
    struct ViewState {
        var graphPoints: [Point] = []
        var balance: Decimal = 0
        var interestEarned: Decimal = 0
        var principal: Decimal = 0
        var monthlyContribution: Decimal = 0
        var noYears: Int = 0
        var annualInterest: Decimal = 0
        var frequency: CompoundFrequency = .MONTHLY
    }

    var state = ViewState()

    var isFormValid: Bool {
        let isPrincipalValid = !state.principal.isNaN
        let isContributionValid = !state.monthlyContribution.isNaN
        let isInterestValid = !state.annualInterest.isNaN
        let isYearsValid = state.noYears > 0

        return isPrincipalValid && isContributionValid && isInterestValid
            && isYearsValid
    }

    func calculate() {
        let (balancePerYear, interestEarned) = calculateBalance()
        let endingBalance = balancePerYear.last!.last!
    
        state.balance = endingBalance
        state.interestEarned = interestEarned
        state.graphPoints =  toPoint(balancePerYear: balancePerYear)
    }

    /// Calculates the projected balance using banking-standard "Daily Accrual."
    ///
    /// Key Logic:
    /// 1. Precision: Uses actual days in the month (e.g., Jan=31, Feb=28/29).
    /// 2. Timing: Deposits are added at the START of the month (earning full interest).
    /// 3. Rate: Uses a daily rate (Annual / 365) for maximum accuracy.
    /// 4. Rounding: Interest is accrued precisely, then rounded (2dp) only when paid out (Monthly or Annually).
    private func calculateBalance() -> (balancesPerYear: [[Decimal]], interestEarned: Decimal) {
        let compoundFrequency = state.frequency
        let noYears = state.noYears
        let principal = state.principal
        let annualInterest = state.annualInterest
        let monthlyContribution = state.monthlyContribution

        var balancePerYear: [[Decimal]] = []
        var daysInMonths = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

        let dailyInterestRate = (annualInterest / 100) / 365
        var total = principal
        var accruedInterest: Decimal = 0
        var totalInterestEarned: Decimal = 0

        for year in 0..<noYears {
            var balancePerMonth: [Decimal] = []

            daysInMonths[1] = getDaysInFeb(currentYear: year)

            for (monthIndex, daysInMonth) in daysInMonths.enumerated() {

                total += monthlyContribution

                let interestForMonth =
                    (total * dailyInterestRate) * Decimal(daysInMonth)
                accruedInterest += interestForMonth

                switch compoundFrequency {
                case .MONTHLY:
                    total += accruedInterest.rounded(2, .plain)
                    totalInterestEarned += accruedInterest
                    accruedInterest = 0
                case .ANNUALLY:
                    if monthIndex == 11 {
                        total += accruedInterest.rounded(2, .plain)
                        totalInterestEarned += accruedInterest
                        accruedInterest = 0
                    }
                }

                balancePerMonth.append(total)
            }

            balancePerYear.append(balancePerMonth)
        }

        return (balancePerYear, totalInterestEarned.rounded(2, .plain))
    }

    private func getDaysInFeb(currentYear: Int) -> Int {
        let currentYear =
            Calendar
            .current
            .component(.year, from: Date())
            .advanced(by: currentYear)

        let isLeapYear =
            currentYear.isMultiple(of: 4)
            && (!currentYear.isMultiple(of: 100)
                || currentYear.isMultiple(of: 400))

        return isLeapYear ? 29 : 28
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
