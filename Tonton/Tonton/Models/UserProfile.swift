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
    @Relationship(deleteRule: .cascade) var mealRecords: [MealRecord] = []
    @Relationship(deleteRule: .cascade) var weightRecords: [WeightRecord] = []
    @Relationship(deleteRule: .cascade) var calorieSavingsRecords: [CalorieSavingsRecord] = []
    
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
    
    /// Calculate base metabolic rate (simplified calculation)
    func calculateBMR() -> Double? {
        guard let weight = weight,
              let gender = gender else { return nil }
        
        // Simplified BMR calculation
        // In production, would use more sophisticated calculation with age and height
        let baseBMR = weight * 22 // Basic multiplier
        return gender == "male" ? baseBMR * 1.1 : baseBMR
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