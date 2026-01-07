import SwiftUI
import Charts

struct GrowthChart: View {
    @Binding var points: [Point]
    
    var body: some View {
        Chart {
            ForEach(points) { point in
                let line = LineMark(
                    x: .value("X", point.x),
                    y: .value("Y", point.y)
                )
                .foregroundStyle(Color(.primary))
                .interpolationMethod(.catmullRom)
                
                if points.count < 20 {
                    line.symbol(.circle)
                } else {
                    line
                }
            }
        }
        .frame(height: 300)
        .chartXScale(
            domain: .automatic(includesZero: false),
            range: .plotDimension(startPadding: 20, endPadding: 20)
        )
        .chartYScale(
            domain: .automatic(includesZero: false),
            range: .plotDimension(startPadding: 20, endPadding: 20)
        )
        .chartYAxis {
            // Uses "£3B", "£500M", "£10k" etc.
            AxisMarks(format: .currency(code: "GBP").notation(.compactName))
        }
        // 3. Animate changes smoothly
      //  .animation(.spring(response: 0, dampingFraction: 1), value: points)
    }
}

struct Point: Identifiable, Equatable {
    let id = UUID()
    let x: Double
    let y: Decimal
}
