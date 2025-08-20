//
//  WeightProgressChart.swift
//  TonTon
//
//  Weight progress visualization using Swift Charts
//  Migrated from Flutter fl_chart implementation
//

import SwiftUI
import Charts
import SwiftData

struct WeightProgressChart: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WeightRecord.date) private var weightRecords: [WeightRecord]
    
    let timeRange: ChartTimeRange
    let showTargetLine: Bool
    let targetWeight: Double?
    
    init(timeRange: ChartTimeRange = .month, 
         showTargetLine: Bool = true, 
         targetWeight: Double? = nil) {
        self.timeRange = timeRange
        self.showTargetLine = showTargetLine
        self.targetWeight = targetWeight
    }
    
    private var filteredRecords: [WeightRecord] {
        let now = Date()
        let startDate: Date
        
        switch timeRange {
        case .week:
            startDate = Calendar.current.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            startDate = Calendar.current.date(byAdding: .month, value: -1, to: now) ?? now
        case .threeMonths:
            startDate = Calendar.current.date(byAdding: .month, value: -3, to: now) ?? now
        case .sixMonths:
            startDate = Calendar.current.date(byAdding: .month, value: -6, to: now) ?? now
        case .year:
            startDate = Calendar.current.date(byAdding: .year, value: -1, to: now) ?? now
        }
        
        return weightRecords.filter { $0.date >= startDate }
    }
    
    private var weightRange: (min: Double, max: Double) {
        guard !filteredRecords.isEmpty else { return (0, 100) }
        
        let weights = filteredRecords.map { $0.weight }
        let minWeight = weights.min() ?? 0
        let maxWeight = weights.max() ?? 100
        
        // Add some padding to make the chart more readable
        let padding = (maxWeight - minWeight) * 0.1
        let adjustedMin = max(0, minWeight - padding)
        let adjustedMax = maxWeight + padding
        
        // Include target weight in range if shown
        if showTargetLine, let target = targetWeight {
            return (min(adjustedMin, target - padding), max(adjustedMax, target + padding))
        }
        
        return (adjustedMin, adjustedMax)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            chartHeader
            
            if filteredRecords.isEmpty {
                emptyStateView
            } else {
                chartView
            }
            
            chartLegend
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    @ViewBuilder
    private var chartHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("体重の推移")
                    .font(.headline)
                    .fontWeight(.bold)
                
                if let latest = filteredRecords.last {
                    HStack {
                        Text("\(String(format: "%.1f", latest.weight)) kg")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.blue)
                        
                        if filteredRecords.count > 1 {
                            let previous = filteredRecords[filteredRecords.count - 2]
                            let change = latest.weight - previous.weight
                            
                            HStack(spacing: 4) {
                                Image(systemName: change >= 0 ? "arrow.up" : "arrow.down")
                                    .font(.caption)
                                Text("\(change >= 0 ? "+" : "")\(String(format: "%.1f", change)) kg")
                                    .font(.caption)
                            }
                            .foregroundColor(change >= 0 ? .red : .green)
                        }
                    }
                }
            }
            
            Spacer()
            
            timeRangeInfo
        }
    }
    
    @ViewBuilder
    private var timeRangeInfo: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(timeRange.displayName)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            if !filteredRecords.isEmpty {
                Text("\(filteredRecords.count)記録")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "scalemass")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("体重記録がありません")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("体重を記録して進捗を確認しましょう")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private var chartView: some View {
        Chart {
            // Weight data line
            ForEach(filteredRecords, id: \.id) { record in
                LineMark(
                    x: .value("日付", record.date, unit: .day),
                    y: .value("体重", record.weight)
                )
                .foregroundStyle(.blue)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                
                PointMark(
                    x: .value("日付", record.date, unit: .day),
                    y: .value("体重", record.weight)
                )
                .foregroundStyle(.blue)
                .symbolSize(36)
            }
            
            // Target weight line
            if showTargetLine, let target = targetWeight {
                RuleMark(y: .value("目標体重", target))
                    .foregroundStyle(.green)
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                    .annotation(position: .trailing, alignment: .leading) {
                        Text("目標: \(String(format: "%.1f", target)) kg")
                            .font(.caption)
                            .foregroundColor(Color.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(.green.opacity(0.1))
                            )
                    }
            }
            
            // Trend line (if enough data points)
            if filteredRecords.count >= 3 {
                let trendLine = calculateTrendLine()
                ForEach(Array(trendLine.enumerated()), id: \.offset) { index, point in
                    LineMark(
                        x: .value("日付", point.date),
                        y: .value("トレンド", point.weight)
                    )
                    .foregroundStyle(.orange.opacity(0.7))
                    .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, dash: [3, 3]))
                }
            }
        }
        .frame(height: 250)
        .chartYScale(domain: weightRange.min...weightRange.max)
        .chartXAxis {
            AxisMarks(values: .stride(by: timeRange.axisStride)) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(formatAxisDate(date))
                            .font(.caption)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel {
                    if let weight = value.as(Double.self) {
                        Text("\(String(format: "%.0f", weight)) kg")
                            .font(.caption)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var chartLegend: some View {
        HStack(spacing: 20) {
            LegendItem(color: .blue, label: "実際の体重", style: .solid)
            
            if showTargetLine && targetWeight != nil {
                LegendItem(color: .green, label: "目標体重", style: .dashed)
            }
            
            if filteredRecords.count >= 3 {
                LegendItem(color: .orange, label: "トレンド", style: .dashed)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatAxisDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        switch timeRange {
        case .week:
            formatter.dateFormat = "M/d"
        case .month:
            formatter.dateFormat = "M/d"
        case .threeMonths, .sixMonths:
            formatter.dateFormat = "M/d"
        case .year:
            formatter.dateFormat = "M月"
        }
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    private func calculateTrendLine() -> [(date: Date, weight: Double)] {
        guard filteredRecords.count >= 2 else { return [] }
        
        // Simple linear regression
        let n = Double(filteredRecords.count)
        let xValues = filteredRecords.enumerated().map { Double($0.offset) }
        let yValues = filteredRecords.map { $0.weight }
        
        let sumX = xValues.reduce(0, +)
        let sumY = yValues.reduce(0, +)
        let sumXY = zip(xValues, yValues).map(*).reduce(0, +)
        let sumXX = xValues.map { $0 * $0 }.reduce(0, +)
        
        let slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX)
        let intercept = (sumY - slope * sumX) / n
        
        return filteredRecords.enumerated().map { index, record in
            let trendWeight = intercept + slope * Double(index)
            return (date: record.date, weight: trendWeight)
        }
    }
}

// MARK: - Supporting Types

struct LegendItem: View {
    let color: Color
    let label: String
    let style: LineStyle
    
    enum LineStyle {
        case solid
        case dashed
    }
    
    var body: some View {
        HStack(spacing: 6) {
            Rectangle()
                .fill(color)
                .frame(width: 16, height: 2)
                .overlay(
                    Rectangle()
                        .stroke(color, style: StrokeStyle(
                            lineWidth: 2,
                            dash: style == .dashed ? [3, 3] : []
                        ))
                )
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    WeightProgressChart(
        timeRange: .month,
        showTargetLine: true,
        targetWeight: 65.0
    )
    .modelContainer(for: [UserProfile.self, MealRecord.self, WeightRecord.self, CalorieSavingsRecord.self, DailySummary.self])
    .padding()
}