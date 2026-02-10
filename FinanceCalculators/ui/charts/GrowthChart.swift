import Charts
import SwiftUI

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

                ForEach(points) { point in
                    AreaMark(
                        x: .value("Year", point.x),
                        y: .value(
                            "Balance",
                            Double(truncating: point.y as NSNumber)
                        )
                    )
                    .interpolationMethod(.monotone)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(.primary).opacity(0.2),
                                Color(.primary).opacity(0.0),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
        }
        .frame(height: 250)
        .chartXScale(
            domain: .automatic(includesZero: false),
            range: .plotDimension(startPadding: 10, endPadding: 0)
        )
        .chartXAxis {
            AxisMarks(values: .stride(by: 2)) { value in
                AxisValueLabel()
                AxisGridLine()
            }
        }
        .chartYScale(
            domain: .automatic(includesZero: false),
            range: .plotDimension(startPadding: 0, endPadding: 10)
        )
        .chartYAxis {

            AxisMarks() { value in
                AxisValueLabel(
                    format: .currency(code: "GBP").precision(.fractionLength(0))
                )

                if let doubleValue = value.as(Double.self), doubleValue == 0 {
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1))
                        .foregroundStyle(.gray.opacity(0.5))  // Optional: makes the 0 line subtle
                }
            }

        }
    }
}

struct Point: Identifiable, Equatable {
    let id = UUID()
    let x: Double
    let y: Decimal
}
