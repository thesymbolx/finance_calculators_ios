import SwiftUI
import Charts

struct GrowthChart: View {
    // 1. Create a simple data model
    struct Point: Identifiable {
        let id = UUID()
        let x: Int
        let y: Int
    }
    
    // 2. Do all your math here, outside the body
    var calculatedData: [Point] {
        var tally = 0
        return (1...10).map { i in
            tally += Int.random(in: 0..<6)
            return Point(x: i, y: i + tally)
        }
    }
    
    var body: some View {
        Chart {
            // 3. The body only handles "Display"
            ForEach(calculatedData) { point in
                LineMark(
                    x: .value("X", point.x),
                    y: .value("Y", point.y)
                ).foregroundStyle(Color(.primary))
            }
        }.frame(height: 300)
    }
}
