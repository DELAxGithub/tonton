//
//  DataService.swift
//  TonTon
//
//  Core data service for SwiftData operations
//  Replaces Flutter providers and Hive operations
//

import Foundation
import SwiftData

@MainActor
class DataService: ObservableObject {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Generic CRUD Operations
    
    func save() throws {
        try modelContext.save()
    }
    
    func delete<T: PersistentModel>(_ object: T) {
        modelContext.delete(object)
    }
    
    func fetch<T: PersistentModel>(_ type: T.Type) throws -> [T] {
        let descriptor = FetchDescriptor<T>()
        return try modelContext.fetch(descriptor)
    }
    
    // MARK: - User Profile Operations
    
    func createUserProfile(displayName: String? = nil,
                          weight: Double? = nil,
                          gender: String? = nil,
                          ageGroup: String? = nil,
                          dietGoal: String? = nil,
                          targetWeight: Double? = nil,
                          targetDays: Int? = nil) -> UserProfile {
        let profile = UserProfile(
            displayName: displayName,
            weight: weight,
            gender: gender,
            ageGroup: ageGroup,
            dietGoal: dietGoal,
            targetWeight: targetWeight,
            targetDays: targetDays
        )
        modelContext.insert(profile)
        return profile
    }
    
    func getCurrentUserProfile() throws -> UserProfile? {
        let descriptor = FetchDescriptor<UserProfile>()
        let profiles = try modelContext.fetch(descriptor)
        return profiles.first
    }
    
    // MARK: - Meal Record Operations
    
    func addMealRecord(mealName: String,
                      description: String = "",
                      calories: Double,
                      protein: Double,
                      fat: Double,
                      carbs: Double,
                      mealTimeType: MealTimeType,
                      consumedAt: Date? = nil,
                      userProfile: UserProfile) -> MealRecord {
        let meal = MealRecord(
            mealName: mealName,
            mealDescription: description,
            calories: calories,
            protein: protein,
            fat: fat,
            carbs: carbs,
            mealTimeType: mealTimeType,
            consumedAt: consumedAt
        )
        meal.userProfile = userProfile
        modelContext.insert(meal)
        return meal
    }
    
    func getTodaysMeals(for userProfile: UserProfile) throws -> [MealRecord] {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = #Predicate<MealRecord> { meal in
            meal.consumedAt >= startOfDay &&
            meal.consumedAt < endOfDay
        }
        
        let descriptor = FetchDescriptor<MealRecord>(predicate: predicate)
        return try modelContext.fetch(descriptor)
    }
    
    func getTotalCaloriesForToday(for userProfile: UserProfile) throws -> Double {
        let todaysMeals = try getTodaysMeals(for: userProfile)
        return todaysMeals.reduce(0) { $0 + $1.calories }
    }
    
    // MARK: - Weight Record Operations
    
    func addWeightRecord(weight: Double,
                        bodyFatPercentage: Double? = nil,
                        bodyFatMass: Double? = nil,
                        date: Date? = nil,
                        userProfile: UserProfile) -> WeightRecord {
        let weightRecord = WeightRecord(
            weight: weight,
            bodyFatPercentage: bodyFatPercentage,
            bodyFatMass: bodyFatMass,
            date: date
        )
        weightRecord.userProfile = userProfile
        modelContext.insert(weightRecord)
        return weightRecord
    }
    
    func getLatestWeightRecord(for userProfile: UserProfile) throws -> WeightRecord? {
        // Simplified predicate - filter by userProfile after fetch if needed
        let predicate: Predicate<WeightRecord>? = nil
        
        let descriptor = FetchDescriptor<WeightRecord>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        let records = try modelContext.fetch(descriptor)
        return records.first
    }
    
    // MARK: - Calorie Savings Operations
    
    func addCalorieSavingsRecord(date: Date,
                                caloriesConsumed: Double,
                                caloriesBurned: Double,
                                previousCumulativeSavings: Double = 0.0,
                                userProfile: UserProfile) -> CalorieSavingsRecord {
        let record = CalorieSavingsRecord(
            date: date,
            caloriesConsumed: caloriesConsumed,
            caloriesBurned: caloriesBurned,
            previousCumulativeSavings: previousCumulativeSavings
        )
        record.userProfile = userProfile
        modelContext.insert(record)
        return record
    }
    
    func getTodaysCalorieSavings(for userProfile: UserProfile) throws -> CalorieSavingsRecord? {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = #Predicate<CalorieSavingsRecord> { record in
            record.date >= startOfDay &&
            record.date < endOfDay
        }
        
        let descriptor = FetchDescriptor<CalorieSavingsRecord>(predicate: predicate)
        let records = try modelContext.fetch(descriptor)
        return records.first
    }
    
    func updateTodaysCalorieSavings(for userProfile: UserProfile,
                                   caloriesConsumed: Double,
                                   caloriesBurned: Double) throws -> CalorieSavingsRecord {
        if let existingRecord = try getTodaysCalorieSavings(for: userProfile) {
            // Update existing record
            existingRecord.updateCalories(consumed: caloriesConsumed, burned: caloriesBurned)
            return existingRecord
        } else {
            // Create new record
            return addCalorieSavingsRecord(
                date: Date(),
                caloriesConsumed: caloriesConsumed,
                caloriesBurned: caloriesBurned,
                userProfile: userProfile
            )
        }
    }
    
    // MARK: - Daily Summary Operations
    
    func addDailySummary(date: Date,
                        caloriesConsumed: Double,
                        caloriesBurned: Double,
                        weight: Double? = nil,
                        bodyFatPercentage: Double? = nil) -> DailySummary {
        let summary = DailySummary(
            date: date,
            caloriesConsumed: caloriesConsumed,
            caloriesBurned: caloriesBurned,
            weight: weight,
            bodyFatPercentage: bodyFatPercentage
        )
        modelContext.insert(summary)
        return summary
    }
    
    func getTodaysSummary() throws -> DailySummary? {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = #Predicate<DailySummary> { summary in
            summary.date >= startOfDay && summary.date < endOfDay
        }
        
        let descriptor = FetchDescriptor<DailySummary>(predicate: predicate)
        let summaries = try modelContext.fetch(descriptor)
        return summaries.first
    }
    
    func updateOrCreateTodaysSummary(caloriesConsumed: Double,
                                    caloriesBurned: Double,
                                    weight: Double? = nil,
                                    bodyFatPercentage: Double? = nil) throws -> DailySummary {
        if let existingSummary = try getTodaysSummary() {
            existingSummary.updateSummary(
                caloriesConsumed: caloriesConsumed,
                caloriesBurned: caloriesBurned,
                weight: weight,
                bodyFatPercentage: bodyFatPercentage
            )
            return existingSummary
        } else {
            return addDailySummary(
                date: Date(),
                caloriesConsumed: caloriesConsumed,
                caloriesBurned: caloriesBurned,
                weight: weight,
                bodyFatPercentage: bodyFatPercentage
            )
        }
    }
    
    // MARK: - Calculation Helpers
    
    func calculateDailyCalorieBalance(for userProfile: UserProfile) throws -> (consumed: Double, burned: Double, balance: Double) {
        let consumed = try getTotalCaloriesForToday(for: userProfile)
        
        // Simplified calorie burn calculation
        // In production, this would integrate with HealthKit
        let bmr = userProfile.calculateBMR() ?? 1800
        let burned = bmr + 300 // Add activity calories (placeholder)
        
        let balance = burned - consumed
        
        return (consumed: consumed, burned: burned, balance: balance)
    }
}