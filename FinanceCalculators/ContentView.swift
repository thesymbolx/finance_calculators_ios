import SwiftUI

struct ContentView: View {
    // Defined standard colors for the cards
    let blueColor = Color(red: 0xE3 / 255, green: 0xF2 / 255, blue: 0xFD / 255)
    let greenColor = Color(red: 0.13, green: 0.61, blue: 0.35)
    let roseColor = Color(red: 0xFD / 255, green: 0xEA / 255, blue: 0xEA / 255)

    var body: some View {
        NavigationView {
            List {
                // 1. Compound Interest Card
                ZStack {
                    CalculatorCardView(
                        title: "Compound Interest Calculator",
                        description: "Analyze growth from a lump sum",
                        iconName: "sparkles",
                        backgroundColor: blueColor,
                        foregroundColor: .primary
                    )
                    
                    // Invisible NavigationLink
                    NavigationLink(destination: CompoundInterestCalculator()) {
                        EmptyView()
                    }
                    .opacity(0) // Hides the link and its default chevron
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

                ZStack {
                    CalculatorCardView(
                        title: "Banking Regular Saver",
                        description: "Growth for regular deposits",
                        iconName: "piggybank",
                        backgroundColor: greenColor,
                        foregroundColor: .white
                    )
                    
                    NavigationLink(destination: RegularSaverCalculator()) {
                        EmptyView()
                    }
                    .opacity(0)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

                // 3. Simple Regular Saver Card
                ZStack {
                    CalculatorCardView(
                        title: "Simple Regular Saver",
                        description: "Calculate basic interest on regular savings",
                        iconName: "banknote",
                        backgroundColor: roseColor,
                        foregroundColor: .primary
                    )
                    
                    NavigationLink(destination: SimpleRegularSaverCalculator()) {
                        EmptyView()
                    }
                    .opacity(0)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
            .listStyle(.plain)
            .navigationTitle("My Calculators")
        }
    }
}

// Reusable card view (Chevron removed from HStack)
struct CalculatorCardView: View {
    let title: String
    let description: String
    let iconName: String
    let backgroundColor: Color
    let foregroundColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .multilineTextAlignment(.leading)

                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .opacity(0.8)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()

            HStack(spacing: 12) {
                Image(iconName)
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(backgroundColor)
        .foregroundColor(foregroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
    }
}

#Preview {
    ContentView()
}
