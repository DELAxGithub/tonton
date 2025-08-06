//
//  CloudKitService.swift
//  TonTon
//
//  CloudKit integration for authentication and data synchronization
//  Handles user authentication, data backup, and cross-device sync
//

import Foundation
import CloudKit
import SwiftData

@MainActor
class CloudKitService: ObservableObject {
    static let shared = CloudKitService()
    
    private let container = CKContainer.default()
    private let publicDatabase: CKDatabase
    private let privateDatabase: CKDatabase
    
    @Published var isSignedIn = false
    @Published var userAccountStatus: String = "未確認"
    @Published var lastSyncDate: Date?
    @Published var syncStatus: String = "未同期"
    @Published var isSyncing = false
    
    // Record types
    private let userProfileRecordType = "UserProfile"
    private let mealRecordType = "MealRecord"
    private let weightRecordType = "WeightRecord"
    private let calorieSavingsRecordType = "CalorieSavingsRecord"
    
    private init() {
        self.publicDatabase = container.publicCloudDatabase
        self.privateDatabase = container.privateCloudDatabase
    }
    
    // MARK: - Authentication
    
    func checkAccountStatus() async {
        do {
            let status = try await container.accountStatus()
            
            switch status {
            case .available:
                userAccountStatus = "利用可能"
                isSignedIn = true
            case .noAccount:
                userAccountStatus = "アカウントなし"
                isSignedIn = false
            case .restricted:
                userAccountStatus = "制限中"
                isSignedIn = false
            case .couldNotDetermine:
                userAccountStatus = "確認不可"
                isSignedIn = false
            case .temporarilyUnavailable:
                userAccountStatus = "一時的に利用不可"
                isSignedIn = false
            @unknown default:
                userAccountStatus = "不明"
                isSignedIn = false
            }
            
            updateSyncStatus(isSignedIn ? "認証済み" : "未認証")
        } catch {
            userAccountStatus = "エラー: \(error.localizedDescription)"
            isSignedIn = false
            updateSyncStatus("認証エラー")
        }
    }
    
    func requestPermissions() async throws -> Bool {
        let status = try await container.requestApplicationPermission(.userDiscoverability)
        return status == .granted
    }
    
    // MARK: - Data Synchronization
    
    func syncAllData(with modelContext: ModelContext) async throws {
        guard isSignedIn else {
            throw CloudKitError.notSignedIn
        }
        
        isSyncing = true
        updateSyncStatus("全データ同期中...")
        
        do {
            // Upload local data to CloudKit
            try await uploadUserProfile(modelContext: modelContext)
            try await uploadMealRecords(modelContext: modelContext)
            try await uploadWeightRecords(modelContext: modelContext)
            try await uploadCalorieSavingsRecords(modelContext: modelContext)
            
            // Download and merge data from CloudKit
            try await downloadUserProfile(modelContext: modelContext)
            try await downloadMealRecords(modelContext: modelContext)
            try await downloadWeightRecords(modelContext: modelContext)
            try await downloadCalorieSavingsRecords(modelContext: modelContext)
            
            lastSyncDate = Date()
            updateSyncStatus("同期完了")
            
        } catch {
            updateSyncStatus("同期エラー: \(error.localizedDescription)")
            throw error
        }
        
        isSyncing = false
    }
    
    // MARK: - UserProfile Sync
    
