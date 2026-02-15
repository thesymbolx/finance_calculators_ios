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
                    state: $viewModel.state,
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
        .background(
            Color(.primary).opacity(0.05)
        )
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

            if let start = state.startMonth, let end = state.endMonth {
                Text("From \(start) to \(end)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.black)
            } else {
                Text("Date range not set")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.black)
            }
            
            Text("£\(result)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color(.primary))
            
            Text("Interest £\(interestEarned)")
                .font(.subheadline.bold())
                .foregroundColor(.black.opacity(0.8))
            
            GrowthChart(points: state.graphPoints)
        }
    }
}

private struct CompundInterestCalculatorBodyView: View {
    @Binding var state: RegularSaverVM.ViewState

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
                amount: $state.principal,
                label: "How much do you have now?",
                prependSymbol: "£",
                onChanged: { old, new in
                    if new > state.limits.principal {
                        state.principal = state.limits.principal
                    }
                }
            )

            AmountInputView(
                amount: $state.monthlyContribution,
                label: "How much will you save each month?",
                prependSymbol: "£",
                onChanged: { old, new in
                    if new > state.limits.monthlyContribution {
                        state.monthlyContribution = state.limits.monthlyContribution
                    }
                }
            )

            AmountInputView(
                amount: $state.annualInterest,
                label: "Interest Rate",
                prependSymbol: "%",
                onChanged: { old, new in
                    if new > state.limits.annualInterest {
                        state.annualInterest = state.limits.annualInterest
                    }
                }
            )

            NumberInputView(
                amount: $state.noYears,
                label: "How long will you save for?",
                prependSymbol: "Y",
                onChanged: { old, new in
                    if new > state.limits.noYears {
                        state.noYears = state.limits.noYears
                    }
                }
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
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.black.opacity(0.9))

            Picker("Frequency", selection: $state.frequency) {
                Text("Monthly")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.black)
                    .tag(CompoundFrequency.MONTHLY)
                
                Text("Annually")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.black)
                    .tag(CompoundFrequency.ANNUALLY)
            }
            .pickerStyle(.segmented)
        }
    }
}
