
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: RegularSavingView()) {
                    Text("How much could I have if I save regularly?")
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
