//
//  MealRecord.swift
//  TonTon
//
//  Model representing a meal record with nutritional information
//  Migrated from Flutter MealRecord class
//

import Foundation
import SwiftData

@Model
class MealRecord {
    var id: UUID = UUID()
    var mealName: String = ""
    var mealDescription: String = ""
    var calories: Double = 0.0
    var protein: Double = 0.0
    var fat: Double = 0.0
    var carbs: Double = 0.0
    var mealTimeType: MealTimeType = MealTimeType.snack
    var consumedAt: Date = Date()
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    // Relationships
    @Relationship(inverse: \UserProfile.mealRecords) var userProfile: UserProfile?
    
    init(mealName: String,
         mealDescription: String = "",
         calories: Double,
         protein: Double,
         fat: Double,
         carbs: Double,
         mealTimeType: MealTimeType,
         consumedAt: Date? = nil) {
        self.id = UUID()
        self.mealName = mealName
        self.mealDescription = mealDescription
        self.calories = calories
        self.protein = protein
        self.fat = fat
        self.carbs = carbs
        self.mealTimeType = mealTimeType
        self.consumedAt = consumedAt ?? Date()
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    /// Update meal record and set updatedAt timestamp
    func updateMeal(mealName: String? = nil,
                   mealDescription: String? = nil,
                   calories: Double? = nil,
                   protein: Double? = nil,
                   fat: Double? = nil,
                   carbs: Double? = nil,
                   mealTimeType: MealTimeType? = nil,
                   consumedAt: Date? = nil) {
        if let mealName = mealName { self.mealName = mealName }
        if let mealDescription = mealDescription { self.mealDescription = mealDescription }
        if let calories = calories { self.calories = calories }
        if let protein = protein { self.protein = protein }
        if let fat = fat { self.fat = fat }
        if let carbs = carbs { self.carbs = carbs }
        if let mealTimeType = mealTimeType { self.mealTimeType = mealTimeType }
        if let consumedAt = consumedAt { self.consumedAt = consumedAt }
        self.updatedAt = Date()
    }
    
    /// Calculate total macronutrients in grams
    var totalMacros: Double {
        return protein + fat + carbs
    }
    
    /// Calculate calories from macronutrients (for validation)
    var calculatedCalories: Double {
        return (protein * 4) + (fat * 9) + (carbs * 4)
    }
    
    /// Check if meal was consumed today
    var isToday: Bool {
        Calendar.current.isDateInToday(consumedAt)
    }
    
    /// Get formatted date string
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: consumedAt)
    }
    
    // MARK: - PFC Analysis
    
    /// Calculate PFC (Protein/Fat/Carbs) balance percentages
    var pfcBalance: PFCBalance {
        let totalCalories = calculatedCalories
        guard totalCalories > 0 else {
            return PFCBalance(proteinPercent: 0, fatPercent: 0, carbsPercent: 0)
        }
        
        let proteinPercent = (protein * 4) / totalCalories * 100
        let fatPercent = (fat * 9) / totalCalories * 100
        let carbsPercent = (carbs * 4) / totalCalories * 100
        
        return PFCBalance(
            proteinPercent: proteinPercent,
            fatPercent: fatPercent,
            carbsPercent: carbsPercent
        )
    }
    
    /// Get formatted nutrition string
    var formattedNutrition: String {
        return "P: \(String(format: "%.1f", protein))g | F: \(String(format: "%.1f", fat))g | C: \(String(format: "%.1f", carbs))g"
    }
    
    /// Calculate calorie accuracy (difference between stated and calculated)
    var calorieAccuracy: Double {
        guard calculatedCalories > 0 else { return 0 }
        return abs(calories - calculatedCalories) / calculatedCalories * 100
    }
    
    /// Check if this meal fits dietary goals
    func fitsGoals(for profile: UserProfile) -> Bool {
        guard let goal = profile.dietGoal else { return true }
        
        switch goal {
        case "weight_loss":
            // Lower calorie density preferred
            return calories < 600
        case "muscle_gain":
            // High protein preferred
            return pfcBalance.proteinPercent >= 20
        case "maintain":
            // Balanced nutrition
            let balance = pfcBalance
            return balance.proteinPercent >= 15 && balance.fatPercent <= 35
        default:
            return true
        }
    }
}

// MARK: - Supporting Types

struct PFCBalance {
    let proteinPercent: Double
    let fatPercent: Double
    let carbsPercent: Double
    
    var isBalanced: Bool {
        return proteinPercent >= 15 && proteinPercent <= 30 &&
               fatPercent >= 20 && fatPercent <= 35 &&
               carbsPercent >= 45 && carbsPercent <= 65
    }
    
    var formattedString: String {
        return String(format: "P: %.1f%% | F: %.1f%% | C: %.1f%%", 
                      proteinPercent, fatPercent, carbsPercent)
    }
}