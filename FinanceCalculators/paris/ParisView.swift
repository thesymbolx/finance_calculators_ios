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
        .navigationTitle("NDC Target")
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
            VStack(spacing: 0) {
                
                // Header
                Text("Select Country")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 20)
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    Text("Search countries...")
                        .foregroundColor(.gray.opacity(0.8))
                    
                    Spacer()
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.bottom, 15)

                ForEach(countries) { country in
                    let isSelected = country.name == "Australia"
                    
                    // MOCKED DATA: Determine status based on country for the screenshot
                    let status: (text: String, color: Color) = {
                        switch country.name {
                        case "Australia": return ("13% Above Target", .orange)
                        case "Argentina": return ("2% Below Target", .green)  // Added value
                        case "Brazil":    return ("8% Below Target", .green)  // Changed from "Trending" for consistency
                        case "Canada":    return ("5% Above Target", .orange)
                        case "China":     return ("20% Above Target", .red)
                        case "France":    return ("5% Below Target", .green)
                        default: return ("On target", .gray)
                        }
                    }()
                    
                    NavigationLink(
                        destination: Text("Details for \(country.name)")
                    ) {
                        HStack {
                            Text(country.flag)
                                .font(.largeTitle)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(country.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                // NEW: Dot Summary Row
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(status.color)
                                        .frame(width: 8, height: 8)
                                    
                                    Text(status.text)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            // Icon Logic
                            Image(systemName: isSelected ? "checkmark.circle.fill" : "chevron.right")
                                .font(.caption)
                                .foregroundColor(isSelected ? .blue : .gray.opacity(0.5))
                        }
                        // Styling for the "Selected" state
                        .padding(.vertical, 12)
                        .padding(.horizontal, 12)
                        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue.opacity(0.3), lineWidth: isSelected ? 1 : 0)
                        )
                    }
                    .padding(.vertical, 4)
                    
                    if !isSelected {
                        Divider()
                            .padding(.leading, 50)
                    }
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
