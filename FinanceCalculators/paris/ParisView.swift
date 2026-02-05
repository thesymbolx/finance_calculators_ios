import Charts
import SwiftUI

struct ParisView: View {
    @State var viewModel = ParisVM()

    @State private var scrollPosition: Int? = 0
    private let scrollSpaceName = "SCROLL_SPACE"

    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    Spacer()
                    EmissionsChart(points: stubbedEmissions)
                }
                .zIndex(0)
                .visualEffect { content, proxy in
                    let minY = proxy.frame(in: .named(scrollSpaceName)).minY
                    return content.offset(y: minY < 0 ? -minY * 0.5 : 0)

                }
                .padding(.all)

                CompundInterestCalculatorBodyView(
                    input: $viewModel.calculatorInput,
                    total: viewModel.graphBalances.total,
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
        .navigationTitle("Paris Agreement Target")
    }
}

private struct CompundInterestCalculatorBodyView: View {
    @Binding var input: ParisVM.ParisInput

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

    // 1. Define a native Swift model
    struct Country: Identifiable {
        let id = UUID()
        let name: String
        let flag: String
    }

    // 2. Native mock data
    let countries = [
            Country(name: "Argentina", flag: "🇦🇷"),
            Country(name: "Australia", flag: "🇦🇺"),
            Country(name: "Brazil", flag: "🇧🇷"),
            Country(name: "Canada", flag: "🇨🇦"),
            Country(name: "China", flag: "🇨🇳"),
            Country(name: "France", flag: "🇫🇷"),
            Country(name: "Germany", flag: "🇩🇪"),
            Country(name: "India", flag: "🇮🇳"),
            Country(name: "Japan", flag: "🇯🇵"),
            Country(name: "Mexico", flag: "🇲🇽"),
            Country(name: "South Africa", flag: "🇿🇦"),
            Country(name: "United Kingdom", flag: "🇬🇧"),
            Country(name: "United States", flag: "🇺🇸")
        ]

    var contentBody: some View {
            // You usually need a NavigationStack at the root level for NavigationLink to work
            VStack(spacing: 0) { // Changed spacing to 0 to handle dividers manually

                // Header
                Text("Select Location")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 20) // Add padding here since we removed VStack spacing

                // SOLUTION: Use ForEach instead of List
                ForEach(countries) { country in
                    
                    // NavigationLink handles the tap & transition
                    NavigationLink(
                        destination: Text("Details for \(country.name)")
                    ) {
                        HStack {
                            Text(country.flag)
                                .font(.largeTitle)

                            VStack(alignment: .leading) {
                                Text(country.name)
                                    .font(.headline)
                                    .foregroundColor(.primary) // Ensure text is black/white, not blue link color
                                Text("Tap to view emissions")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Optional: Add a chevron to show it's clickable
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Manually add the separator line that List usually provides
                    Divider()
                }
            }
            .padding(.all)
        }

    var frequencyPicker: some View {
        VStack(alignment: .leading) {
            Text("Interest paid")
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
