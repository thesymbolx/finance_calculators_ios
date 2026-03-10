import SwiftUI

struct ContentView: View {
    let blueColor = Color(red: 0.83, green: 0.24, blue: 0.27)
    let greenColor = Color(red: 0.13, green: 0.61, blue: 0.35)
    let roseColor = Color(red: 0.83, green: 0.24, blue: 0.27)

    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ZStack {
                        CalculatorCardView(
                            title: "Regular Saver",
                            description: "Growth for regular deposits",
                            iconName: "piggybank",
                            backgroundColor: greenColor,
                            isSystemImage: false
                        )

                        NavigationLink(destination: RegularSaverCalculator()) {
                            EmptyView()
                        }
                        .opacity(0)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(
                        EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
                    )

                    ZStack {
                        CalculatorCardView(
                            title: "Saving Goal",
                            description: "How long to reach a sum",
                            iconName: "growth",
                            backgroundColor: blueColor,
                            isSystemImage: false
                        )

                        NavigationLink(
                            destination: CompoundInterestCalculator()
                        ) {
                            EmptyView()
                        }
                        .opacity(0)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(
                        EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
                    )

                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Calculators")
            .background(.background)
        }
    }
}

struct CalculatorCardView: View {
    let title: String
    let description: String
    let iconName: String
    let backgroundColor: Color
    let isSystemImage: Bool

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .multilineTextAlignment(.leading)

                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .opacity(0.9)
                    .multilineTextAlignment(.leading)
            }

            Spacer()
           
            Image(iconName)
                .resizable()
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .padding(.trailing, 4)
                .foregroundColor(.white)

            
            Image(systemName: "chevron.right")
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
                .frame(width: 14, height: 14)
                .foregroundColor(.white)
                
        }
        .padding(.vertical, 22)
        .padding(.horizontal, 16)
        .background(backgroundColor)
        .foregroundColor(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    ContentView()
}
