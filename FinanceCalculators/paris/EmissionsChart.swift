import SwiftUI
import Charts

import SwiftUI
import Charts

struct EmissionsChart: View {
    let points: [EmissionPoint]
    let targetValue: Double = 450.0

    var body: some View {
        Chart {
            // 1. The Paris Agreement Target Line
            RuleMark(y: .value("Paris Target", targetValue))
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                .foregroundStyle(.red)
                .annotation(position: .top, alignment: .trailing) {
                    Text("Paris Target")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }

            // 2. The Country's Actual Emissions
            ForEach(points) { point in
                LineMark(
                    x: .value("Year", point.x),
                    y: .value("CO2 (Mt)", Double(truncating: point.y as NSNumber))
                )
                .foregroundStyle(.blue)
                .interpolationMethod(.catmullRom)
                .symbol(.circle)
            }
        }
        // --- THE FIX IS HERE ---
        .chartXScale(domain: .automatic(includesZero: false))
        // -----------------------
        .chartYAxis {
            AxisMarks(position: .trailing)
        }
        .chartXAxis {
            // Now that the domain is ~2015-2024, stride(by: 1) will
            // only draw ~10 labels, removing the black smudge.
            AxisMarks(values: .stride(by: 1)) { value in
                AxisValueLabel(format: FloatingPointFormatStyle<Double>.number.grouping(.never))
            }
        }
        .frame(height: 250)
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
