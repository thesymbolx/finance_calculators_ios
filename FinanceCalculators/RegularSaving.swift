//
//  RegularSaving.swift
//  FinanceCalculators
//
//  Created by Dale Evans on 19/12/2025.
//

import SwiftUI
import Charts


struct RegularSavingView: View {
    @State var principal: Double? = 30000
    @State var monthlyDeposit: Double? = 300
    @State var years: Int? = 10
    @State var annualRate: Double = 10
    @State var taxBand: String = ""
    @State var result: Double = 0.0
    
    
    var body: some View {
        VStack(spacing: 20) {
            Chart {
                LineMark(
                        x: .value("Shape Type", 10),
                        y: .value("Total Count", 10)
                    )
                LineMark(
                         x: .value("Shape Type", 33),
                         y: .value("Total Count", 55)
                    )
                LineMark(
                         x: .value("Shape Type", 66),
                         y: .value("Total Count", 88)
                    )
            }
            
            Text("You would have \(result)")
            
            TextField("How much do you have now?", value: $principal, format: .number)
                 .keyboardType(.decimalPad)
                 .textFieldStyle(.roundedBorder)
            
           TextField("How much will you save each month?", value: $monthlyDeposit, format: .number)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
            
            TextField("How long will you save for?", value: $years, format: .number)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
            
            TextField("Interest Rate", value: $annualRate, format: .number)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
            
            Button("Calculate") {
                if principal != nil && monthlyDeposit != nil && years != nil {
                    result = calculate(
                        principal: 30000,
                        monthlyDeposit: 300,
                        annualRate: 10,
                        years: 10
                    )
                }
            }

        }.navigationTitle("Regular Saving")
            .padding(.all)
    }
}

//func calculate(principle: Double, monthlyAmount: Double, howLong: Int, interestRate: Double) -> Double {
//    let lumpSumGrowth = principle * pow(1 + interestRate / 100, Double(howLong))
//    
//    return principle * pow(1 + interestRate / 100, Double(howLong))
//}

func calculate(principal: Double, monthlyDeposit: Double, annualRate: Double, years: Double) -> Double {
    let n: Double = 1 // Compounding frequency (monthly)
    let r_n = annualRate / n // Periodic interest rate
    let nt = n * years // Total number of periods
    
    // 1. Growth of the initial principal: P(1 + r/n)^(nt)
    let principalGrowth = principal * pow(1 + r_n, nt)
    
    // 2. Growth of the monthly deposits: PMT * [((1 + r/n)^(nt) - 1) / (r/n)]
    let depositGrowth = monthlyDeposit * ((pow(1 + r_n, nt) - 1) / r_n)
    
    print(principalGrowth)
    
    return principalGrowth + depositGrowth
}

