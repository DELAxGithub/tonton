//
//  NutritionBreakdownChart.swift
//  TonTon
//
//  Nutrition breakdown visualization using Swift Charts
//  Shows PFC (Protein, Fat, Carbs) balance with pie chart and details
//

import SwiftUI
import Charts
import SwiftData

struct NutritionBreakdownChart: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var mealRecords: [MealRecord]
    
    let timeRange: ChartTimeRange
    let showRecommendations: Bool
    
    init(timeRange: ChartTimeRange = .week, showRecommendations: Bool = true) {
        self.timeRange = timeRange
        self.showRecommendations = showRecommendations
    }
    
    private var filteredMeals: [MealRecord] {
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
        
        return mealRecords.filter { $0.consumedAt >= startDate }
    }
    
    private var nutritionSummary: NutritionSummary {
        let totalProtein = filteredMeals.map { $0.protein }.reduce(0, +)
        let totalFat = filteredMeals.map { $0.fat }.reduce(0, +)
        let totalCarbs = filteredMeals.map { $0.carbs }.reduce(0, +)
        let totalCalories = filteredMeals.map { $0.calories }.reduce(0, +)
        
        return NutritionSummary(
            protein: totalProtein,
            fat: totalFat,
            carbs: totalCarbs,
            totalCalories: totalCalories
        )
    }
    
    private var nutritionData: [NutritionData] {
        let summary = nutritionSummary
        let total = summary.protein + summary.fat + summary.carbs
        
        guard total > 0 else { return [] }
        
        return [
            NutritionData(
                name: "タンパク質",
                value: summary.protein,
                percentage: (summary.protein / total) * 100,
                color: .blue,
                calories: summary.protein * 4, // 1g = 4kcal
                icon: "figure.strengthtraining.traditional"
            ),
            NutritionData(
                name: "脂質",
                value: summary.fat,
                percentage: (summary.fat / total) * 100,
                color: .orange,
                calories: summary.fat * 9, // 1g = 9kcal
                icon: "drop"
            ),
            NutritionData(
                name: "炭水化物",
                value: summary.carbs,
                percentage: (summary.carbs / total) * 100,
                color: .green,
                calories: summary.carbs * 4, // 1g = 4kcal
                icon: "leaf"
            )
        ]
    }
    
    private var recommendedRanges: [String: ClosedRange<Double>] {
        [
            "タンパク質": 15...25,
            "脂質": 20...30,
            "炭水化物": 50...65
        ]
    }
    
    var body: some View {
        VStack(spacing: 16) {
            chartHeader
            
            if filteredMeals.isEmpty {
                emptyStateView
            } else {
                HStack(spacing: 20) {
                    // Pie chart
                    pieChartView
                    
                    // Nutrition details
                    nutritionDetailsView
                }
                
                if showRecommendations {
                    recommendationsView
                }
            }
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
                Text("栄養バランス")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text("PFC バランス")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(timeRange.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text("\(String(format: "%.0f", nutritionSummary.totalCalories))kcal")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.pie")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("栄養データがありません")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("食事を記録して栄養バランスを確認しましょう")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private var pieChartView: some View {
        Chart(nutritionData, id: \.name) { data in
            SectorMark(
                angle: .value("カロリー", data.calories),
                innerRadius: .ratio(0.4),
                angularInset: 2
            )
            .foregroundStyle(data.color)
            .opacity(0.8)
        }
        .frame(width: 120, height: 120)
        .overlay {
            VStack(spacing: 2) {
                Text("\(String(format: "%.0f", nutritionSummary.totalCalories))")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text("kcal")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private var nutritionDetailsView: some View {
        VStack(spacing: 12) {
            ForEach(nutritionData, id: \.name) { data in
                NutritionRow(
                    data: data,
                    recommendedRange: recommendedRanges[data.name]
                )
            }
        }
    }
    
    @ViewBuilder
    private var recommendationsView: some View {
        VStack(spacing: 12) {
            HStack {
                Text("推奨バランス")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
            }
            
            VStack(spacing: 8) {
                ForEach(nutritionData, id: \.name) { data in
                    if let range = recommendedRanges[data.name] {
                        RecommendationRow(
                            name: data.name,
                            current: data.percentage,
                            recommended: range,
                            color: data.color
                        )
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Supporting Types

struct NutritionSummary {
    let protein: Double
    let fat: Double
    let carbs: Double
    let totalCalories: Double
}

struct NutritionData {
    let name: String
    let value: Double
    let percentage: Double
    let color: Color
    let calories: Double
    let icon: String
}

struct NutritionRow: View {
    let data: NutritionData
    let recommendedRange: ClosedRange<Double>?
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: data.icon)
                .font(.title3)
                .foregroundColor(data.color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(data.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(String(format: "%.1f", data.value))g")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(String(format: "%.1f", data.percentage))%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(data.color)
                
                if let range = recommendedRange {
                    let isInRange = range.contains(data.percentage)
                    Text(isInRange ? "適正" : "要調整")
                        .font(.caption)
                        .foregroundColor(isInRange ? .green : .orange)
                }
            }
        }
    }
}

struct RecommendationRow: View {
    let name: String
    let current: Double
    let recommended: ClosedRange<Double>
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(name)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("推奨: \(String(format: "%.0f", recommended.lowerBound))-\(String(format: "%.0f", recommended.upperBound))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            SwiftUI.ProgressView(value: current / 100.0)
                .progressViewStyle(.linear)
                .tint(color)
                .overlay(alignment: .trailing) {
                    Text("\(String(format: "%.1f", current))%")
                        .font(.caption)
                        .foregroundColor(color)
                }
            
            // Recommended range indicator
            GeometryReader { geometry in
                let width = geometry.size.width
                let startX = width * (recommended.lowerBound / 100)
                let endX = width * (recommended.upperBound / 100)
                
                Rectangle()
                    .fill(color.opacity(0.3))
                    .frame(width: endX - startX, height: 2)
                    .offset(x: startX)
            }
            .frame(height: 2)
        }
    }
}

#Preview {
    NutritionBreakdownChart(
        timeRange: .week,
        showRecommendations: true
    )
    .modelContainer(for: [UserProfile.self, MealRecord.self, WeightRecord.self, CalorieSavingsRecord.self, DailySummary.self])
    .padding()
}