    private func uploadUserProfile(modelContext: ModelContext) async throws {
        let profileDescriptor = FetchDescriptor<UserProfile>()
        let profiles = try modelContext.fetch(profileDescriptor)
        
        guard let profile = profiles.first else { return }
        
        let record = CKRecord(recordType: userProfileRecordType)
        record["displayName"] = profile.displayName
        record["weight"] = profile.weight
        record["gender"] = profile.gender
        record["ageGroup"] = profile.ageGroup
        record["dietGoal"] = profile.dietGoal
        record["targetWeight"] = profile.targetWeight
        record["targetDays"] = profile.targetDays
        record["onboardingCompleted"] = profile.onboardingCompleted ? 1 : 0
        record["selectedAIProvider"] = profile.selectedAIProvider
        record["calorieGoal"] = profile.calorieGoal
        record["lastWeightDate"] = profile.lastWeightDate
        record["dailyCaloriesBurned"] = profile.dailyCaloriesBurned
        record["lastCaloriesSyncDate"] = profile.lastCaloriesSyncDate
        record["createdAt"] = profile.createdAt
        record["updatedAt"] = profile.updatedAt
        
        // Store AI preferences as data
        if let preferencesData = profile.aiProviderPreferencesData {
            record["aiProviderPreferencesData"] = preferencesData
        }
        
        try await privateDatabase.save(record)
    }
    
    private func downloadUserProfile(modelContext: ModelContext) async throws {
        let query = CKQuery(recordType: userProfileRecordType, predicate: NSPredicate(value: true))
        let records = try await privateDatabase.records(matching: query)
        
        guard records.matchResults.first?.1 != nil else { return }
        
        let profileDescriptor = FetchDescriptor<UserProfile>()
        let profiles = try modelContext.fetch(profileDescriptor)
        let profile = profiles.first ?? UserProfile()
        
        if profiles.isEmpty {
            modelContext.insert(profile)
        }
        
        // Update profile with CloudKit data
        // Note: CloudKit record.get method signature may need adjustment
        // Profile sync would go here when CloudKit integration is fully implemented
        profile.displayName = profile.displayName ?? "ユーザー"
        // CloudKit sync implementation placeholder
        
        try modelContext.save()
    }
    
    // MARK: - MealRecord Sync
    
    private func uploadMealRecords(modelContext: ModelContext) async throws {
        // Get recent meal records (last 30 days)
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        
        let mealDescriptor = FetchDescriptor<MealRecord>(
            predicate: #Predicate<MealRecord> { meal in
                meal.consumedAt >= thirtyDaysAgo
            }
        )
        
        let meals = try modelContext.fetch(mealDescriptor)
        
