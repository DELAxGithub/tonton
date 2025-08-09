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
    
    // MARK: - Advanced Calculations
    
    /// Calculate if user met their savings goal for the day
    func metSavingsGoal(targetSavings: Double) -> Bool {
        return dailyBalance >= targetSavings
    }
    
    /// Calculate savings efficiency (actual vs target)
    func savingsEfficiency(targetSavings: Double) -> Double {
        guard targetSavings > 0 else { return 0 }
        return (dailyBalance / targetSavings) * 100
    }
    
    /// Get savings category for display purposes
    var savingsCategory: SavingsCategory {
        switch dailyBalance {
        case ..<0:
            return .deficit
        case 0..<100:
            return .minimal
        case 100..<300:
            return .good
        case 300..<500:
            return .excellent
        default:
            return .outstanding
        }
    }
    
    /// Calculate estimated weight impact (1 pound ≈ 3500 calories)
    var estimatedWeightImpact: Double {
        return dailyBalance / 3500.0 // kg equivalent
    }
    
    /// Get motivational message based on savings
    var motivationalMessage: String {
        switch savingsCategory {
        case .deficit:
            return "今日は少し多めでしたが、明日は新しいチャンス！"
        case .minimal:
            return "良いスタートです！もう少し頑張りましょう"
        case .good:
            return "素晴らしい！健康的なペースで進んでいます"
        case .excellent:
            return "とても良い結果です！この調子で続けましょう"
        case .outstanding:
            return "驚異的な成果！完璧なバランスです"
        }
    }
}

// MARK: - Supporting Types

enum SavingsCategory {
    case deficit
    case minimal
    case good
    case excellent
    case outstanding
    
    var color: String {
        switch self {
        case .deficit:
            return "#FF6B6B"    // Red
        case .minimal:
            return "#FFD93D"    // Yellow
        case .good:
            return "#6BCF7F"    // Light Green
        case .excellent:
            return "#4ECDC4"    // Teal
        case .outstanding:
            return "#45B7D1"    // Blue
        }
    }
    
    var emoji: String {
        switch self {
        case .deficit:
            return "😔"
        case .minimal:
            return "🌱"
        case .good:
            return "👍"
        case .excellent:
            return "🎉"
        case .outstanding:
            return "🏆"
        }
    }
}