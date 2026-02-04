
import SwiftUI

struct ContentView: View {
    let roseColor = Color(red: 0xFD/255, green: 0xEA/255, blue: 0xEA/255)
    let blueColor = Color(red: 0xE3/255, green: 0xF2/255, blue: 0xFD/255)

    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: CompoundInterestCalculator()) {
                    Text("Compound Interest Calculator")
                }.listRowBackground(blueColor)
                
                NavigationLink(destination: RegularSaverCalculator()) {
                    Text("Banking Regular Saver Calculator")
                }.listRowBackground(roseColor)
                
                NavigationLink(destination: SimpleRegularSaverCalculator()) {
                    Text("Simple Regular Saver Calculator")
                }.listRowBackground(roseColor)
                
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
