import SwiftUI
import Charts

struct GrowthChart: View {
    @Binding var points: [Point]
    
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
    let x: Double
    let y: Double
}
