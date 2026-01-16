import Charts
import SwiftUI

struct CalculatorInput: Equatable {
    var principal: Decimal = 0
    var monthlyContribution: Decimal = 0
    var noYears: Int = 0
    var annualInterest: Decimal = 0
}

struct RegularSaverCalculator: View {
    @State var viewModel: RegularSaverVM = RegularSaverVM()
    @State private var input = CalculatorInput()
    
    @State private var scrollPosition: Int? = 0
    private let scrollSpaceName = "SCROLL_SPACE"

    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    Spacer()
                    GrowthChart(points: $viewModel.amount.graphPoints)
                }
                .zIndex(0)
                .visualEffect { content, proxy in
                    let minY = proxy.frame(in: .named(scrollSpaceName)).minY
                    return content.offset(y: minY < 0 ? -minY * 0.5 : 0)

                }
                .padding(.all)

                CompundInterestCalculatorBodyView(
                    input: $input,
                    total: viewModel.amount.total,
                    onCalculate: {
                        viewModel.compoundInterestMonthly(
                            principal: input.principal,
                            annualInterest: input.annualInterest,
                            noYears: input.noYears,
                            monthlyContribution: input.monthlyContribution
                        )

                        withAnimation(.linear) {
                            scrollPosition = 0
                        }
                    }
                ).zIndex(1)

            }
            .scrollTargetLayout()
        }
        .background(.background)
        .coordinateSpace(name: scrollSpaceName)
        .scrollPosition(id: $scrollPosition)
        .navigationTitle("Compound Interest Calculator")
    }
}

private struct CompundInterestCalculatorBodyView: View {
    @Binding var input: CalculatorInput

    let total: Decimal
    let onCalculate: () -> Void

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
        VStack {
            let result = total.formatted(.number.precision(.fractionLength(2)))

            Spacer()
            
            Text(
                "You would have \( Text("\(result)").foregroundColor(Color(.primary)).bold())"
            )
            .padding(.vertical)

            VStack(spacing: 30) {
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
                    .background(Color(.primary))
                    .clipShape(Capsule())
                    .foregroundStyle(.white)
            }

        }
        .padding(.all)
    }
}
