import Combine
import Foundation
import SwiftUI


@Observable
class SimpleRegularSaverVM: ObservableObject {

    struct AmountModel {
        var total: Decimal
        var graphPoints: [Point]
    }

    struct CalculatorInput: Equatable {
        var principal: Decimal = 0
        var monthlyContribution: Decimal = 0
        var noYears: Int = 0
        var annualInterest: Decimal = 0
        var frequency: CompoundFrequency = .MONTHLY
    }

    var calculatorInput = CalculatorInput()
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

    private func calculateBalance() -> [[Decimal]] {
        let compoundFrequency = calculatorInput.frequency
        let noYears = calculatorInput.noYears
        let principal = calculatorInput.principal
        let annualInterest = calculatorInput.annualInterest
        let monthlyContribution = calculatorInput.monthlyContribution

        var balancePerYear: [[Decimal]] = []

        let monthlyInterestRate = (annualInterest / 100) / 12
        var total = principal
        var accruedInterest: Decimal = 0

        for _ in 0..<noYears {
            var balancePerMonth: [Decimal] = []

            for month in 1...12 {

                total += monthlyContribution

                let interestForMonth = total * monthlyInterestRate
                accruedInterest += interestForMonth
                
                print(accruedInterest)

                switch compoundFrequency {
                    case .MONTHLY:
                        total += accruedInterest.rounded(2, .plain)
                        accruedInterest = 0

                    case .ANNUALLY:
                        if month == 12 {
                            total += accruedInterest.rounded(2, .plain)
                            accruedInterest = 0
                        }
                }

                balancePerMonth.append(total)
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
