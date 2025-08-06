//
//  HealthKitService.swift
//  TonTon
//
//  Native iOS HealthKit integration for weight and calorie data synchronization
//  Bidirectional sync with TonTon health tracking data
//

import Foundation
import HealthKit
import SwiftData

@MainActor
class HealthKitService: ObservableObject {
    static let shared = HealthKitService()
    
    private let healthStore = HKHealthStore()
    
    @Published var isAuthorized = false
    @Published var authorizationStatus: String = "未確認"
    @Published var lastSyncDate: Date?
    @Published var syncStatus: String = "未同期"
    
    // HealthKit data types we need
    private let readTypes: Set<HKObjectType> = [
        HKObjectType.quantityType(forIdentifier: .bodyMass)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!,
        HKObjectType.quantityType(forIdentifier: .stepCount)!
    ]
    
    private let writeTypes: Set<HKSampleType> = [
        HKObjectType.quantityType(forIdentifier: .bodyMass)!,
        HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
    ]
    
    private init() {}
    
    // MARK: - Authorization
    
    func requestAuthorization() async throws -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { [weak self] success, error in
                Task { @MainActor in
                    self?.isAuthorized = success
                    self?.authorizationStatus = success ? "許可済み" : "拒否"
                    self?.updateSyncStatus("認証" + (success ? "成功" : "失敗"))
                }
                
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
    }
    
    func checkAuthorizationStatus() {
        let bodyMassType = HKObjectType.quantityType(forIdentifier: .bodyMass)!
        let status = healthStore.authorizationStatus(for: bodyMassType)
        
        switch status {
        case .notDetermined:
            authorizationStatus = "未確認"
            isAuthorized = false
        case .sharingDenied:
            authorizationStatus = "拒否"
            isAuthorized = false
        case .sharingAuthorized:
            authorizationStatus = "許可済み"
            isAuthorized = true
        @unknown default:
            authorizationStatus = "不明"
            isAuthorized = false
        }
    }
    
    // MARK: - Weight Data Sync
    
    func syncWeightData(with modelContext: ModelContext) async throws {
        guard isAuthorized else {
            throw HealthKitError.notAuthorized
        }
        
        updateSyncStatus("体重データ同期中...")
        
        // Get latest weight from HealthKit
        let latestWeight = try await getLatestWeight()
        
        // Get user profile
        let profileDescriptor = FetchDescriptor<UserProfile>()
        let profiles = try modelContext.fetch(profileDescriptor)
        guard let profile = profiles.first else {
            throw HealthKitError.noUserProfile
        }
        
        // Update profile with latest weight if newer
        if let weight = latestWeight {
            if profile.lastWeightDate == nil || weight.date > profile.lastWeightDate! {
                profile.weight = weight.value
                profile.lastWeightDate = weight.date
                
                // Create new weight record
                let weightRecord = WeightRecord(
                    weight: weight.value,
                    date: weight.date
                )
                modelContext.insert(weightRecord)
            }
        }
        
        // Sync TonTon weight records to HealthKit
        try await syncTonTonWeightToHealthKit(modelContext: modelContext)
        
        lastSyncDate = Date()
        updateSyncStatus("体重同期完了")
        try modelContext.save()
    }
    
    private func getLatestWeight() async throws -> (value: Double, date: Date)? {
        let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let _ = HKSampleQuery(
            sampleType: weightType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            // Results handled in continuation
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let actualQuery = HKSampleQuery(
                sampleType: weightType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let sample = samples?.first as? HKQuantitySample {
                    let weightInKg = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                    continuation.resume(returning: (value: weightInKg, date: sample.endDate))
                } else {
                    continuation.resume(returning: nil)
                }
            }
            
            healthStore.execute(actualQuery)
        }
    }
    
