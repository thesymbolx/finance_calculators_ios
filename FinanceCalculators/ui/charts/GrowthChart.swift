import SwiftUI
import Charts

struct GrowthChart: View {
    let points: [Point]
    
    var body: some View {
        Chart {
            if points.isEmpty {
                RuleMark(y: .value("Y", 0)).foregroundStyle(.clear)
                RuleMark(y: .value("Y", 1000)).foregroundStyle(.clear)
                
                RuleMark(x: .value("X", 0)).foregroundStyle(.clear)
                RuleMark(x: .value("X", 10)).foregroundStyle(.clear)
            } else {
                ForEach(points) { point in
                    let line = LineMark(
                        x: .value("X", point.x),
                        y: .value("Y", point.y)
                    )
                    .foregroundStyle(Color(.primary))
                    .interpolationMethod(.catmullRom)
                    
                    if points.count < 30 {
                        line.symbol(.circle)
                    } else {
                        line
                    }
                }
            }
        }
        .frame(height: 250)
        .chartXScale(
            domain: .automatic(includesZero: false),
            range: .plotDimension(startPadding: 20, endPadding: 0)
        )
        .chartYScale(
            domain: .automatic(includesZero: false),
            range: .plotDimension(startPadding: 20, endPadding: 20)
        )
        .chartYAxis {
            AxisMarks(format: .currency(code: "GBP").notation(.compactName))
        }
    }
}

struct Point: Identifiable, Equatable {
    let id = UUID()
    let x: Double
    let y: Decimal
}
