
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: CompoundInterestCalculator()) {
                    Text("Compound Interest Calculator")
                }
                NavigationLink(destination: RegularSaverCalculator()) {
                    Text("Regular Saver Calculator")
                }
                Text("Number 3")
                Text("Number 4")
                Text("Number 5")
            }
        }
    }
}

#Preview {
    ContentView()
}
