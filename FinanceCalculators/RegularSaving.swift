//
//  RegularSaving.swift
//  FinanceCalculators
//
//  Created by Dale Evans on 19/12/2025.
//

import SwiftUI


struct RegularSavingView: View {
    @State var currentAmount: String = ""
    @State var monthlyAmount: String = ""
    @State var howLong: String = ""
    @State var interestRate: String = ""
    @State var taxBand: String = ""
    @State var result: String = "0.0"
    
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("how much do you have now?", text: $currentAmount)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
            
            TextField("how much will you save each month?", text: $monthlyAmount)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
            
            TextField("How long will you save for?", text: $howLong)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
            
            TextField("Interest Rate", text: $interestRate)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
            
            TextField("How much tax do you pay on interest?", text: $taxBand)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
            
            Text("You would have \(result)")

        }.navigationTitle("Regular Saving")
            .padding(.all)
    }
}

func calculate(currentAmount: Double, monthlyAmount: Double, howLong: Double, interestRate: Double, taxBand: Double) -> Double {
    return currentAmount + monthlyAmount * howLong
}

