import SwiftUI
import Charts

struct GrowthChart: View {
    @Binding var points: [Point]
    
    var calculatedData: [Point] {
        var tally = 0
        return (1...10).map { i in
            tally += Int.random(in: 0..<6)
            return Point(x: i, y: i + tally)
        }
    }
    
    var body: some View {
        Chart {
            ForEach(points) { point in
                LineMark(
                    x: .value("X", point.x),
                    y: .value("Y", point.y)
                ).foregroundStyle(Color(.primary))
                    .symbol(.circle)
            }
        }.frame(height: 300)
    }
}

struct Point: Identifiable {
    let id = UUID()
    let x: Int
    let y: Int
}
