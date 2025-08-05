//
//  BugReport.swift
//  TonTon
//
//  DELAX-inspired bug reporting models for TonTon health tracking app
//  Health and meal logging specific bug categories and context
//

import Foundation
import SwiftUI

// MARK: - Bug Report Main Model

struct TonTonBugReport: Codable, Identifiable {
    let id = UUID()
    let category: TonTonBugCategory
    let title: String?
    let description: String?
    let reproductionSteps: String?
    let expectedBehavior: String?
    let actualBehavior: String?
    let currentScreen: String
    let deviceInfo: TonTonDeviceInfo
    let healthContext: HealthKitContext?
    let mealLoggingContext: MealLoggingContext?
    let appVersion: String
    let timestamp: Date
    
    init(
        category: TonTonBugCategory,
        title: String? = nil,
        description: String? = nil,
        reproductionSteps: String? = nil,
        expectedBehavior: String? = nil,
        actualBehavior: String? = nil,
        currentScreen: String,
        healthContext: HealthKitContext? = nil,
        mealLoggingContext: MealLoggingContext? = nil
    ) {
        self.category = category
        self.title = title
        self.description = description
        self.reproductionSteps = reproductionSteps
        self.expectedBehavior = expectedBehavior
        self.actualBehavior = actualBehavior
        self.currentScreen = currentScreen
        self.deviceInfo = TonTonDeviceInfo()
        self.healthContext = healthContext
        self.mealLoggingContext = mealLoggingContext
        self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        self.timestamp = Date()
    }
}

// MARK: - Bug Categories for Health App

enum TonTonBugCategory: String, CaseIterable, Codable {
    // UI/UX Issues
    case uiDisplay = "ui_display"
    case navigationIssue = "navigation_issue"
    case buttonNotWorking = "button_not_working"
    
    // Health & Data Issues
    case healthKitSync = "healthkit_sync"
    case weightTracking = "weight_tracking"
    case calorieCalculation = "calorie_calculation"
    case dataNotSaved = "data_not_saved"
    case dataSync = "data_sync"
    
    // Meal Logging Issues
    case mealPhotoUpload = "meal_photo_upload"
    case aiAnalysisError = "ai_analysis_error"
    case nutritionEstimation = "nutrition_estimation"
    case mealLoggingFlow = "meal_logging_flow"
    
    // Performance Issues
    case appFreeze = "app_freeze"
    case slowLoading = "slow_loading"
    case memoryIssue = "memory_issue"
    case batteryDrain = "battery_drain"
    
    // Backend/API Issues
    case supabaseConnection = "supabase_connection"
    case geminiApiError = "gemini_api_error"
    case authenticationError = "authentication_error"
    
    // Other
    case crash = "crash"
    case other = "other"
    
    var displayName: String {
        switch self {
        // UI/UX
        case .uiDisplay: return "UI表示の問題"
        case .navigationIssue: return "画面遷移の問題"
        case .buttonNotWorking: return "ボタンが動作しない"
        
        // Health & Data
        case .healthKitSync: return "ヘルスケア連携"
        case .weightTracking: return "体重記録"
        case .calorieCalculation: return "カロリー計算"
        case .dataNotSaved: return "データが保存されない"
        case .dataSync: return "データ同期"
        
        // Meal Logging
        case .mealPhotoUpload: return "食事写真アップロード"
        case .aiAnalysisError: return "AI分析エラー"
        case .nutritionEstimation: return "栄養素推定"
        case .mealLoggingFlow: return "食事記録フロー"
        
        // Performance
        case .appFreeze: return "アプリが固まる"
        case .slowLoading: return "読み込みが遅い"
        case .memoryIssue: return "メモリの問題"
        case .batteryDrain: return "バッテリー消費"
        
        // Backend/API
        case .supabaseConnection: return "サーバー接続"
        case .geminiApiError: return "AI API エラー"
        case .authenticationError: return "認証エラー"
        
        // Other
        case .crash: return "アプリがクラッシュ"
        case .other: return "その他"
        }
    }
    
