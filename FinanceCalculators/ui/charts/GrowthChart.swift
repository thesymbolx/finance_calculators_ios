import Charts
import SwiftUI

struct GrowthChart: View {
    let points: [Point]

    private let xScaleDomainMax = 10.0
    @State private var revealProgress: CGFloat = 1.0
    @State private var selectedX: Double?

    var body: some View {
        Chart {
            if points.isEmpty {
                RuleMark(y: .value("Y", 0)).foregroundStyle(.clear)
                RuleMark(y: .value("Y", 1000)).foregroundStyle(.clear)

                RuleMark(x: .value("X", 0)).foregroundStyle(.clear)
                RuleMark(x: .value("X", xScaleDomainMax)).foregroundStyle(
                    .clear
                )
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

                if let selectedX {
                    if let closest = points.min(by: { abs($0.x - selectedX) < abs($1.x - selectedX) }) {
                        PointMark(
                            x: .value("X", closest.x),
                            y: .value("Y", closest.y)
                        )
                        .foregroundStyle(Color(.primary))
                        .symbolSize(100)
                    }
                }
            }
        }
        .frame(height: 250)
        .onChange(of: points) { oldValue, newValue in
            revealProgress = 0.0

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    revealProgress = 1.0
                }
            }
        }
        .chartXSelection(value: $selectedX)
        .chartXScale(
            domain: points.isEmpty
                ? 0...xScaleDomainMax : 0...(points.last?.x ?? xScaleDomainMax),
            range: .plotDimension(startPadding: 5, endPadding: 5)
        )
        .chartYScale(
            domain: .automatic(includesZero: false),
            range: .plotDimension(startPadding: 5, endPadding: 5)
        )
        .chartYAxis {
            AxisMarks { value in
                AxisValueLabel(
                    format: .currency(code: "GBP").notation(.compactName)
                )

                if let doubleValue = value.as(Double.self), doubleValue == 0 {
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1))
                        .foregroundStyle(.gray.opacity(0.5))
                }
            }

        }
        .chartPlotStyle { plotArea in
            plotArea
                .mask(alignment: .leading) {
                    Rectangle()
                        .scaleEffect(x: revealProgress, anchor: .leading)
                }
        }
        .animation(.none, value: points)
    }
}

struct Point: Identifiable, Equatable {
    let id = UUID()
    let x: Double
    let y: Decimal
}
