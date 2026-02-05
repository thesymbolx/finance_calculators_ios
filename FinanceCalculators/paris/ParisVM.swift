import Combine
import Foundation
import SwiftUI

@Observable
class ParisVM: ObservableObject {

    struct AmountModel {
        var total: Decimal
        var graphPoints: [Point]
    }

    struct ParisInput: Equatable {
        var principal: Decimal = 0
        var monthlyContribution: Decimal = 0
        var noYears: Int = 0
        var annualInterest: Decimal = 0
        var frequency: CompoundFrequency = .MONTHLY
    }

    var calculatorInput = ParisInput()
    private(set) var graphBalances: AmountModel = AmountModel(
        total: 0,
        graphPoints: []
    )

    var isFormValid: Bool {
        let isPrincipalValid = !calculatorInput.principal.isNaN
        let isContributionValid = !calculatorInput.monthlyContribution.isNaN
        let isInterestValid = !calculatorInput.annualInterest.isNaN
        let isYearsValid = calculatorInput.noYears > 0

        return isPrincipalValid && isContributionValid && isInterestValid
            && isYearsValid
    }

    func calculate() {
        let balancePerYear = calculateBalance()
        let endingBalance = balancePerYear.last!.last!

        graphBalances = AmountModel(
            total: endingBalance,
            graphPoints: toPoint(balancePerYear: balancePerYear)
        )
    }

    /// Commercial-standard calculation: Uses a flat Gross monthly rate (Annual / 12) for simplicity.
    ///
    /// Key Logic:
    /// 1. Timing: Deposits are added at the START of the month (optimistic view).
    /// 2. Rate: Treats input as Gross (Rate/12). This allows Monthly Payouts to correctly outperform Annual Payouts.
    /// 3. Payouts: 'Monthly' compounds immediately (exponential curve), while 'Annually' holds interest in a pot (stepped line).
    private func calculateBalance() -> [[Decimal]] {
        let noYears = calculatorInput.noYears
        let monthlyContribution = calculatorInput.monthlyContribution
        let annualInterest = calculatorInput.annualInterest
        let principal = calculatorInput.principal
        let interestPaidFrequency = calculatorInput.frequency

        let monthlyRate = (annualInterest / 100) / 12

        var balance = principal
        var accruedInterest: Decimal = 0
        var balancePerYear: [[Decimal]] = []

        for _ in 0..<noYears {
            var balancePerMonth: [Decimal] = []

            for month in 1...12 {
                balance += monthlyContribution

                let interest = balance * monthlyRate

                switch interestPaidFrequency {
                case .MONTHLY:
                    balance += interest.rounded(2, .plain)

                case .ANNUALLY:
                    accruedInterest += interest

                    if month == 12 {
                        balance += accruedInterest.rounded(2, .plain)
                        accruedInterest = 0
                    }
                }

                balancePerMonth.append(balance)
            }

            balancePerYear.append(balancePerMonth)
        }

        return balancePerYear
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
