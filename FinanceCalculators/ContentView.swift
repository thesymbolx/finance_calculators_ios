
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: CompoundInterestCalculator()) {
                    Text("Compound Interest Calculator")
                }
                Text("Number 2")
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
