//
//  ProgressView.swift
//  TonTon
//
//  Progress tracking screen with charts and statistics
//  Migrated from Flutter progress screens
//

import SwiftUI
import SwiftData
import Charts

struct ProgressView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var calorieSavingsRecords: [CalorieSavingsRecord]
    @Query private var weightRecords: [WeightRecord]
    @Query private var dailySummaries: [DailySummary]
    @Query private var userProfiles: [UserProfile]
    
    private var currentUserProfile: UserProfile? {
        userProfiles.first
    }
    
    @State private var selectedPeriod: TimePeriod = .week
    @State private var selectedTab: ProgressTab = .calories
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Period selector
                periodSelectorSection
                
                // Tab selector
                tabSelectorSection
                
                // Content based on selected tab
                ScrollView {
                    switch selectedTab {
                    case .calories:
                        calorieSavingsChartSection
                    case .weight:
                        weightChartSection
                    case .nutrition:
                        nutritionChartSection
                    }
                }
            }
            .navigationTitle("進捗")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    @ViewBuilder
    private var periodSelectorSection: some View {
        HStack(spacing: 16) {
            ForEach(TimePeriod.allCases, id: \.self) { period in
                Button(action: {
                    selectedPeriod = period
                }) {
                    Text(period.displayName)
                        .font(.subheadline)
                        .fontWeight(selectedPeriod == period ? .bold : .regular)
                        .foregroundColor(selectedPeriod == period ? .white : .primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(selectedPeriod == period ? Color.accentColor : Color(.systemGray6))
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 16)
    }
    
    @ViewBuilder
    private var tabSelectorSection: some View {
        HStack(spacing: 0) {
            ForEach(ProgressTab.allCases, id: \.self) { tab in
                Button(action: {
                    selectedTab = tab
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.title3)
                        Text(tab.displayName)
                            .font(.caption)
                    }
                    .foregroundColor(selectedTab == tab ? .accentColor : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .background(
            Rectangle()
                .fill(Color(.systemGray6))
                .frame(height: 1)
        )
        .padding(.bottom, 20)
    }
    
    @ViewBuilder
    private var calorieSavingsChartSection: some View {
        VStack(spacing: 20) {
            CalorieSavingsChart(
                timeRange: selectedPeriod.chartTimeRange,
                showAverage: true
            )
            .padding(.horizontal)
            
            // Statistics cards
            statisticsSection
        }
    }
    
    @ViewBuilder
    private var weightChartSection: some View {
        VStack(spacing: 20) {
            WeightProgressChart(
                timeRange: selectedPeriod.chartTimeRange,
                showTargetLine: true,
                targetWeight: currentUserProfile?.targetWeight
            )
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private var nutritionChartSection: some View {
        VStack(spacing: 20) {
            NutritionBreakdownChart(
                timeRange: selectedPeriod.chartTimeRange,
                showRecommendations: true
            )
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private var emptyChartPlaceholder: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("データがありません")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("食事や体重を記録すると、ここにグラフが表示されます")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(height: 200)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var statisticsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatisticCardView(
                title: "平均貯金",
                value: String(format: "%.0f", averageSavingsForPeriod),
                unit: "kcal/日",
                color: .green
            )
            
            StatisticCardView(
                title: "最大貯金",
                value: String(format: "%.0f", maxSavingsForPeriod),
                unit: "kcal",
                color: .blue
            )
            
            StatisticCardView(
                title: "記録日数",
                value: "\(recordingDaysCount)",
                unit: "日",
                color: .purple
            )
            
            StatisticCardView(
                title: "達成率",
                value: String(format: "%.0f", achievementRate),
                unit: "%",
                color: .orange
            )
        }
        .padding(.horizontal)
    }
    
    // MARK: - Computed Properties
    
    private var filteredCalorieSavings: [CalorieSavingsRecord] {
        let startDate = Calendar.current.date(byAdding: selectedPeriod.dateComponent, value: -selectedPeriod.value, to: Date()) ?? Date()
        return calorieSavingsRecords.filter { $0.date >= startDate }.sorted { $0.date < $1.date }
    }
    
    private var filteredWeightRecords: [WeightRecord] {
        let startDate = Calendar.current.date(byAdding: selectedPeriod.dateComponent, value: -selectedPeriod.value, to: Date()) ?? Date()
        return weightRecords.filter { $0.date >= startDate }.sorted { $0.date < $1.date }
    }
    
    private var totalSavingsForPeriod: Double? {
        let savings = filteredCalorieSavings
        return savings.isEmpty ? nil : savings.map(\.dailyBalance).reduce(0, +)
    }
    
    private var averageSavingsForPeriod: Double {
        let savings = filteredCalorieSavings
        return savings.isEmpty ? 0 : savings.map(\.dailyBalance).reduce(0, +) / Double(savings.count)
    }
    
    private var maxSavingsForPeriod: Double {
        filteredCalorieSavings.map(\.dailyBalance).max() ?? 0
    }
    
    private var recordingDaysCount: Int {
        filteredCalorieSavings.count
    }
    
    private var achievementRate: Double {
        let positiveCount = filteredCalorieSavings.filter { $0.dailyBalance > 0 }.count
        return filteredCalorieSavings.isEmpty ? 0 : (Double(positiveCount) / Double(filteredCalorieSavings.count)) * 100
    }
}

// MARK: - Supporting Types and Views

enum TimePeriod: CaseIterable {
    case week, month, threeMonths, year
    
    var displayName: String {
        switch self {
        case .week: return "1週間"
        case .month: return "1ヶ月"
        case .threeMonths: return "3ヶ月"
        case .year: return "1年"
        }
    }
    
    var dateComponent: Calendar.Component {
        switch self {
        case .week: return .day
        case .month: return .day
        case .threeMonths: return .day
        case .year: return .day
        }
    }
    
    var value: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .threeMonths: return 90
        case .year: return 365
        }
    }
    
    var chartTimeRange: ChartTimeRange {
        switch self {
        case .week: return .week
        case .month: return .month
        case .threeMonths: return .threeMonths
        case .year: return .year
        }
    }
}

enum ProgressTab: CaseIterable {
    case calories, weight, nutrition
    
    var displayName: String {
        switch self {
        case .calories: return "カロリー"
        case .weight: return "体重"
        case .nutrition: return "栄養"
        }
    }
    
    var icon: String {
        switch self {
        case .calories: return "flame"
        case .weight: return "scalemass"
        case .nutrition: return "chart.pie"
        }
    }
}

struct StatisticCardView: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(unit)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

#Preview {
    ProgressView()
        .modelContainer(for: [UserProfile.self, MealRecord.self, WeightRecord.self, CalorieSavingsRecord.self, DailySummary.self])
}