    var icon: String {
        switch self {
        // UI/UX
        case .uiDisplay: return "display"
        case .navigationIssue: return "arrow.turn.up.right"
        case .buttonNotWorking: return "hand.tap"
        
        // Health & Data
        case .healthKitSync: return "heart"
        case .weightTracking: return "scalemass"
        case .calorieCalculation: return "flame"
        case .dataNotSaved: return "externaldrive.badge.exclamationmark"
        case .dataSync: return "icloud.and.arrow.up"
        
        // Meal Logging
        case .mealPhotoUpload: return "camera"
        case .aiAnalysisError: return "brain"
        case .nutritionEstimation: return "chart.pie"
        case .mealLoggingFlow: return "fork.knife"
        
        // Performance
        case .appFreeze: return "pause.circle"
        case .slowLoading: return "clock"
        case .memoryIssue: return "memorychip"
        case .batteryDrain: return "battery.25"
        
        // Backend/API
        case .supabaseConnection: return "wifi.exclamationmark"
        case .geminiApiError: return "cloud.bolt"
        case .authenticationError: return "lock.trianglebadge.exclamationmark"
        
        // Other
        case .crash: return "exclamationmark.triangle"
        case .other: return "questionmark.circle"
        }
    }
}

// MARK: - Health Context

struct HealthKitContext: Codable {
    let healthKitPermissions: [String]
    let lastSyncDate: Date?
    let syncStatus: String?
    let availableDataTypes: [String]
    let lastWeightRecord: Date?
    let calorieGoal: Double?
    
    init(
        healthKitPermissions: [String] = [],
        lastSyncDate: Date? = nil,
        syncStatus: String? = nil,
        availableDataTypes: [String] = [],
        lastWeightRecord: Date? = nil,
        calorieGoal: Double? = nil
    ) {
        self.healthKitPermissions = healthKitPermissions
        self.lastSyncDate = lastSyncDate
        self.syncStatus = syncStatus
        self.availableDataTypes = availableDataTypes
        self.lastWeightRecord = lastWeightRecord
        self.calorieGoal = calorieGoal
    }
}

// MARK: - Meal Logging Context

struct MealLoggingContext: Codable {
    let currentStep: String
    let aiAnalysisStatus: String?
    let imageProcessingStatus: String?
    let nutritionEstimationStatus: String?
    let lastMealLoggedDate: Date?
    let todayMealCount: Int
    
    init(
        currentStep: String,
        aiAnalysisStatus: String? = nil,
        imageProcessingStatus: String? = nil,
        nutritionEstimationStatus: String? = nil,
        lastMealLoggedDate: Date? = nil,
        todayMealCount: Int = 0
    ) {
        self.currentStep = currentStep
        self.aiAnalysisStatus = aiAnalysisStatus
        self.imageProcessingStatus = imageProcessingStatus
        self.nutritionEstimationStatus = nutritionEstimationStatus
        self.lastMealLoggedDate = lastMealLoggedDate
        self.todayMealCount = todayMealCount
    }
}

// MARK: - Device Info Model

struct TonTonDeviceInfo: Codable {
    let deviceModel: String
    let deviceName: String
    let systemName: String
    let systemVersion: String
    let appVersion: String
    let appBuild: String
    let availableStorage: Int64?
    let totalStorage: Int64?
    let memoryUsage: [String: UInt64]
    let batteryLevel: Float?
    let batteryState: String
    let networkStatus: String
    
    init() {
        let device = UIDevice.current
        
        self.deviceModel = device.model
        self.deviceName = device.name
        self.systemName = device.systemName
        self.systemVersion = device.systemVersion
        self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        self.appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        
        // Storage info
        let fileManager = FileManager.default
        if let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                let values = try url.resourceValues(forKeys: [.volumeAvailableCapacityKey, .volumeTotalCapacityKey])
                self.availableStorage = Int64(values.volumeAvailableCapacity ?? 0)
                self.totalStorage = Int64(values.volumeTotalCapacity ?? 0)
            } catch {
                self.availableStorage = nil
                self.totalStorage = nil
            }
        } else {
            self.availableStorage = nil
            self.totalStorage = nil
        }
        
        // Memory usage
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            self.memoryUsage = [
                "resident_size": info.resident_size,
                "virtual_size": info.virtual_size
            ]
        } else {
            self.memoryUsage = [:]
        }
        
        // Battery info
        device.isBatteryMonitoringEnabled = true
        self.batteryLevel = device.batteryLevel >= 0 ? device.batteryLevel : nil
        
        switch device.batteryState {
        case .unknown: self.batteryState = "unknown"
        case .unplugged: self.batteryState = "unplugged"
        case .charging: self.batteryState = "charging"
        case .full: self.batteryState = "full"
        @unknown default: self.batteryState = "unknown"
        }
        
        // Network status (simplified)
        self.networkStatus = "available" // TODO: Implement proper network status check
    }
}