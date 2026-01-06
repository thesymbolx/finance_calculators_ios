import SwiftUI

struct AmountInputView: View {
    @Binding var amount: Decimal
    let label: String
    let prependSymbol: String


    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(white: 0.2))

            HStack() {
                Text(prependSymbol)
                    .font(.system(size: 18, weight: .bold))
                    .frame(width: 45, height: 45)
                    .foregroundColor(.white)
                    .background(Color(.secondary))
                    .clipShape(
                            UnevenRoundedRectangle(
                                topLeadingRadius: 12,
                                bottomLeadingRadius: 12,
                                bottomTrailingRadius: 0,
                                topTrailingRadius: 0
                            )
                        )
                
                TextField("", value: $amount, format: .currency(code: ""))
                    .keyboardType(.decimalPad)
                    .font(.system(size: 16))
            }
            .frame(height: 45)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
        }
    }
}
