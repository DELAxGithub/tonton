//
//  ActivityLevel.swift
//  TonTon
//
//  Activity level enumeration for TDEE calculation
//  Based on standard activity multipliers
//

import Foundation

enum ActivityLevel: String, CaseIterable {
    case sedentary = "sedentary"
    case lightlyActive = "lightly_active"  
    case moderatelyActive = "moderately_active"
    case veryActive = "very_active"
    case extraActive = "extra_active"
    
    var multiplier: Double {
        switch self {
        case .sedentary:
            return 1.2  // Little to no exercise
        case .lightlyActive:
            return 1.375 // Light exercise 1-3 days/week
        case .moderatelyActive:
            return 1.55 // Moderate exercise 3-5 days/week
        case .veryActive:
            return 1.725 // Hard exercise 6-7 days/week
        case .extraActive:
            return 1.9  // Very hard exercise, physical job
        }
    }
    
    var displayName: String {
        switch self {
        case .sedentary:
            return "座りがち"
        case .lightlyActive:
            return "軽く活動的"
        case .moderatelyActive:
            return "適度に活動的"
        case .veryActive:
            return "とても活動的"
        case .extraActive:
            return "非常に活動的"
        }
    }
    
    var description: String {
        switch self {
        case .sedentary:
            return "ほとんど運動しない、デスクワーク中心"
        case .lightlyActive:
            return "週1-3回の軽い運動"
        case .moderatelyActive:
            return "週3-5回の適度な運動"
        case .veryActive:
            return "週6-7回のハードな運動"
        case .extraActive:
            return "毎日激しい運動、肉体労働"
        }
    }
}