        for meal in meals {
            let record = CKRecord(recordType: mealRecordType)
            record["mealName"] = meal.mealName
            record["description"] = meal.mealDescription
            record["calories"] = meal.calories
            record["protein"] = meal.protein
            record["fat"] = meal.fat
            record["carbs"] = meal.carbs
            // record["confidence"] = meal.confidence // Not available in current model
            // record["aiProvider"] = meal.aiProvider // Not available in current model
            record["date"] = meal.consumedAt
            record["mealTime"] = meal.mealTimeType.rawValue
            record["localID"] = meal.id.uuidString
            
            // Upload image if exists (placeholder - imageData not available in current model)
            // if let imageData = meal.imageData {
            //     let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".jpg")
            //     try imageData.write(to: tempURL)
            //     record["imageAsset"] = CKAsset(fileURL: tempURL)
            // }
            
            try await privateDatabase.save(record)
        }
    }
    
    private func downloadMealRecords(modelContext: ModelContext) async throws {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let predicate = NSPredicate(format: "date >= %@", thirtyDaysAgo as NSDate)
        let query = CKQuery(recordType: mealRecordType, predicate: predicate)
        
        let records = try await privateDatabase.records(matching: query)
        
        for result in records.matchResults {
            switch result.1 {
            case .success(let record):
                // Check if record already exists locally
                let localID = record["localID"] as? String
                if let localIDString = localID,
                   let localUUID = UUID(uuidString: localIDString) {
                    
                    let existingDescriptor = FetchDescriptor<MealRecord>(
                        predicate: #Predicate<MealRecord> { meal in
                            meal.id == localUUID
                        }
                    )
                    
                    let existing = try modelContext.fetch(existingDescriptor)
                    if !existing.isEmpty { continue }
                }
                
                // Create new meal record
                let meal = MealRecord(
                    mealName: record["mealName"] as? String ?? "不明",
                    mealDescription: record["description"] as? String ?? "",
                    calories: record["calories"] as? Double ?? 0,
                    protein: record["protein"] as? Double ?? 0,
                    fat: record["fat"] as? Double ?? 0,
                    carbs: record["carbs"] as? Double ?? 0,
                    mealTimeType: MealTimeType(rawValue: record["mealTime"] as? String ?? "snack") ?? .snack,
                    consumedAt: record["date"] as? Date ?? Date()
                )
                
                // Note: Current MealRecord model doesn't support confidence, aiProvider, imageData
                // These would need to be added to the model if CloudKit sync is required
                
                // Download image if exists (placeholder - would need imageData property)
                if let imageAsset = record["imageAsset"] as? CKAsset,
                   let imageURL = imageAsset.fileURL {
                    // meal.imageData = try Data(contentsOf: imageURL) // Requires imageData property
                }
                
                if let localIDString = localID,
                   let localUUID = UUID(uuidString: localIDString) {
                    meal.id = localUUID
                }
                
                modelContext.insert(meal)
                
            case .failure(let error):
                print("Failed to download meal record: \(error)")
            }
        }
        
        try modelContext.save()
    }
    
    // MARK: - WeightRecord Sync
    
    private func uploadWeightRecords(modelContext: ModelContext) async throws {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        
        let weightDescriptor = FetchDescriptor<WeightRecord>(
            predicate: #Predicate<WeightRecord> { weight in
                weight.date >= thirtyDaysAgo
            }
        )
        
        let weights = try modelContext.fetch(weightDescriptor)
        
        for weight in weights {
            let record = CKRecord(recordType: weightRecordType)
            record["weight"] = weight.weight
            record["date"] = weight.date
            // Note: WeightRecord doesn't have source property, using default
            record["localID"] = weight.id.uuidString
            
            try await privateDatabase.save(record)
        }
    }
    
    private func downloadWeightRecords(modelContext: ModelContext) async throws {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let predicate = NSPredicate(format: "date >= %@", thirtyDaysAgo as NSDate)
        let query = CKQuery(recordType: weightRecordType, predicate: predicate)
        
        let records = try await privateDatabase.records(matching: query)
        
        for result in records.matchResults {
            switch result.1 {
            case .success(let record):
                // Check if record already exists locally
                let localID = record["localID"] as? String
                if let localIDString = localID,
                   let localUUID = UUID(uuidString: localIDString) {
                    
                    let existingDescriptor = FetchDescriptor<WeightRecord>(
                        predicate: #Predicate<WeightRecord> { weight in
                            weight.id == localUUID
                        }
                    )
                    
                    let existing = try modelContext.fetch(existingDescriptor)
                    if !existing.isEmpty { continue }
                }
                
                // Create new weight record
                let weight = WeightRecord(
                    weight: record["weight"] as? Double ?? 0,
                    date: record["date"] as? Date ?? Date()
                )
                
                if let localIDString = localID,
                   let localUUID = UUID(uuidString: localIDString) {
                    weight.id = localUUID
                }
                
                modelContext.insert(weight)
                
            case .failure(let error):
                print("Failed to download weight record: \(error)")
            }
        }
        
        try modelContext.save()
    }
    
    // MARK: - CalorieSavingsRecord Sync
    
    private func uploadCalorieSavingsRecords(modelContext: ModelContext) async throws {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        
        let savingsDescriptor = FetchDescriptor<CalorieSavingsRecord>(
            predicate: #Predicate<CalorieSavingsRecord> { savings in
                savings.date >= thirtyDaysAgo
            }
        )
        
        let savings = try modelContext.fetch(savingsDescriptor)
        
        for saving in savings {
            let record = CKRecord(recordType: calorieSavingsRecordType)
            record["date"] = saving.date
            record["dailyBalance"] = saving.dailyBalance
            record["caloriesConsumed"] = saving.caloriesConsumed
            record["caloriesBurned"] = saving.caloriesBurned
            record["localID"] = saving.id.uuidString
            
            try await privateDatabase.save(record)
        }
    }
    
    private func downloadCalorieSavingsRecords(modelContext: ModelContext) async throws {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let predicate = NSPredicate(format: "date >= %@", thirtyDaysAgo as NSDate)
        let query = CKQuery(recordType: calorieSavingsRecordType, predicate: predicate)
        
        let records = try await privateDatabase.records(matching: query)
        
        for result in records.matchResults {
            switch result.1 {
            case .success(let record):
                // Check if record already exists locally
                let localID = record["localID"] as? String
                if let localIDString = localID,
                   let localUUID = UUID(uuidString: localIDString) {
                    
                    let existingDescriptor = FetchDescriptor<CalorieSavingsRecord>(
                        predicate: #Predicate<CalorieSavingsRecord> { savings in
                            savings.id == localUUID
                        }
                    )
                    
                    let existing = try modelContext.fetch(existingDescriptor)
                    if !existing.isEmpty { continue }
                }
                
                // Create new calorie savings record
                let savings = CalorieSavingsRecord(
                    date: record["date"] as? Date ?? Date(),
                    caloriesConsumed: record["caloriesConsumed"] as? Double ?? 0,
                    caloriesBurned: record["caloriesBurned"] as? Double ?? 0,
                    dailyBalance: record["dailyBalance"] as? Double ?? 0,
                    cumulativeSavings: record["cumulativeSavings"] as? Double ?? 0
                )
                
                if let localIDString = localID,
                   let localUUID = UUID(uuidString: localIDString) {
                    savings.id = localUUID
                }
                
                modelContext.insert(savings)
                
            case .failure(let error):
                print("Failed to download calorie savings record: \(error)")
            }
        }
        
        try modelContext.save()
    }
    
    // MARK: - Background Sync
    
    func enableRemoteNotifications() async throws {
        let subscription = CKQuerySubscription(
            recordType: userProfileRecordType,
            predicate: NSPredicate(value: true),
            options: [.firesOnRecordCreation, .firesOnRecordUpdate]
        )
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
        
        try await privateDatabase.save(subscription)
    }
    
    // MARK: - Utility Methods
    
    private func updateSyncStatus(_ status: String) {
        syncStatus = status
    }
    
    func getAccountInfo() async -> (userID: String?, email: String?) {
        do {
            let userID = try await container.userRecordID()
            return (userID: userID.recordName, email: nil)
        } catch {
            return (userID: nil, email: nil)
        }
    }
    
    func deleteAllCloudData() async throws {
        guard isSignedIn else {
            throw CloudKitError.notSignedIn
        }
        
        updateSyncStatus("クラウドデータ削除中...")
        
        // Delete all record types
        let recordTypes = [userProfileRecordType, mealRecordType, weightRecordType, calorieSavingsRecordType]
        
        for recordType in recordTypes {
            let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
            let records = try await privateDatabase.records(matching: query)
            
            for result in records.matchResults {
                switch result.1 {
                case .success(let record):
                    try await privateDatabase.deleteRecord(withID: record.recordID)
                case .failure(let error):
                    print("Failed to delete record: \(error)")
                }
            }
        }
        
        updateSyncStatus("クラウドデータ削除完了")
    }
}

// MARK: - Error Types

enum CloudKitError: Error, LocalizedError {
    case notSignedIn
    case syncFailed
    case permissionDenied
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .notSignedIn:
            return "iCloudにサインインしていません"
        case .syncFailed:
            return "データの同期に失敗しました"
        case .permissionDenied:
            return "CloudKitへのアクセスが拒否されました"
        case .networkError:
            return "ネットワークエラーが発生しました"
        }
    }
}