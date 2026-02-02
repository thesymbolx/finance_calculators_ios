import Combine
import SwiftUI

@Observable
class RegularSaverVM: ObservableObject {
    struct AmountModel {
        var total: Decimal
        var graphPoints: [Point]
    }

    enum Frequency: String, CaseIterable {
        case MONTHLY = "Monthly"
        case ANNUALLY = "Annually"
    }

    struct CalculatorInput: Equatable {
        var principal: Decimal = 0
        var monthlyContribution: Decimal = 0
        var noYears: Int = 0
        var annualInterest: Decimal = 0
        var frequency: Frequency = .MONTHLY
    }
    
    var calculatorInput = CalculatorInput()
    private(set) var graphBalances: AmountModel = AmountModel(total: 0, graphPoints: [])
    
    var isFormValid: Bool {
            let isPrincipalValid = !calculatorInput.principal.isNaN
            let isContributionValid = !calculatorInput.monthlyContribution.isNaN
            let isInterestValid = !calculatorInput.annualInterest.isNaN
            let isYearsValid = calculatorInput.noYears > 0
            
            return isPrincipalValid && isContributionValid && isInterestValid && isYearsValid
        }
    
    func calculate() {
        if(calculatorInput.frequency == .MONTHLY) {
            compoundInterestMonthly()
        } else if(calculatorInput.frequency == .ANNUALLY) {
            compoundInterestYearly()
        }
    }

    private func compoundInterestMonthly() {
        let noYears = calculatorInput.noYears
        let principal = calculatorInput.principal
        let annualInterest = calculatorInput.annualInterest
        let monthlyContribution = calculatorInput.monthlyContribution
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
                let accuredInterest = (total * dailyInterestRate) * Decimal(day)
                balancePerMonth.append(total + accuredInterest)
            }

            balancePerYear.append(balancePerMonth)
        }
        
        graphBalances = AmountModel(
            total: total,
            graphPoints: toPoint(balancePerYear: balancePerYear)
        )
    }
    
    private func compoundInterestYearly() {
        let noYears = calculatorInput.noYears
        let principal = calculatorInput.principal
        let annualInterest = calculatorInput.annualInterest
        let monthlyContribution = calculatorInput.monthlyContribution
        var balancePerYear: [[Decimal]] = []
        var daysInMonths = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        let dailyInterestRate = (annualInterest / 100) / 365
        var total = principal
        var accuredInterest: Decimal = 0

        for year in 1...noYears {
            var balancePerMonth: [Decimal] = []

            if isLeapYear(year) {
                daysInMonths[1] = 29
            } else {
                daysInMonths[1] = 28
            }

            daysInMonths.forEach { day in
                total += monthlyContribution
                accuredInterest += (total * dailyInterestRate) * Decimal(day)
                balancePerMonth.append(total)
            }
            
            balancePerMonth[balancePerMonth.count - 1] += accuredInterest

            balancePerYear.append(balancePerMonth)
        }
        
        graphBalances = AmountModel(
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
