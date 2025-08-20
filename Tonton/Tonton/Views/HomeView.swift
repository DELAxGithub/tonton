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
    @State private var calculationService: CalorieCalculationService?
    @State private var dailyBalance: Double = 0
    @State private var totalSavings: Double = 0
    @State private var isCalculating = false
    
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
            .onAppear {
                Task {
                    await refreshData()
                }
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
            NavigationLink(destination: ProfileView()) {
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
                
                if isCalculating {
                    ProgressView()
                        .scaleEffect(0.8)
                } else if let savings = todaysCalorieSavings {
                    VStack(spacing: 4) {
                        Text(savings.formattedDailyBalance)
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(savings.hasSavings ? .green : .red)
                        
                        // Show category and emoji
                        HStack {
                            Text(savings.savingsCategory.emoji)
                            Text(savings.motivationalMessage)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                } else {
                    VStack(spacing: 4) {
                        Text(dailyBalance >= 0 ? "+\(Int(dailyBalance)) kcal" : "\(Int(dailyBalance)) kcal")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(dailyBalance >= 0 ? .green : .red)
                        
                        Text("計算中...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Total savings display
            if totalSavings != 0 {
                VStack(spacing: 4) {
                    Text("累積貯金")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(totalSavings >= 0 ? "+\(Int(totalSavings)) kcal" : "\(Int(totalSavings)) kcal")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(totalSavings >= 0 ? .green : .red)
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
                
                if let profile = currentUserProfile,
                   let bmr = profile.calculateBMR() {
                    Text("BMR: \(String(format: "%.0f", bmr)) kcal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                // Calories consumed
                StatCardView(
                    title: "摂取",
                    value: String(format: "%.0f", todaysDailySummary?.caloriesConsumed ?? 0.0),
                    unit: "kcal",
                    color: .orange
                )
                
                // Calories burned
                StatCardView(
                    title: "消費",
                    value: String(format: "%.0f", todaysDailySummary?.caloriesBurned ?? 0.0),
                    unit: "kcal", 
                    color: .blue
                )
                
                // Efficiency percentage
                if let savings = todaysCalorieSavings,
                   let profile = currentUserProfile,
                   let targetSavings = profile.calculateTargetSavings() {
                    let efficiency = savings.savingsEfficiency(targetSavings: targetSavings)
                    StatCardView(
                        title: "効率",
                        value: String(format: "%.0f", efficiency),
                        unit: "%",
                        color: efficiency >= 80 ? .green : efficiency >= 60 ? .orange : .red
                    )
                }
            }
            
            // Additional insights row
            if let savings = todaysCalorieSavings {
                HStack(spacing: 12) {
                    VStack {
                        Text("カテゴリ")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(savings.savingsCategory.emoji)
                            .font(.title2)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("予想体重変化")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(savings.estimatedWeightImpact >= 0 ? 
                             "+\(String(format: "%.3f", savings.estimatedWeightImpact))kg" :
                             "\(String(format: "%.3f", savings.estimatedWeightImpact))kg")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(savings.estimatedWeightImpact >= 0 ? .green : .red)
                    }
                    
                    Spacer()
                }
                .padding(.top, 8)
            }
        }
    }
    
    // Removed quick actions section as requested in issue
    // User specifically mentioned: "ここのクイックアクションはもう表示を切っちゃっていいです"
    
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
                            .foregroundColor(Color.blue)
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
                            .foregroundColor(Color.green)
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
        isCalculating = true
        
        do {
            // Initialize calculation service if needed
            if calculationService == nil {
                calculationService = CalorieCalculationService(modelContext: modelContext)
            }
            
            guard let service = calculationService else { return }
            
            // Update user goal if profile exists
            if let profile = currentUserProfile {
                service.updateDailyGoal(for: profile)
            }
            
            // Calculate and save today's savings
            let savingsRecord = try await service.calculateAndSaveDailySavings()
            
            // Update state variables
            dailyBalance = savingsRecord.dailyBalance
            totalSavings = await service.getCumulativeSavings(upTo: Date())
            
        } catch {
            print("Error refreshing data: \(error)")
        }
        
        isCalculating = false
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