import SwiftUI
import Charts

import SwiftUI
import Charts

struct EmissionsChart: View {
    let points: [EmissionPoint]
    let targetValue: Double = 450.0
    
    // MARK: - Hardcoded Selection
    // We manually select the 2023 data point to simulate a user press
    var selectedPoint: EmissionPoint? {
        points.first { $0.x == 2023 }
    }

    var body: some View {
        VStack(alignment: .leading) {
            
            // 1. Header: Hardcoded to show the "Active" state
            // This simulates what the user sees while dragging
            if let selected = selectedPoint {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Year 2023")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                                        
                    HStack(alignment: .firstTextBaseline) {
                        Text("\(selected.y as NSDecimalNumber)")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                        
                        Text("Mt CO2")
                            .font(.subheadline.bold())
                            .foregroundStyle(.secondary)
                        
                        // Added context pill for the screenshot
                        Text("60 Above Target")
                            .font(.caption2.bold())
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.15))
                            .foregroundStyle(.orange)
                            .clipShape(Capsule())
                    }
                }
            }
           

            Chart {
                // 2. The Paris Agreement Target Line
                RuleMark(y: .value("Paris Target", targetValue))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                    .foregroundStyle(.red)
                    .annotation(position: .bottom, alignment: .trailing) {
                        Text("Paris Goal (450)")
                            .font(.caption2.bold())
                            .foregroundStyle(.red)
                            .padding(4)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(4)
                    }

                // 3. Area Gradient (Visual Polish)
                ForEach(points) { point in
                    AreaMark(
                        x: .value("Year", point.x),
                        y: .value("CO2 (Mt)", Double(truncating: point.y as NSNumber))
                    )
                    .interpolationMethod(.monotone)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue.opacity(0.2), .blue.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }

                // 4. Main Line
                ForEach(points) { point in
                    LineMark(
                        x: .value("Year", point.x),
                        y: .value("CO2 (Mt)", Double(truncating: point.y as NSNumber))
                    )
                    .foregroundStyle(.blue)
                    .interpolationMethod(.monotone)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    .symbol(.circle)
                    .symbolSize(80)
                }

                // 5. Hardcoded Selection Indicator (The Scrubber)
                if let selected = selectedPoint {
                   
                    
                    PointMark(
                        x: .value("Selected Year", selected.x),
                        y: .value("Value", Double(truncating: selected.y as NSNumber))
                    )
                    .foregroundStyle(.white)
                    .symbolSize(150) // Larger size for emphasis
                    .annotation(position: .overlay) {
                        // Ring effect around the dot
                        Circle()
                            .stroke(Color.blue, lineWidth: 3)
                            .frame(width: 14, height: 14)
                    }
                }
            }
            .chartXScale(domain: .automatic(includesZero: false))
            .chartYAxis {
                AxisMarks(position: .trailing, values: .automatic(desiredCount: 5))
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: 1)) { value in
                    if let year = value.as(Double.self), year == selectedPoint?.x {
                        // Bold the selected year on the axis
                        AxisValueLabel {
                            Text(String(format: "%.0f", year))
                                .bold()
                                .foregroundStyle(.blue)
                        }
                    } else {
                        AxisValueLabel(format: FloatingPointFormatStyle<Double>.number.grouping(.never))
                    }
                }
            }
            .frame(height: 280)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
}

struct EmissionPoint: Identifiable, Equatable {
    let id = UUID()
    let x: Double
    let y: Decimal
}

// Sample data for a country (e.g., 2015 - 2024)
let stubbedEmissions: [EmissionPoint] = [
    EmissionPoint(x: 2015, y: 700),
    EmissionPoint(x: 2016, y: 680),
    EmissionPoint(x: 2017, y: 690),
    EmissionPoint(x: 2018, y: 650),
    EmissionPoint(x: 2019, y: 610),
    EmissionPoint(x: 2020, y: 520), // Drop due to pandemic
    EmissionPoint(x: 2021, y: 580),
    EmissionPoint(x: 2022, y: 550),
    EmissionPoint(x: 2023, y: 510),
    EmissionPoint(x: 2024, y: 490)
]
