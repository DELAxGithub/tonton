//
//  UserProfile.swift
//  TonTon
//
//  User profile model with health goals and preferences
//  Migrated from Flutter UserProfile class
//

import Foundation
import SwiftData

@Model
class UserProfile {
    var id: UUID = UUID()
    var displayName: String? = nil
    var weight: Double? = nil
    var height: Double? = nil // 身長 (cm)
    var age: Int? = nil // 年齢
    var gender: String? = nil // 'male' or 'female' - DEPRECATED
    var ageGroup: String? = nil // 'young', 'middle', 'senior' - DEPRECATED  
    var dietGoal: String? = nil // 'weight_loss', 'muscle_gain', 'maintain'
    var targetWeight: Double? = nil
    var targetDays: Int? = nil
    var onboardingCompleted: Bool = false
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var lastModified: Date = Date() // ProfileEditViewで使用
    
    // AI Settings
    var selectedAIProvider: String = AIProvider.gemini.rawValue
    var aiProviderPreferencesData: Data?
    var lastWeightDate: Date?
    var calorieGoal: Double? = nil
    
    // HealthKit Integration
    var dailyCaloriesBurned: Double? = nil
    var lastCaloriesSyncDate: Date? = nil
    
    // Relationships
    @Relationship(deleteRule: .cascade) var mealRecords: [MealRecord]?
    @Relationship(deleteRule: .cascade) var weightRecords: [WeightRecord]?
    @Relationship(deleteRule: .cascade) var calorieSavingsRecords: [CalorieSavingsRecord]?
    
    init(displayName: String? = nil,
         weight: Double? = nil,
         height: Double? = nil,
         age: Int? = nil,
         gender: String? = nil,
         ageGroup: String? = nil,
         dietGoal: String? = nil,
         targetWeight: Double? = nil,
         targetDays: Int? = nil,
         onboardingCompleted: Bool = false) {
        self.id = UUID()
        self.displayName = displayName
        self.weight = weight
        self.height = height
        self.age = age
        self.gender = gender
        self.ageGroup = ageGroup
        self.dietGoal = dietGoal
        self.targetWeight = targetWeight
        self.targetDays = targetDays
        self.onboardingCompleted = onboardingCompleted
        self.selectedAIProvider = AIProvider.gemini.rawValue // デフォルト値を明示的に設定
        self.createdAt = Date()
        self.updatedAt = Date()
        self.lastModified = Date()
    }
    
    /// Update the profile and set updatedAt timestamp
    func updateProfile(displayName: String? = nil,
                      weight: Double? = nil,
                      height: Double? = nil,
                      age: Int? = nil,
                      gender: String? = nil,
                      ageGroup: String? = nil,
                      dietGoal: String? = nil,
                      targetWeight: Double? = nil,
                      targetDays: Int? = nil,
                      onboardingCompleted: Bool? = nil) {
        if let displayName = displayName { self.displayName = displayName }
        if let weight = weight { self.weight = weight }
        if let height = height { self.height = height }
        if let age = age { self.age = age }
        if let gender = gender { self.gender = gender }
        if let ageGroup = ageGroup { self.ageGroup = ageGroup }
        if let dietGoal = dietGoal { self.dietGoal = dietGoal }
        if let targetWeight = targetWeight { self.targetWeight = targetWeight }
        if let targetDays = targetDays { self.targetDays = targetDays }
        if let onboardingCompleted = onboardingCompleted { self.onboardingCompleted = onboardingCompleted }
        self.updatedAt = Date()
        self.lastModified = Date()
    }
    
    /// Calculate base metabolic rate using Harris-Benedict equation
    func calculateBMR() -> Double? {
        guard let weight = weight,
              let height = height,
              let age = age,
              let gender = gender else { return nil }
        
        // Harris-Benedict equation (revised)
        if gender == "male" {
            return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * Double(age))
        } else {
            return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * Double(age))
        }
    }
    
    /// Calculate Total Daily Energy Expenditure based on activity level
    func calculateTDEE(activityLevel: ActivityLevel = .sedentary) -> Double? {
        guard let bmr = calculateBMR() else { return nil }
        return bmr * activityLevel.multiplier
    }
    
    /// Calculate daily calorie goal based on diet goal
    func calculateDailyCalorieGoal() -> Double? {
        guard let tdee = calculateTDEE() else { return nil }
        
        switch dietGoal {
        case "weight_loss":
            return tdee * 0.85 // 15% deficit for weight loss
        case "muscle_gain":
            return tdee * 1.15 // 15% surplus for muscle gain
        case "maintain":
            return tdee
        default:
            return tdee
        }
    }
    
    /// Calculate expected daily calorie savings based on goals
    func calculateTargetSavings() -> Double? {
        guard let tdee = calculateTDEE(),
              let calorieGoal = calorieGoal else { return nil }
        
        return max(0, tdee - calorieGoal) // Only positive savings
    }
    
    // MARK: - AI Settings
    
    var aiProvider: AIProvider {
        get { AIProvider(rawValue: selectedAIProvider) ?? .gemini }
        set { selectedAIProvider = newValue.rawValue }
    }
    
    var aiProviderPreferences: AIProviderPreferences {
        get {
            guard let data = aiProviderPreferencesData,
                  let preferences = try? JSONDecoder().decode(AIProviderPreferences.self, from: data) else {
                return AIProviderPreferences()
            }
            return preferences
        }
        set {
            aiProviderPreferencesData = try? JSONEncoder().encode(newValue)
            updatedAt = Date()
        }
    }
    
    func updateAISettings(provider: AIProvider, preferences: AIProviderPreferences? = nil) {
        self.aiProvider = provider
        if let preferences = preferences {
            self.aiProviderPreferences = preferences
        }
        self.updatedAt = Date()
    }
}