    private func syncTonTonWeightToHealthKit(modelContext: ModelContext) async throws {
        // Get recent weight records from TonTon that aren't from HealthKit
        let calendar = Calendar.current
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        
        let weightDescriptor = FetchDescriptor<WeightRecord>(
            predicate: #Predicate<WeightRecord> { record in
                record.date >= thirtyDaysAgo
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        let weightRecords = try modelContext.fetch(weightDescriptor)
        
        for record in weightRecords {
            try await saveWeightToHealthKit(weight: record.weight, date: record.date)
        }
    }
    
    private func saveWeightToHealthKit(weight: Double, date: Date) async throws {
        let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        let weightQuantity = HKQuantity(unit: HKUnit.gramUnit(with: .kilo), doubleValue: weight)
        
        let weightSample = HKQuantitySample(
            type: weightType,
            quantity: weightQuantity,
            start: date,
            end: date,
            metadata: [HKMetadataKeyWasUserEntered: true]
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            healthStore.save(weightSample) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    // MARK: - Calorie Data Sync
    
    func syncCalorieData(with modelContext: ModelContext) async throws {
        guard isAuthorized else {
            throw HealthKitError.notAuthorized
        }
        
        updateSyncStatus("カロリーデータ同期中...")
        
        // Get today's calorie data from HealthKit
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        let activeCalories = try await getCalorieData(
            type: .activeEnergyBurned,
            startDate: today,
            endDate: tomorrow
        )
        
        let basalCalories = try await getCalorieData(
            type: .basalEnergyBurned,
            startDate: today,
            endDate: tomorrow
        )
        
        // Update user profile with calorie data
        let profileDescriptor = FetchDescriptor<UserProfile>()
        let profiles = try modelContext.fetch(profileDescriptor)
        guard let profile = profiles.first else {
            throw HealthKitError.noUserProfile
        }
        
        // Calculate total daily energy expenditure
        let totalCalories = activeCalories + basalCalories
        profile.dailyCaloriesBurned = totalCalories
        profile.lastCaloriesSyncDate = Date()
        
        // Sync meal calories to HealthKit
        try await syncMealCaloriesToHealthKit(modelContext: modelContext)
        
        updateSyncStatus("カロリー同期完了")
        try modelContext.save()
    }
    
    private func getCalorieData(type: HKQuantityTypeIdentifier, startDate: Date, endDate: Date) async throws -> Double {
        let calorieType = HKQuantityType.quantityType(forIdentifier: type)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: calorieType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let sum = result?.sumQuantity() {
                    let calories = sum.doubleValue(for: HKUnit.kilocalorie())
                    continuation.resume(returning: calories)
                } else {
                    continuation.resume(returning: 0.0)
                }
            }
            
            healthStore.execute(query)
        }
    }
    
    private func syncMealCaloriesToHealthKit(modelContext: ModelContext) async throws {
        // Get today's meal records
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        let mealDescriptor = FetchDescriptor<MealRecord>(
            predicate: #Predicate<MealRecord> { meal in
                meal.consumedAt >= today && meal.consumedAt < tomorrow
            }
        )
        
        let meals = try modelContext.fetch(mealDescriptor)
        
        for meal in meals {
            try await saveMealCaloriesToHealthKit(meal: meal)
        }
    }
    
    private func saveMealCaloriesToHealthKit(meal: MealRecord) async throws {
        let calorieType = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
        let calorieQuantity = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: meal.calories)
        
        let calorieSample = HKQuantitySample(
            type: calorieType,
            quantity: calorieQuantity,
            start: meal.consumedAt,
            end: meal.consumedAt,
            metadata: [
                HKMetadataKeyFoodType: meal.mealName,
                HKMetadataKeyWasUserEntered: false
            ]
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            healthStore.save(calorieSample) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    // MARK: - Background Sync
    
    func enableBackgroundDelivery() async throws {
        guard isAuthorized else {
            throw HealthKitError.notAuthorized
        }
        
        let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass)!
        
        return try await withCheckedThrowingContinuation { continuation in
            healthStore.enableBackgroundDelivery(for: weightType, frequency: .immediate) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    // MARK: - Utility Methods
    
    private func updateSyncStatus(_ status: String) {
        syncStatus = status
    }
    
    func getAvailableDataTypes() -> [String] {
        return ["体重", "消費カロリー", "基礎代謝", "摂取カロリー", "歩数"]
    }
    
    func getHealthKitPermissions() -> [String] {
        var permissions: [String] = []
        
        for type in readTypes {
            let status = healthStore.authorizationStatus(for: type)
            let typeName = getDataTypeName(for: type)
            let statusText = getAuthorizationStatusText(status)
            permissions.append("\(typeName): \(statusText)")
        }
        
        return permissions
    }
    
    private func getDataTypeName(for type: HKObjectType) -> String {
        guard let quantityType = type as? HKQuantityType else { return "不明" }
        
        switch quantityType.identifier {
        case HKQuantityTypeIdentifier.bodyMass.rawValue:
            return "体重"
        case HKQuantityTypeIdentifier.activeEnergyBurned.rawValue:
            return "消費カロリー"
        case HKQuantityTypeIdentifier.basalEnergyBurned.rawValue:
            return "基礎代謝"
        case HKQuantityTypeIdentifier.dietaryEnergyConsumed.rawValue:
            return "摂取カロリー"
        case HKQuantityTypeIdentifier.stepCount.rawValue:
            return "歩数"
        default:
            return "不明"
        }
    }
    
    private func getAuthorizationStatusText(_ status: HKAuthorizationStatus) -> String {
        switch status {
        case .notDetermined:
            return "未確認"
        case .sharingDenied:
            return "拒否"
        case .sharingAuthorized:
            return "許可"
        @unknown default:
            return "不明"
        }
    }
}

// MARK: - Error Types

enum HealthKitError: Error, LocalizedError {
    case notAvailable
    case notAuthorized
    case noUserProfile
    case syncFailed
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKitは利用できません"
        case .notAuthorized:
            return "HealthKitへのアクセスが許可されていません"
        case .noUserProfile:
            return "ユーザープロフィールが見つかりません"
        case .syncFailed:
            return "データの同期に失敗しました"
        }
    }
}

// MARK: - HealthKit Context for Bug Reporting
// Note: HealthKitContext is defined in Models/BugReport.swift to avoid duplication