//
//  WeightRecord.swift
//  TonTon
//
//  Model representing a weight measurement record from HealthKit
//  Migrated from Flutter WeightRecord class
//

import Foundation
import SwiftData

@Model
class WeightRecord {
    var id: UUID = UUID()
    var weight: Double = 0.0
    var bodyFatPercentage: Double? = nil
    var bodyFatMass: Double? = nil
    var date: Date = Date()
    var createdAt: Date = Date()
    
    // Relationships
    @Relationship(inverse: \UserProfile.weightRecords) var userProfile: UserProfile?
    
    init(weight: Double,
         bodyFatPercentage: Double? = nil,
         bodyFatMass: Double? = nil,
         date: Date? = nil) {
        self.id = UUID()
        self.weight = weight
        self.bodyFatPercentage = bodyFatPercentage
        self.bodyFatMass = bodyFatMass
        self.date = date ?? Date()
        self.createdAt = Date()
    }
    
    /// Check if body fat data is available
    var hasBodyFat: Bool {
        return bodyFatPercentage != nil
    }
    
    /// Get formatted weight string
    var formattedWeight: String {
        return String(format: "%.1f kg", weight)
    }
    
    /// Get formatted body fat percentage string
    var formattedBodyFat: String {
        if let bodyFatPercentage = bodyFatPercentage {
            return String(format: "%.1f %%", bodyFatPercentage * 100)
        }
        return "データなし"
    }
    
    /// Get formatted body fat mass string
    var formattedBodyFatMass: String {
        if let bodyFatMass = bodyFatMass {
            return String(format: "%.1f kg", bodyFatMass)
        }
        return "データなし"
    }
    
    /// Check if weight was recorded today
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    /// Get formatted date string
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    /// Calculate BMI if height is provided
    func calculateBMI(height: Double?) -> Double? {
        guard let height = height, height > 0 else { return nil }
        let heightInMeters = height / 100 // Convert cm to meters
        return weight / (heightInMeters * heightInMeters)
    }
}