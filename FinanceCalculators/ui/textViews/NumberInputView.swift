import SwiftUI

struct NumberInputView: View {
    @Binding var amount: Int
    let label: String
    let prependSymbol: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(white: 0.2))

            HStack {
                TextField("", value: $amount, format: .number)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 16))
            }
            .padding()
            .frame(height: 45)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
        }
    }
}
