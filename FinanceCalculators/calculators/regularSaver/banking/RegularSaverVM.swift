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
    struct Limits {
        let principal: Decimal = 100_000_000
        let monthlyContribution: Decimal = 10_000
        let noYears = 100
        var annualInterest: Decimal = 30
    }

    struct ViewState {
        var limits = Limits()
        var graphPoints: [Point] = []
        var balance: Decimal = 0
        var interestEarned: Decimal = 0
        var principal: Decimal = 0
        var monthlyContribution: Decimal = 0
        var noYears: Int = 0
        var annualInterest: Decimal = 0
        var frequency: CompoundFrequency = .MONTHLY
        var startMonth: String? = nil
        var endMonth: String? = nil
    }

    var state = ViewState()

    var isFormValid: Bool {
        let isPrincipalValid = !state.principal.isNaN
        let isContributionValid = !state.monthlyContribution.isNaN
        let isInterestValid = !state.annualInterest.isNaN
        let isYearsValid = state.noYears > 0

        return isPrincipalValid && isContributionValid && isInterestValid && isYearsValid
    }

    func calculate() {
        let (balancePerYear, interestEarned) =
            calculateBalanceAdjustedStartDate()
        let endingBalance = balancePerYear.last!.last!

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"

        let currentDate = Date()
        let startMonthDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
        let endMonthDate =
            Calendar.current.date(
                byAdding: .month,
                value: 12 * state.noYears,
                to: currentDate
            ) ?? currentDate

        state.startMonth = dateFormatter.string(from: startMonthDate)
        state.endMonth = dateFormatter.string(from: endMonthDate)
        state.balance = endingBalance
        state.interestEarned = interestEarned
        state.graphPoints = toPoint(balancePerYear: balancePerYear)
    }

    /// Calculates the projected balance using banking-standard "Daily Accrual."
    ///
    /// Key Logic:
    /// 1. Precision: Uses actual days in the month (e.g., Jan=31, Feb=28/29).
    /// 2. Starts on the next month from current (e.g. if current month is Feb start in March). This avoids overcalculation when days in current month have already passed.
    /// 3. Timing: Deposits are added at the START of the month (earning full interest).
    /// 4. Rate: Uses a daily rate (Annual / 365) for maximum accuracy.
    /// 5. Rounding: Interest is accrued precisely, then rounded (2dp) only when paid out (Monthly or Annually).
    private func calculateBalanceAdjustedStartDate() -> (
        balancesPerYear: [[Decimal]], interestEarned: Decimal
    ) {
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

        //Start on the next full month to avoid complext logic of adjusting for the partial current month
        let currentDate = Date()
        let startMonthDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
        let startMonthIndex = Calendar.current.component(.month, from: startMonthDate) - 1

        for yearCount in 0..<noYears {
            var balancePerMonth: [Decimal] = []

            daysInMonths[1] = getDaysInFeb(
                yearCount: yearCount,
                startMonth: startMonthIndex,
                currentDate: currentDate
            )

            for monthCount in 0..<12 {
                // Determine if Feb falls in the Current Year or Next Year
                // If we start in March (Index 2) or later, the next Feb is next year.
                let currentMonthIndex = (startMonthIndex + monthCount) % 12
                let daysInCurrentMonth = daysInMonths[currentMonthIndex]

                total += monthlyContribution

                let interestForMonth = (total * dailyInterestRate) * Decimal(daysInCurrentMonth)
                accruedInterest += interestForMonth

                switch compoundFrequency {
                case .MONTHLY:
                    total += accruedInterest.rounded(2, .plain)
                    totalInterestEarned += accruedInterest
                    accruedInterest = 0
                case .ANNUALLY:
                    if monthCount == 11 {
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

    private func getDaysInFeb(
        yearCount: Int,
        startMonth: Int,
        currentDate: Date
    ) -> Int {
        //If start month after feb, feb is in next year so offset to next year.
        let yearOffset = startMonth > 1 ? 1 : 0

        //Get current year, unless feb is in next year, in which case get next year.
        let dateYearAdjusted =
            Calendar.current.date(
                byAdding: .year,
                value: yearCount + yearOffset,
                to: currentDate
            ) ?? currentDate
        let adjustedYear = Calendar.current.component(
            .year,
            from: dateYearAdjusted
        )

        let isLeapYear =
            adjustedYear.isMultiple(of: 4)
            && (!adjustedYear.isMultiple(of: 100)
                || adjustedYear.isMultiple(of: 400))

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
