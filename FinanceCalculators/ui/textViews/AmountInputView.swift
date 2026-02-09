import SwiftUI

struct AmountInputView: View {
    @Binding var amount: Decimal
    let label: String
    let prependSymbol: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.headline)
                .foregroundColor(Color(white: 0.2))

            HStack(spacing: 0) {
                Text(prependSymbol)
                    .font(.system(size: 18, weight: .bold))
                    .frame(width: 45, height: 45)
                    .foregroundColor(Color(.primary))
                    .overlay(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 12,
                            bottomLeadingRadius: 12,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 0
                        ).stroke(Color(.primary), lineWidth: 2)
                            .background(Color(.primary).opacity(0.1))
                    )
                
                
                TextField("", value: $amount, format: .currency(code: ""))
                    .keyboardType(.decimalPad)
                    .font(.system(size: 16))
                    .padding(.leading, 12)
                    .frame(maxWidth: .infinity)
                    .frame(height: 45)
                    .overlay(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 0,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 12,
                            topTrailingRadius: 12
                        ).stroke(Color.gray.opacity(0.5), lineWidth: 2)
                    )
            }
            .background(Color.white)
        }
    }
}
