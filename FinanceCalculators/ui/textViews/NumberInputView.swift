import SwiftUI

struct NumberInputView: View {
    @Binding var amount: Int
    let label: String
    let prependSymbol: String
    let onChanged: (Int, Int) -> Void

    var body: some View {

        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.black.opacity(0.9))

            HStack(spacing: 0) {
                Text(prependSymbol)
                    .font(.system(size: 18, weight: .bold))
                    .frame(width: 45, height: 45)
                    .foregroundColor(Color(.primary))
                    .background(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 12,
                            bottomLeadingRadius: 12,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 0
                        )
                        .fill(Color(.primary).opacity(0.1))
                    )
                    .overlay(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 12,
                            bottomLeadingRadius: 12,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 0
                        )
                        .stroke(Color(.primary), lineWidth: 2)
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
                    .onChange(of: amount) { oldValue, newValue in
                        onChanged(oldValue, newValue)
                    }
            }
            .background(Color.white)
        }
    }
}
