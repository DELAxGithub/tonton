//
//  CalorieSavingsRecord.swift
//  TonTon
//
//  Model representing daily calorie savings calculation
//  Core concept: "calorie savings" = calories burned - calories consumed
//  Migrated from Flutter CalorieSavingsRecord class
//

import Foundation
import SwiftData

@Model
class CalorieSavingsRecord {
    var id: UUID = UUID()
    var date: Date = Date()
    var dayOfMonth: Int = 1
    var caloriesConsumed: Double = 0.0
    var caloriesBurned: Double = 0.0
    var dailyBalance: Double = 0.0 // Daily difference (burned - consumed)
    var cumulativeSavings: Double = 0.0 // Running total of savings
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    // Relationships
    @Relationship(inverse: \UserProfile.calorieSavingsRecords) var userProfile: UserProfile?
    
    init(date: Date,
         caloriesConsumed: Double,
         caloriesBurned: Double,
         dailyBalance: Double,
         cumulativeSavings: Double) {
        self.id = UUID()
        self.date = date
        self.dayOfMonth = Calendar.current.component(.day, from: date)
        self.caloriesConsumed = caloriesConsumed
        self.caloriesBurned = caloriesBurned
        self.dailyBalance = dailyBalance
        self.cumulativeSavings = cumulativeSavings
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    /// Convenience initializer for creating records from raw data
    convenience init(date: Date,
                    caloriesConsumed: Double,
                    caloriesBurned: Double,
                    previousCumulativeSavings: Double = 0.0) {
        let dailyBalance = caloriesBurned - caloriesConsumed
        let cumulativeSavings = previousCumulativeSavings + dailyBalance
        
        self.init(date: date,
                 caloriesConsumed: caloriesConsumed,
                 caloriesBurned: caloriesBurned,
                 dailyBalance: dailyBalance,
                 cumulativeSavings: cumulativeSavings)
    }
    
    /// Update the record with new calorie data
    func updateCalories(consumed: Double? = nil,
                       burned: Double? = nil,
                       previousCumulativeSavings: Double? = nil) {
        if let consumed = consumed { self.caloriesConsumed = consumed }
        if let burned = burned { self.caloriesBurned = burned }
        
        // Recalculate balance
        self.dailyBalance = self.caloriesBurned - self.caloriesConsumed
        
        // Update cumulative savings if previous value provided
        if let previousCumulative = previousCumulativeSavings {
            self.cumulativeSavings = previousCumulative + self.dailyBalance
        }
        
        self.updatedAt = Date()
    }
    
    /// Check if savings were positive (saved calories)
    var hasSavings: Bool {
        return dailyBalance > 0
    }
    
    /// Get savings percentage of burned calories
    var savingsPercentage: Double {
        guard caloriesBurned > 0 else { return 0 }
        return (dailyBalance / caloriesBurned) * 100
    }
    
    /// Get formatted daily balance string
    var formattedDailyBalance: String {
        let sign = dailyBalance >= 0 ? "+" : ""
        return String(format: "%@%.0f kcal", sign, dailyBalance)
    }
    
    /// Get formatted cumulative savings string
    var formattedCumulativeSavings: String {
        let sign = cumulativeSavings >= 0 ? "+" : ""
        return String(format: "%@%.0f kcal", sign, cumulativeSavings)
    }
    
    /// Check if record is for today
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    /// Get formatted date string
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}