//
//  MealTimeType.swift
//  TonTon
//
//  Enum representing different meal times of the day
//  Migrated from Flutter MealTimeType enum
//

import Foundation

enum MealTimeType: String, CaseIterable, Codable {
    case breakfast = "breakfast"
    case lunch = "lunch"
    case dinner = "dinner"
    case snack = "snack"
    
    /// Returns a human-readable name for the meal type
    var displayName: String {
        switch self {
        case .breakfast:
            return "Breakfast"
        case .lunch:
            return "Lunch"
        case .dinner:
            return "Dinner"
        case .snack:
            return "Snack"
        }
    }
    
    /// Returns localized display name (for Japanese/English support)
    func localizedDisplayName(for locale: Locale) -> String {
        if locale.identifier.hasPrefix("ja") {
            switch self {
            case .breakfast: return "朝食"
            case .lunch: return "昼食"
            case .dinner: return "夕食"
            case .snack: return "間食"
            }
        }
        return displayName
    }
    
    /// Converts a string value to the corresponding MealTimeType
    static func fromString(_ value: String) -> MealTimeType {
        return MealTimeType(rawValue: value.lowercased()) ?? .snack
    }
}