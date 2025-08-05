//
//  SampleDataGenerator.swift
//  TonTon
//
//  Sample data generator for testing charts and UI components
//  Provides realistic test data for development and previews
//

import SwiftUI
import SwiftData
import Foundation

struct SampleDataGenerator {
    
    static func generateSampleData(in modelContext: ModelContext) {
        let calendar = Calendar.current
        let now = Date()
        
        // Create sample user profile
        let profile = UserProfile(
            displayName: "テストユーザー",
            weight: 70.0,
            gender: "male",
            ageGroup: "middle",
            dietGoal: "weight_loss",
            targetWeight: 65.0,
            targetDays: 60,
            onboardingCompleted: true
        )
        profile.calorieGoal = 1800
        modelContext.insert(profile)
        
        // Generate weight records (last 30 days)
        for i in 0..<30 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: now) else { continue }
            
            // Simulate gradual weight loss with some variation
            let baseWeight = 70.0 - (Double(30-i) * 0.05) // Gradual decrease
            let variation = Double.random(in: -0.3...0.3) // Daily variation
            let weight = max(baseWeight + variation, 60.0)
            
            let weightRecord = WeightRecord(
                weight: weight,
                date: date
            )
            modelContext.insert(weightRecord)
        }
        
        // Generate meal records (last 30 days)
        for i in 0..<30 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: now) else { continue }
            
            // Generate 2-4 meals per day
            let mealsCount = Int.random(in: 2...4)
            
            for mealIndex in 0..<mealsCount {
                let mealHour = [8, 12, 18, 21][min(mealIndex, 3)]
                guard let mealDate = calendar.date(bySettingHour: mealHour, minute: 0, second: 0, of: date) else { continue }
                
                let sampleMeals = [
                    (name: "和定食", calories: 680.0, protein: 25.0, fat: 18.0, carbs: 95.0),
                    (name: "サラダボウル", calories: 420.0, protein: 15.0, fat: 12.0, carbs: 55.0),
                    (name: "パスタ", calories: 550.0, protein: 18.0, fat: 15.0, carbs: 78.0),
                    (name: "寿司セット", calories: 480.0, protein: 22.0, fat: 8.0, carbs: 72.0),
                    (name: "カレーライス", calories: 720.0, protein: 20.0, fat: 25.0, carbs: 98.0),
                    (name: "鶏胸肉サラダ", calories: 320.0, protein: 35.0, fat: 8.0, carbs: 15.0),
                    (name: "おにぎり弁当", calories: 450.0, protein: 12.0, fat: 10.0, carbs: 78.0)
                ]
                
                let randomMeal = sampleMeals.randomElement()!
                let mealTime: MealTimeType = mealIndex == 0 ? .breakfast : 
                                          mealIndex == 1 ? .lunch : 
                                          mealIndex == 2 ? .dinner : .snack
                
                let meal = MealRecord(
                    mealName: randomMeal.name,
                    mealDescription: "\(randomMeal.name)を記録しました",
                    calories: randomMeal.calories,
                    protein: randomMeal.protein,
                    fat: randomMeal.fat,
                    carbs: randomMeal.carbs,
                    mealTimeType: mealTime,
                    consumedAt: mealDate
                )
                modelContext.insert(meal)
            }
        }
        
        // Generate calorie savings records (last 30 days)
        for i in 0..<30 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: now) else { continue }
            
            // Get meals for this day
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
            
            // Calculate consumed calories from meals (simplified)
            let consumedCalories = Double.random(in: 1200...2200)
            let targetCalories = 1800.0
            let savedCalories = targetCalories - consumedCalories
            
            let savingsRecord = CalorieSavingsRecord(
                date: date,
                caloriesConsumed: consumedCalories,
                caloriesBurned: targetCalories
            )
            modelContext.insert(savingsRecord)
        }
        
        // Generate daily summaries (last 30 days)
        for i in 0..<30 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: now) else { continue }
            
            let summary = DailySummary(
                date: date,
                caloriesConsumed: Double.random(in: 1200...2200),
                caloriesBurned: Double.random(in: 2000...2500),
                weight: 70.0 + Double.random(in: -3.0...3.0),
                bodyFatPercentage: Double.random(in: 0.15...0.25)
            )
            modelContext.insert(summary)
        }
        
        // Save all data
        try? modelContext.save()
    }
    
    static func clearAllData(in modelContext: ModelContext) {
        // Clear all existing data
        let descriptors: [Any] = [
            FetchDescriptor<UserProfile>(),
            FetchDescriptor<WeightRecord>(),
            FetchDescriptor<MealRecord>(),
            FetchDescriptor<CalorieSavingsRecord>(),
            FetchDescriptor<DailySummary>()
        ]
        
        do {
            for descriptor in descriptors {
                switch descriptor {
                case let d as FetchDescriptor<UserProfile>:
                    let items = try modelContext.fetch(d)
                    items.forEach { modelContext.delete($0) }
                case let d as FetchDescriptor<WeightRecord>:
                    let items = try modelContext.fetch(d)
                    items.forEach { modelContext.delete($0) }
                case let d as FetchDescriptor<MealRecord>:
                    let items = try modelContext.fetch(d)
                    items.forEach { modelContext.delete($0) }
                case let d as FetchDescriptor<CalorieSavingsRecord>:
                    let items = try modelContext.fetch(d)
                    items.forEach { modelContext.delete($0) }
                case let d as FetchDescriptor<DailySummary>:
                    let items = try modelContext.fetch(d)
                    items.forEach { modelContext.delete($0) }
                default:
                    break
                }
            }
            
            try modelContext.save()
        } catch {
            print("Error clearing data: \(error)")
        }
    }
}

// MARK: - Preview Helper

struct SampleDataPreview: View {
    @Environment(\.modelContext) private var modelContext
    @State private var dataGenerated = false
    
    var body: some View {
        VStack {
            if !dataGenerated {
                Button("サンプルデータを生成") {
                    SampleDataGenerator.generateSampleData(in: modelContext)
                    dataGenerated = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            } else {
                Text("サンプルデータを生成しました")
                    .foregroundColor(.green)
                
                Button("データをクリア") {
                    SampleDataGenerator.clearAllData(in: modelContext)
                    dataGenerated = false
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
    }
}

#Preview {
    SampleDataPreview()
        .modelContainer(for: [UserProfile.self, MealRecord.self, WeightRecord.self, CalorieSavingsRecord.self, DailySummary.self])
}