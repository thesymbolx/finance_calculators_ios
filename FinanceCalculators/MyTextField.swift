import SwiftUI

struct AmountInputView: View {
    @Binding var amount: Double
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(white: 0.2))

            HStack {
                Text("£")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                
                TextField("How much do you have now?", value: $amount, format: .number)
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
        .padding()
    }
}
