//
//  CalorieCalculationService.swift
//  TonTon
//
//  Core calorie calculation service for savings logic
//  Migrated from Flutter CalorieCalculationService
//

import Foundation
import SwiftData

@MainActor
class CalorieCalculationService: ObservableObject {
    private let modelContext: ModelContext
    
    @Published var dailyGoal: Double = 0
    @Published var currentBalance: Double = 0
    @Published var totalSavings: Double = 0
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Daily Calculations
    
    /// Calculate daily calorie balance (burned - consumed)
    func calculateDailyBalance(for date: Date = Date()) async -> Double {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // Get meals for the day
        let mealDescriptor = FetchDescriptor<MealRecord>(
            predicate: #Predicate<MealRecord> { meal in
                meal.consumedAt >= startOfDay && meal.consumedAt < endOfDay
            }
        )
        
        let meals = try? modelContext.fetch(mealDescriptor)
        let totalConsumed = meals?.reduce(0) { $0 + $1.calories } ?? 0
        
        // Get calories burned from HealthKit via DailySummary
        let summaryDescriptor = FetchDescriptor<DailySummary>(
            predicate: #Predicate<DailySummary> { summary in
                summary.date >= startOfDay && summary.date < endOfDay
            }
        )
        
        let summaries = try? modelContext.fetch(summaryDescriptor)
        let totalBurned = summaries?.first?.caloriesBurned ?? 0
        
        return totalBurned - totalConsumed
    }
    
    /// Update or create daily summary for a specific date
    func updateDailySummary(for date: Date = Date()) async throws {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // Fetch existing summary or create new one
        let summaryDescriptor = FetchDescriptor<DailySummary>(
            predicate: #Predicate<DailySummary> { summary in
                summary.date >= startOfDay && summary.date < endOfDay
            }
        )
        
        let existingSummaries = try modelContext.fetch(summaryDescriptor)
        let dailySummary = existingSummaries.first ?? DailySummary(date: startOfDay)
        
        if existingSummaries.isEmpty {
            modelContext.insert(dailySummary)
        }
        
        // Calculate consumed calories from meals
        let mealDescriptor = FetchDescriptor<MealRecord>(
            predicate: #Predicate<MealRecord> { meal in
                meal.consumedAt >= startOfDay && meal.consumedAt < endOfDay
            }
        )
        
        let meals = try modelContext.fetch(mealDescriptor)
        dailySummary.caloriesConsumed = meals.reduce(0) { $0 + $1.calories }
        
        // Get user profile for BMR calculation
        let profileDescriptor = FetchDescriptor<UserProfile>()
        let profiles = try modelContext.fetch(profileDescriptor)
        if let profile = profiles.first,
           let bmr = profile.calculateBMR() {
            dailySummary.basalCalories = bmr
        }
        
        dailySummary.updatedAt = Date()
        try modelContext.save()
    }
    
    /// Calculate and update calorie savings record
    func calculateAndSaveDailySavings(for date: Date = Date()) async throws -> CalorieSavingsRecord {
        // Ensure daily summary is up to date
        try await updateDailySummary(for: date)
        
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // Get daily summary
        let summaryDescriptor = FetchDescriptor<DailySummary>(
            predicate: #Predicate<DailySummary> { summary in
                summary.date >= startOfDay && summary.date < endOfDay
            }
        )
        
        let summaries = try modelContext.fetch(summaryDescriptor)
        guard let summary = summaries.first else {
            throw CalorieCalculationError.summaryNotFound
        }
        
        // Calculate total burned (basal + active)
        let totalBurned = summary.basalCalories + (summary.caloriesBurned - summary.basalCalories)
        let totalConsumed = summary.caloriesConsumed
        let dailyBalance = totalBurned - totalConsumed
        
        // Get previous cumulative savings
        let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: date)!
        let previousSavings = await getCumulativeSavings(upTo: previousDate)
        
        // Check if savings record already exists
        let savingsDescriptor = FetchDescriptor<CalorieSavingsRecord>(
            predicate: #Predicate<CalorieSavingsRecord> { record in
                record.date >= startOfDay && record.date < endOfDay
            }
        )
        
        let existingRecords = try modelContext.fetch(savingsDescriptor)
        let savingsRecord = existingRecords.first ?? CalorieSavingsRecord(
            date: startOfDay,
            caloriesConsumed: totalConsumed,
            caloriesBurned: totalBurned,
            dailyBalance: dailyBalance,
            cumulativeSavings: previousSavings + dailyBalance
        )
        
        if existingRecords.isEmpty {
            modelContext.insert(savingsRecord)
        } else {
            savingsRecord.updateCalories(
                consumed: totalConsumed,
                burned: totalBurned,
                previousCumulativeSavings: previousSavings
            )
        }
        
        try modelContext.save()
        
        // Update published properties
        currentBalance = dailyBalance
        totalSavings = savingsRecord.cumulativeSavings
        
        return savingsRecord
    }
    
    // MARK: - Cumulative Calculations
    
    /// Get cumulative savings up to a specific date
    func getCumulativeSavings(upTo date: Date) async -> Double {
        let descriptor = FetchDescriptor<CalorieSavingsRecord>(
            predicate: #Predicate<CalorieSavingsRecord> { record in
                record.date <= date
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        do {
            let records = try modelContext.fetch(descriptor)
            return records.first?.cumulativeSavings ?? 0
        } catch {
            return 0
        }
    }
    
    /// Calculate weekly average savings
    func getWeeklyAverageSavings(for date: Date = Date()) async -> Double {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!
        
        let descriptor = FetchDescriptor<CalorieSavingsRecord>(
            predicate: #Predicate<CalorieSavingsRecord> { record in
                record.date >= startOfWeek && record.date < endOfWeek
            }
        )
        
        do {
            let records = try modelContext.fetch(descriptor)
            let totalSavings = records.reduce(0) { $0 + $1.dailyBalance }
            return totalSavings / 7.0
        } catch {
            return 0
        }
    }
    
    /// Calculate monthly progress towards goal
    func getMonthlyProgress(for date: Date = Date()) async -> MonthlyProgress {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: date)?.start ?? date
        let endOfMonth = calendar.dateInterval(of: .month, for: date)?.end ?? date
        let daysInMonth = calendar.dateInterval(of: .month, for: date)?.duration ?? 0 / (24 * 60 * 60)
        
        let descriptor = FetchDescriptor<CalorieSavingsRecord>(
            predicate: #Predicate<CalorieSavingsRecord> { record in
                record.date >= startOfMonth && record.date < endOfMonth
            }
        )
        
        do {
            let records = try modelContext.fetch(descriptor)
            let totalSavings = records.reduce(0) { $0 + $1.dailyBalance }
            let daysWithSavings = records.filter { $0.hasSavings }.count
            let averageDailySavings = records.isEmpty ? 0 : totalSavings / Double(records.count)
            
            // Get user goal from profile
            let profileDescriptor = FetchDescriptor<UserProfile>()
            let profiles = try modelContext.fetch(profileDescriptor)
            let monthlyGoal = profiles.first?.calculateTargetSavings() ?? 0
            
            return MonthlyProgress(
                totalSavings: totalSavings,
                daysWithSavings: daysWithSavings,
                totalDays: Int(daysInMonth),
                averageDailySavings: averageDailySavings,
                monthlyGoal: monthlyGoal * daysInMonth,
                progressPercentage: monthlyGoal > 0 ? (totalSavings / (monthlyGoal * daysInMonth)) * 100 : 0
            )
        } catch {
            return MonthlyProgress(
                totalSavings: 0,
                daysWithSavings: 0,
                totalDays: Int(daysInMonth),
                averageDailySavings: 0,
                monthlyGoal: 0,
                progressPercentage: 0
            )
        }
    }
    
    // MARK: - Goal Management
    
    /// Set daily calorie goal based on user profile
    func updateDailyGoal(for userProfile: UserProfile) {
        dailyGoal = userProfile.calculateDailyCalorieGoal() ?? 2000
    }
    
    /// Check if user is on track for their goals
    func isOnTrackForGoals() async -> Bool {
        let weeklyAverage = await getWeeklyAverageSavings()
        
        // Get user profile
        let profileDescriptor = FetchDescriptor<UserProfile>()
        do {
            let profiles = try modelContext.fetch(profileDescriptor)
            guard let profile = profiles.first,
                  let targetSavings = profile.calculateTargetSavings() else {
                return false
            }
            
            return weeklyAverage >= (targetSavings * 0.8) // 80% of target is considered on track
        } catch {
            return false
        }
    }
}

// MARK: - Supporting Types

struct MonthlyProgress {
    let totalSavings: Double
    let daysWithSavings: Int
    let totalDays: Int
    let averageDailySavings: Double
    let monthlyGoal: Double
    let progressPercentage: Double
    
    var formattedTotalSavings: String {
        return String(format: "%.0f kcal", totalSavings)
    }
    
    var consistencyRate: Double {
        return totalDays > 0 ? (Double(daysWithSavings) / Double(totalDays)) * 100 : 0
    }
}

enum CalorieCalculationError: LocalizedError {
    case summaryNotFound
    case userProfileNotFound
    case invalidDate
    
    var errorDescription: String? {
        switch self {
        case .summaryNotFound:
            return "日次サマリーが見つかりません"
        case .userProfileNotFound:
            return "ユーザープロフィールが見つかりません"
        case .invalidDate:
            return "無効な日付です"
        }
    }
}