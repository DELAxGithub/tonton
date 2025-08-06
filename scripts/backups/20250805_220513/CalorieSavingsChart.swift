//
//  CalorieSavingsChart.swift
//  TonTon
//
//  Calorie savings visualization using Swift Charts
//  Shows daily calorie savings progress with bar chart
//

import SwiftUI
import Charts
import SwiftData

struct CalorieSavingsChart: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CalorieSavingsRecord.date) private var savingsRecords: [CalorieSavingsRecord]
    
    let timeRange: ChartTimeRange
    let showAverage: Bool
    
    init(timeRange: ChartTimeRange = .month, showAverage: Bool = true) {
        self.timeRange = timeRange
        self.showAverage = showAverage
    }
    
    private var filteredRecords: [CalorieSavingsRecord] {
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
        
        return savingsRecords.filter { $0.date >= startDate }
    }
    
    private var averageSavings: Double {
        guard !filteredRecords.isEmpty else { return 0 }
        return filteredRecords.map { $0.dailyBalance }.reduce(0, +) / Double(filteredRecords.count)
    }
    
    private var totalSavings: Double {
        filteredRecords.map { $0.dailyBalance }.reduce(0, +)
    }
    
    private var savingsRange: (min: Double, max: Double) {
        guard !filteredRecords.isEmpty else { return (-500, 500) }
        
        let savings = filteredRecords.map { $0.dailyBalance }
        let minSaving = savings.min() ?? 0
        let maxSaving = savings.max() ?? 0
        
        // Add some padding and ensure range includes zero
        let padding = max(abs(minSaving), abs(maxSaving)) * 0.1
        let adjustedMin = min(minSaving - padding, -padding)
        let adjustedMax = max(maxSaving + padding, padding)
        
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
            
            summaryStats
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
                Text("カロリー貯金")
                    .font(.headline)
                    .fontWeight(.bold)
                
                if let latest = filteredRecords.last {
                    HStack {
                        Text("\(String(format: "%.0f", latest.dailyBalance))kcal")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(latest.dailyBalance >= 0 ? .green : .red)
                        
                        Text(latest.dailyBalance >= 0 ? "貯金" : "オーバー")
                            .font(.caption)
                            .foregroundColor(latest.dailyBalance >= 0 ? .green : .red)
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
                Text("合計: \(String(format: "%.0f", totalSavings))kcal")
                    .font(.caption)
                    .foregroundColor(totalSavings >= 0 ? .green : .red)
            }
        }
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("カロリー貯金記録がありません")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("食事を記録してカロリー貯金を始めましょう")
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
            // Calorie savings bars
            ForEach(filteredRecords, id: \.id) { record in
                BarMark(
                    x: .value("日付", record.date),
                    y: .value("貯金", record.dailyBalance)
                )
                .foregroundStyle(record.dailyBalance >= 0 ? .green : .red)
                .opacity(0.8)
            }
            
            // Zero line
            RuleMark(y: .value("ゼロライン", 0))
                .foregroundStyle(.gray)
                .lineStyle(StrokeStyle(lineWidth: 1))
            
            // Average line
            if showAverage && !filteredRecords.isEmpty {
                RuleMark(y: .value("平均", averageSavings))
                    .foregroundStyle(.blue)
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                    .annotation(position: .trailing, alignment: .leading) {
                        Text("平均: \(String(format: "%.0f", averageSavings))kcal")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(.blue.opacity(0.1))
                            )
                    }
            }
        }
        .frame(height: 250)
        .chartYScale(domain: savingsRange.min...savingsRange.max)
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
                    if let calories = value.as(Double.self) {
                        Text("\(String(format: "%.0f", calories))")
                            .font(.caption)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var summaryStats: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatCard(
                title: "総貯金",
                value: "\(String(format: "%.0f", totalSavings))kcal",
                color: totalSavings >= 0 ? .green : .red,
                icon: "plus.circle.fill"
            )
            
            StatCard(
                title: "1日平均",
                value: "\(String(format: "%.0f", averageSavings))kcal",
                color: averageSavings >= 0 ? .green : .red,
                icon: "chart.line.uptrend.xyaxis"
            )
            
            StatCard(
                title: "成功日数",
                value: "\(successfulDays)/\(filteredRecords.count)日",
                color: .blue,
                icon: "checkmark.circle.fill"
            )
        }
    }
    
    private var successfulDays: Int {
        filteredRecords.filter { $0.dailyBalance >= 0 }.count
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
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
        )
    }
}

#Preview {
    CalorieSavingsChart(
        timeRange: .month,
        showAverage: true
    )
    .modelContainer(for: [UserProfile.self, MealRecord.self, WeightRecord.self, CalorieSavingsRecord.self, DailySummary.self])
    .padding()
}