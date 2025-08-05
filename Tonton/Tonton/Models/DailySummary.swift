//
//  DailySummary.swift
//  TonTon
//
//  Model representing aggregated daily health data
//  Migrated from Flutter DailySummary class
//

import Foundation
import SwiftData

@Model
class DailySummary {
    var id: UUID = UUID()
    var date: Date = Date()
    var caloriesConsumed: Double = 0.0
    var caloriesBurned: Double = 0.0
    var weight: Double? = nil
    var bodyFatPercentage: Double? = nil
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    // Computed nutrition totals from meal records
    var totalProtein: Double = 0.0
    var totalFat: Double = 0.0
    var totalCarbs: Double = 0.0
    
    init(date: Date,
         caloriesConsumed: Double,
         caloriesBurned: Double,
         weight: Double? = nil,
         bodyFatPercentage: Double? = nil) {
        self.id = UUID()
        self.date = date
        self.caloriesConsumed = caloriesConsumed
        self.caloriesBurned = caloriesBurned
        self.weight = weight
        self.bodyFatPercentage = bodyFatPercentage
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    /// Net calories (burned - consumed) - the core "savings" concept
    var netCalories: Double {
        return caloriesBurned - caloriesConsumed
    }
    
    /// Total calories burned (for clarity)
    var totalCaloriesBurned: Double {
        return caloriesBurned
    }
    
    /// Check if there were calorie savings
    var hasSavings: Bool {
        return netCalories > 0
    }
    
    /// Update summary with new data
    func updateSummary(caloriesConsumed: Double? = nil,
                      caloriesBurned: Double? = nil,
                      weight: Double? = nil,
                      bodyFatPercentage: Double? = nil,
                      totalProtein: Double? = nil,
                      totalFat: Double? = nil,
                      totalCarbs: Double? = nil) {
        if let consumed = caloriesConsumed { self.caloriesConsumed = consumed }
        if let burned = caloriesBurned { self.caloriesBurned = burned }
        if let weight = weight { self.weight = weight }
        if let bodyFat = bodyFatPercentage { self.bodyFatPercentage = bodyFat }
        if let protein = totalProtein { self.totalProtein = protein }
        if let fat = totalFat { self.totalFat = fat }
        if let carbs = totalCarbs { self.totalCarbs = carbs }
        self.updatedAt = Date()
    }
    
    /// Get formatted net calories string
    var formattedNetCalories: String {
        let sign = netCalories >= 0 ? "+" : ""
        return String(format: "%@%.0f kcal", sign, netCalories)
    }
    
    /// Get formatted weight string
    var formattedWeight: String {
        if let weight = weight {
            return String(format: "%.1f kg", weight)
        }
        return "データなし"
    }
    
    /// Get formatted body fat string
    var formattedBodyFat: String {
        if let bodyFat = bodyFatPercentage {
            return String(format: "%.1f%%", bodyFat * 100)
        }
        return "データなし"
    }
    
    /// Check if summary is for today
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    /// Get formatted date string
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    /// Get short date string (for charts)
    func shortDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
}