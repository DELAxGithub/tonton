//
//  ChartsContainerView.swift
//  TonTon
//
//  Container view for all charts with time range selection
//  Central hub for data visualization in TonTon
//

import SwiftUI
import SwiftData

struct ChartsContainerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]
    
    @State private var selectedTimeRange: ChartTimeRange = .month
    @State private var selectedChartType: ChartType = .weight
    
    private var currentUserProfile: UserProfile? {
        userProfiles.first
    }
    
    enum ChartType: String, CaseIterable {
        case weight = "weight"
        case savings = "savings"
        case nutrition = "nutrition"
        case overview = "overview"
        
        var displayName: String {
            switch self {
            case .weight: return "体重"
            case .savings: return "カロリー貯金"
            case .nutrition: return "栄養バランス"
            case .overview: return "概要"
            }
        }
        
        var icon: String {
            switch self {
            case .weight: return "scalemass"
            case .savings: return "chart.bar.fill"
            case .nutrition: return "chart.pie"
            case .overview: return "chart.xyaxis.line"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Time range selector
                timeRangeSelector
                
                // Chart type selector
                chartTypeSelector
                
                // Chart content
                ScrollView {
                    VStack(spacing: 16) {
                        switch selectedChartType {
                        case .weight:
                            weightChartSection
                        case .savings:
                            savingsChartSection
                        case .nutrition:
                            nutritionChartSection
                        case .overview:
                            overviewSection
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("データ分析")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    @ViewBuilder
    private var timeRangeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ChartTimeRange.allCases, id: \.self) { range in
                    Button(action: {
                        selectedTimeRange = range
                    }) {
                        Text(range.displayName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedTimeRange == range ? Color.accentColor : Color(.systemGray5))
                            )
                            .foregroundColor(selectedTimeRange == range ? .white : .primary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
    
    @ViewBuilder
    private var chartTypeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ChartType.allCases, id: \.self) { type in
                    Button(action: {
                        selectedChartType = type
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: type.icon)
                                .font(.caption)
                            
                            Text(type.displayName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedChartType == type ? Color.accentColor.opacity(0.2) : Color.clear)
                                .stroke(selectedChartType == type ? Color.accentColor : Color(.systemGray4), lineWidth: 1)
                        )
                        .foregroundColor(selectedChartType == type ? .accentColor : .primary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
    }
    
    @ViewBuilder
    private var weightChartSection: some View {
        WeightProgressChart(
            timeRange: selectedTimeRange,
            showTargetLine: true,
            targetWeight: currentUserProfile?.targetWeight
        )
    }
    
    @ViewBuilder
    private var savingsChartSection: some View {
        CalorieSavingsChart(
            timeRange: selectedTimeRange,
            showAverage: true
        )
    }
    
    @ViewBuilder
    private var nutritionChartSection: some View {
        NutritionBreakdownChart(
            timeRange: selectedTimeRange,
            showRecommendations: true
        )
    }
    
    @ViewBuilder
    private var overviewSection: some View {
        VStack(spacing: 16) {
            // Summary stats
            OverviewStatsCard(timeRange: selectedTimeRange)
            
            // Mini charts
            VStack(spacing: 12) {
                // Mini weight chart
                MiniChartCard(
                    title: "体重推移",
                    icon: "scalemass",
                    color: .blue
                ) {
                    WeightProgressChart(
                        timeRange: selectedTimeRange,
                        showTargetLine: false,
                        targetWeight: nil
                    )
                    .frame(height: 120)
                }
                
                // Mini savings chart
                MiniChartCard(
                    title: "カロリー貯金",
                    icon: "chart.bar.fill",
                    color: .green
                ) {
                    CalorieSavingsChart(
                        timeRange: selectedTimeRange,
                        showAverage: false
                    )
                    .frame(height: 120)
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct OverviewStatsCard: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var weightRecords: [WeightRecord]
    @Query private var savingsRecords: [CalorieSavingsRecord]
    @Query private var mealRecords: [MealRecord]
    @Query private var userProfiles: [UserProfile]
    
    let timeRange: ChartTimeRange
    
    private var currentUserProfile: UserProfile? {
        userProfiles.first
    }
    
    private var filteredData: (weight: [WeightRecord], savings: [CalorieSavingsRecord], meals: [MealRecord]) {
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
        
        return (
            weight: weightRecords.filter { $0.date >= startDate },
            savings: savingsRecords.filter { $0.date >= startDate },
            meals: mealRecords.filter { $0.consumedAt >= startDate }
        )
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("期間サマリー")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                let data = filteredData
                
                // Weight change
                if let firstWeight = data.weight.first?.weight,
                   let lastWeight = data.weight.last?.weight {
                    let change = lastWeight - firstWeight
                    
                    OverviewStatItem(
                        title: "体重変化",
                        value: "\(change >= 0 ? "+" : "")\(String(format: "%.1f", change))kg",
                        subtitle: "開始時から",
                        color: change <= 0 ? .green : .red,
                        icon: change <= 0 ? "arrow.down.circle" : "arrow.up.circle"
                    )
                }
                
                // Total savings
                let totalSavings = data.savings.map { $0.dailyBalance }.reduce(0, +)
                OverviewStatItem(
                    title: "総カロリー貯金",
                    value: "\(String(format: "%.0f", totalSavings))kcal",
                    subtitle: "\(data.savings.count)日間",
                    color: totalSavings >= 0 ? .green : .red,
                    icon: "chart.bar.fill"
                )
                
                // Meal count
                OverviewStatItem(
                    title: "記録した食事",
                    value: "\(data.meals.count)回",
                    subtitle: "合計カロリー",
                    color: .blue,
                    icon: "camera.on.rectangle"
                )
                
                // Average calories
                let avgCalories = data.meals.isEmpty ? 0 : data.meals.map { $0.calories }.reduce(0, +) / Double(data.meals.count)
                OverviewStatItem(
                    title: "1食平均",
                    value: "\(String(format: "%.0f", avgCalories))kcal",
                    subtitle: "カロリー",
                    color: .orange,
                    icon: "flame"
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

struct OverviewStatItem: View {
    let title: String
    let value: String
    let subtitle: String
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
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

struct MiniChartCard<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: () -> Content
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
            }
            
            content()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

#Preview {
    ChartsContainerView()
        .modelContainer(for: [UserProfile.self, MealRecord.self, WeightRecord.self, CalorieSavingsRecord.self, DailySummary.self])
}