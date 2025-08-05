//
//  HomeView.swift
//  TonTon
//
//  Main home screen showing daily calorie savings and progress
//  Migrated from Flutter HomeScreen
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]
    @Query private var todaysSummary: [DailySummary]
    @Query private var calorieSavingsRecords: [CalorieSavingsRecord]
    @State private var showingBugReport = false
    
    private var currentUserProfile: UserProfile? {
        userProfiles.first
    }
    
    private var todaysDailySummary: DailySummary? {
        todaysSummary.first { Calendar.current.isDateInToday($0.date) }
    }
    
    private var todaysCalorieSavings: CalorieSavingsRecord? {
        calorieSavingsRecords.first { Calendar.current.isDateInToday($0.date) }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header section
                    headerSection
                    
                    // Main calorie savings display (Hero section)
                    calorieSavingsHeroSection
                    
                    // Daily stats section
                    dailyStatsSection
                    
                    // Quick actions section
                    quickActionsSection
                    
                    // Mini charts section
                    miniChartsSection
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
            }
            .navigationTitle("TonTon")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await refreshData()
            }
            .sheet(isPresented: $showingBugReport) {
                TonTonBugReportView(
                    currentScreen: "HomeView",
                    healthContext: createHealthContext(),
                    mealLoggingContext: nil
                )
            }
        }
    }
    
    @ViewBuilder
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading) {
                if let profile = currentUserProfile, let displayName = profile.displayName {
                    Text("こんにちは、\(displayName)さん")
                        .font(.title2)
                        .fontWeight(.medium)
                } else {
                    Text("こんにちは")
                        .font(.title2)
                        .fontWeight(.medium)
                }
                
                Text("今日のカロリー貯金")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Profile image or icon
            Button(action: {
                // Navigate to profile
            }) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.title)
                    .foregroundColor(.accentColor)
            }
        }
        .padding(.top)
    }
    
    @ViewBuilder
    private var calorieSavingsHeroSection: some View {
        VStack(spacing: 16) {
            // Main savings display
            VStack(spacing: 8) {
                Text("今日の貯金")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                if let savings = todaysCalorieSavings {
                    Text(savings.formattedDailyBalance)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(savings.hasSavings ? .green : .red)
                } else {
                    Text("+0 kcal")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            
            // Piggy bank illustration placeholder
            Image(systemName: "creditcard.fill")
                .font(.system(size: 60))
                .foregroundColor(.pink)
                .background(
                    Circle()
                        .fill(Color.pink.opacity(0.1))
                        .frame(width: 120, height: 120)
                )
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    @ViewBuilder
    private var dailyStatsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("今日の詳細")
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 16) {
                // Calories consumed
                StatCardView(
                    title: "摂取",
                    value: String(format: "%.0f", todaysDailySummary?.caloriesConsumed ?? 0),
                    unit: "kcal",
                    color: .orange
                )
                
                // Calories burned
                StatCardView(
                    title: "消費",
                    value: String(format: "%.0f", todaysDailySummary?.caloriesBurned ?? 0),
                    unit: "kcal", 
                    color: .blue
                )
                
                // Weight (if available)
                if let weight = todaysDailySummary?.weight {
                    StatCardView(
                        title: "体重",
                        value: String(format: "%.1f", weight),
                        unit: "kg",
                        color: .purple
                    )
                }
            }
        }
    }
    
    @ViewBuilder
    private var quickActionsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("クイックアクション")
                    .font(.headline)
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                QuickActionButton(
                    title: "食事を記録",
                    icon: "camera.fill",
                    color: .green
                ) {
                    // Navigate to meal logging
                }
                
                QuickActionButton(
                    title: "体重を記録",
                    icon: "scalemass.fill",
                    color: .blue
                ) {
                    // Navigate to weight logging
                }
                
                QuickActionButton(
                    title: "進捗を確認",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .purple
                ) {
                    // Navigate to progress
                }
                
                QuickActionButton(
                    title: "設定",
                    icon: "gearshape.fill",
                    color: .gray
                ) {
                    // Navigate to settings
                }
            }
        }
    }
    
    @ViewBuilder
    private var miniChartsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("最近の推移")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                
                NavigationLink("詳細", destination: ChartsContainerView())
                    .font(.subheadline)
                    .foregroundColor(.accentColor)
            }
            
            VStack(spacing: 12) {
                // Mini weight chart
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "scalemass")
                            .foregroundColor(.blue)
                        Text("体重推移（1週間）")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    
                    WeightProgressChart(
                        timeRange: .week,
                        showTargetLine: false,
                        targetWeight: nil
                    )
                    .frame(height: 100)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                )
                
                // Mini savings chart  
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(.green)
                        Text("カロリー貯金（1週間）")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    
                    CalorieSavingsChart(
                        timeRange: .week,
                        showAverage: false
                    )
                    .frame(height: 100)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                )
            }
        }
    }
    
    private func refreshData() async {
        // Implement data refresh logic
        // This would typically fetch from HealthKit and update summaries
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay for demo
    }
    
    private func createHealthContext() -> HealthKitContext? {
        // Create health context for bug reporting
        let profile = currentUserProfile
        let lastWeightRecord = profile?.lastWeightDate
        
        return HealthKitContext(
            healthKitPermissions: ["体重", "歩数", "消費カロリー"], // TODO: Get actual permissions
            lastSyncDate: Date(), // TODO: Get actual last sync date
            syncStatus: "同期済み", // TODO: Get actual sync status
            availableDataTypes: ["weight", "steps", "calories"],
            lastWeightRecord: lastWeightRecord,
            calorieGoal: profile?.calorieGoal
        )
    }
}

// MARK: - Supporting Views

struct StatCardView: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(unit)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

// Note: QuickActionButton is defined in Views/Components/SettingsComponents.swift

#Preview {
    HomeView()
        .modelContainer(for: [UserProfile.self, MealRecord.self, WeightRecord.self, CalorieSavingsRecord.self, DailySummary.self])
}