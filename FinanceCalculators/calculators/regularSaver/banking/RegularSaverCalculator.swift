import Charts
import SwiftUI

struct RegularSaverCalculator: View {
    @State var viewModel: RegularSaverVM = RegularSaverVM()

    @State private var scrollPosition: Int? = nil
    private let scrollSpaceName = "SCROLL_SPACE"

    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    Color.clear
                        .frame(height: 1)
                        .id(0)
                    
                    CalculatorHeader(
                        state: $viewModel.state
                    )
                }
                .zIndex(0)
                .visualEffect { content, proxy in
                    let minY = proxy.frame(in: .named(scrollSpaceName)).minY
                    return content.offset(y: minY < 0 ? -minY * 0.5 : 0)

                }
                .padding(.all)

                CompundInterestCalculatorBodyView(
                    input: $viewModel.state,
                    total: viewModel.state.balance,
                    onCalculate: {
                        viewModel.calculate()

                        withAnimation(.linear) {
                            scrollPosition = 0
                        }
                    },
                    isButtonEnabled: viewModel.isFormValid
                ).zIndex(1)

            }
            .scrollTargetLayout()
        }
        .background(.background)
        .coordinateSpace(name: scrollSpaceName)
        .scrollPosition(id: $scrollPosition)
        .navigationTitle("Banking Regular Saver")
    }
}

private struct CalculatorHeader: View {
    @Binding var state: RegularSaverVM.ViewState

    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            
            let result = state.balance.formatted(.number.precision(.fractionLength(2)))
            let interestEarned = state.interestEarned.formatted(.number.precision(.fractionLength(2)))

            let balanceText = Text("\(result)")
                .foregroundColor(Color(.primary))
                .bold()
            
            Text("£\(balanceText)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color(.primary))
            
            Text("In Year 2023")
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            
            Text("Interest £\(interestEarned)")
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
            
            GrowthChart(points: state.graphPoints)
        }
    }
}

private struct CompundInterestCalculatorBodyView: View {
    @Binding var input: RegularSaverVM.ViewState

    let total: Decimal
    let onCalculate: () -> Void
    let isButtonEnabled: Bool

    var body: some View {
        ZStack {
            contentBody
        }
        .background(.background)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 25,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 25
            )
        )
        .background {
            UnevenRoundedRectangle(
                topLeadingRadius: 25,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 25
            )
            .fill(Color.white)
            .shadow(
                color: Color.black.opacity(0.1),
                radius: 10,
                x: 0,
                y: 5
            )
            .mask(
                Rectangle()
                    .padding(.top, -20)

            )
        }
    }

    var contentBody: some View {
        VStack(spacing: 30) {
            frequencyPicker

            AmountInputView(
                amount: $input.principal,
                label: "How much do you have now?",
                prependSymbol: "£"
            )

            AmountInputView(
                amount: $input.monthlyContribution,
                label: "How much will you save each month?",
                prependSymbol: "£"
            )

            AmountInputView(
                amount: $input.annualInterest,
                label: "Interest Rate",
                prependSymbol: "£"
            )

            NumberInputView(
                amount: $input.noYears,
                label: "How long will you save for?"
            )

            Button("Calculate", action: onCalculate)
                .frame(maxWidth: .infinity)
                .padding()
                .bold()
                .background(isButtonEnabled ? Color(.primary) : Color.gray)
                .clipShape(Capsule())
                .foregroundStyle(.white)
                .disabled(!isButtonEnabled)

        }
        .padding(.all)
    }

    var frequencyPicker: some View {
        VStack(alignment: .leading) {
            Text("Interest Paid")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(white: 0.2))

            Picker("Frequency", selection: $input.frequency) {
                Text("Monthly").tag(CompoundFrequency.MONTHLY)
                Text("Annually").tag(CompoundFrequency.ANNUALLY)
            }
            .pickerStyle(.segmented)
        }
    }
}
