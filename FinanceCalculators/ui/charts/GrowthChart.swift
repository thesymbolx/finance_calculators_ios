import Charts
import SwiftUI

struct GrowthChart: View {
    let points: [Point]
    
    private let xScaleDomainMax = 10.0
    
    // 1. State to track the line's vertical growth (0.0 = bottom, 1.0 = actual height)
    @State private var animationProgress: Double = 1.0

    // 2. Pre-calculate the explicit Y-domain to prevent the axes from collapsing
    private var yDomain: ClosedRange<Double> {
        guard !points.isEmpty else { return 0...1000 }
        let yValues = points.map { Double(truncating: $0.y as NSNumber) }
        let minVal = yValues.min() ?? 0
        let maxVal = yValues.max() ?? 1000
        // Ensure the range is valid even if all points have the same Y value
        return minVal < maxVal ? minVal...maxVal : (minVal - 10)...(maxVal + 10)
    }

    var body: some View {
        Chart {
            if points.isEmpty {
                RuleMark(y: .value("Y", 0)).foregroundStyle(.clear)
                RuleMark(y: .value("Y", 1000)).foregroundStyle(.clear)

                RuleMark(x: .value("X", 0)).foregroundStyle(.clear)
                RuleMark(x: .value("X", xScaleDomainMax)).foregroundStyle(.clear)
            } else {
                ForEach(points) { point in
                    let actualY = Double(truncating: point.y as NSNumber)
                    
                    // 3. Interpolate the Y value based on animation progress
                    // This anchors the line to the bottom of the current domain when progress is 0
                    let animatedY = yDomain.lowerBound + ((actualY - yDomain.lowerBound) * animationProgress)

                    let line = LineMark(
                        x: .value("X", point.x),
                        y: .value("Y", animatedY) // Use the animated value
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
                    let actualY = Double(truncating: point.y as NSNumber)
                    let animatedY = yDomain.lowerBound + ((actualY - yDomain.lowerBound) * animationProgress)

                    AreaMark(
                        x: .value("Year", point.x),
                        y: .value("Balance", animatedY) // Use the animated value
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
            domain: points.isEmpty ? 0...xScaleDomainMax : 0...(points.last?.x ?? xScaleDomainMax),
            range: .plotDimension(startPadding: 5, endPadding: 5)
        )
        // 4. Bind the Y-scale explicitly to our calculated domain
        .chartYScale(
            domain: points.isEmpty ? 0...1000 : yDomain,
            range: .plotDimension(startPadding: 0, endPadding: 10)
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
        // 5. Sequence the animation when points change (iOS 17+ syntax)
        .onChange(of: points) { oldValue, newValue in
            // Instantly flatten the line to the bottom of the graph
            animationProgress = 0.0
            
            // The chart's axes update automatically.
            // We wait 0.5 seconds for them to settle, then animate the line upward.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                    animationProgress = 1.0
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
