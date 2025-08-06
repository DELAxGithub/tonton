//
//  AIServiceManager.swift
//  TonTon
//
//  AI service management for multiple providers
//  Handles Gemini, Claude, and OpenAI integration
//

import Foundation
import SwiftUI
import UIKit

struct MealAnalysisResult {
    let mealName: String
    let description: String
    let calories: Double
    let protein: Double
    let fat: Double
    let carbs: Double
    let confidence: Double
    let provider: AIProvider
    let requestId: String
    let timestamp: Date
    
    init(mealName: String, 
         description: String, 
         calories: Double, 
         protein: Double, 
         fat: Double, 
         carbs: Double, 
         confidence: Double, 
         provider: AIProvider) {
        self.mealName = mealName
        self.description = description
        self.calories = calories
        self.protein = protein
        self.fat = fat
        self.carbs = carbs
        self.confidence = confidence
        self.provider = provider
        self.requestId = UUID().uuidString
        self.timestamp = Date()
    }
}

protocol AIProviderServiceProtocol {
    var provider: AIProvider { get }
    var isConfigured: Bool { get }
    
    func analyzeMealImage(_ image: UIImage) async throws -> MealAnalysisResult
    func testConnection() async throws -> Bool
    func estimateCost(for imageSize: Int) -> Double
}

@MainActor
class AIServiceManager: ObservableObject {
    @Published var currentProvider: AIProvider = .gemini
    @Published var isAnalyzing = false
    @Published var lastAnalysisResult: MealAnalysisResult?
    @Published var usageStats: [AIProvider: AIUsageStats] = [:]
    @Published var errorMessage: String?
    @Published var lastUsedDate: Date?
    
    private let keychainService: KeychainService
    private var services: [AIProvider: AIProviderServiceProtocol] = [:]
    
    init(keychainService: KeychainService = KeychainService()) {
        self.keychainService = keychainService
        setupServices()
        loadUsageStats()
    }
    
    private func setupServices() {
        services[.gemini] = GeminiService(keychainService: keychainService)
        services[.claude] = ClaudeService(keychainService: keychainService)
        services[.openai] = OpenAIService(keychainService: keychainService)
    }
    
    // MARK: - Configuration
    
    func setCurrentProvider(_ provider: AIProvider) {
        currentProvider = provider
        UserDefaults.standard.set(provider.rawValue, forKey: "selected_ai_provider")
    }
    
    func isProviderConfigured(_ provider: AIProvider) -> Bool {
        return keychainService.hasAPIKey(for: provider)
    }
    
    func configureProvider(_ provider: AIProvider, apiKey: String) -> Bool {
        guard keychainService.validateAPIKey(apiKey, for: provider) else {
            errorMessage = "無効なAPIキーです"
            return false
        }
        
        let success = keychainService.saveAPIKey(for: provider, apiKey: apiKey)
        if success {
            errorMessage = nil
            // Test the connection
            Task {
                do {
                    _ = try await testProvider(provider)
                } catch {
                    errorMessage = "接続テストに失敗しました: \(error.localizedDescription)"
                }
            }
        } else {
            errorMessage = "APIキーの保存に失敗しました"
        }
        
        return success
    }
    
    func removeProviderConfiguration(_ provider: AIProvider) -> Bool {
        return keychainService.deleteAPIKey(for: provider)
    }
    
    // MARK: - Analysis
    
    func analyzeMealImage(_ image: UIImage, userProfile: UserProfile) async throws -> MealAnalysisResult {
        isAnalyzing = true
        errorMessage = nil
        
        defer { isAnalyzing = false }
        
        let provider = userProfile.aiProvider
        let preferences = userProfile.aiProviderPreferences
        
        do {
            let result = try await performAnalysis(image, provider: provider, preferences: preferences)
            lastAnalysisResult = result
            lastUsedDate = Date()
            recordUsage(for: provider, cost: provider.estimatedCostPerRequest)
            return result
        } catch {
            // Try fallback if enabled
            if preferences.enableFallback, 
               let fallbackProvider = preferences.fallbackProvider,
               fallbackProvider != provider {
                do {
                    let result = try await performAnalysis(image, provider: fallbackProvider, preferences: preferences)
                    lastAnalysisResult = result
                    lastUsedDate = Date()
                    recordUsage(for: fallbackProvider, cost: fallbackProvider.estimatedCostPerRequest)
                    return result
                } catch {
                    errorMessage = "メイン及びフォールバックプロバイダーでエラーが発生しました"
                    throw error
                }
            } else {
                errorMessage = error.localizedDescription
                throw error
            }
        }
    }
    
    private func performAnalysis(_ image: UIImage, provider: AIProvider, preferences: AIProviderPreferences) async throws -> MealAnalysisResult {
        guard let service = services[provider] else {
            throw AIServiceError.providerNotAvailable
        }
        
        guard service.isConfigured else {
            throw AIServiceError.notConfigured
        }
        
        // Retry logic
        var lastError: Error?
        for attempt in 1...preferences.maxRetries {
            do {
                return try await service.analyzeMealImage(image)
            } catch {
                lastError = error
                if attempt < preferences.maxRetries {
                    try await Task.sleep(nanoseconds: UInt64(attempt * 1_000_000_000)) // Exponential backoff
                }
            }
        }
        
        throw lastError ?? AIServiceError.unknown
    }
    
    // MARK: - Testing
    
    func testProvider(_ provider: AIProvider) async throws -> Bool {
        guard let service = services[provider] else {
            throw AIServiceError.providerNotAvailable
        }
        
        return try await service.testConnection()
    }
    
    func testAllConfiguredProviders() async -> [AIProvider: Bool] {
        var results: [AIProvider: Bool] = [:]
        
        for provider in AIProvider.allCases {
            if isProviderConfigured(provider) {
                do {
                    results[provider] = try await testProvider(provider)
                } catch {
                    results[provider] = false
                }
            }
        }
        
        return results
    }
    
    // MARK: - Usage Statistics
    
    private func recordUsage(for provider: AIProvider, cost: Double) {
        let currentStats = usageStats[provider] ?? AIUsageStats()
        currentStats.requestCount += 1
        currentStats.totalCost += cost
        currentStats.lastUsed = Date()
        
        usageStats[provider] = currentStats
        saveUsageStats()
    }
    
    func getDailyUsage(for provider: AIProvider) -> AIUsageStats {
        guard let stats = usageStats[provider] else {
            return AIUsageStats()
        }
        
        let calendar = Calendar.current
        if let lastUsed = stats.lastUsed,
           calendar.isDateInToday(lastUsed) {
            return stats
        } else {
            // Reset daily stats
            let newStats = AIUsageStats()
            usageStats[provider] = newStats
            return newStats
        }
    }
    
    func canMakeRequest(for provider: AIProvider, userProfile: UserProfile) -> Bool {
        let preferences = userProfile.aiProviderPreferences
        let dailyUsage = getDailyUsage(for: provider)
        
        let estimatedNewCost = dailyUsage.totalCost + provider.estimatedCostPerRequest
        return estimatedNewCost <= preferences.maxDailyCost
    }
    
    private func saveUsageStats() {
        if let data = try? JSONEncoder().encode(usageStats) {
            UserDefaults.standard.set(data, forKey: "ai_usage_stats")
        }
    }
    
    private func loadUsageStats() {
        if let data = UserDefaults.standard.data(forKey: "ai_usage_stats"),
           let stats = try? JSONDecoder().decode([AIProvider: AIUsageStats].self, from: data) {
            usageStats = stats
        }
    }
    
    // MARK: - Helper Methods
    
    func hasConfiguredProvider() -> Bool {
        return AIProvider.allCases.contains { provider in
            isProviderConfigured(provider)
        }
    }
}

// MARK: - Supporting Types

class AIUsageStats: Codable, ObservableObject {
    @Published var requestCount: Int = 0
    @Published var totalCost: Double = 0.0
    @Published var lastUsed: Date?
    
    enum CodingKeys: CodingKey {
        case requestCount, totalCost, lastUsed
    }
    
    init() {}
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        requestCount = try container.decode(Int.self, forKey: .requestCount)
        totalCost = try container.decode(Double.self, forKey: .totalCost)
        lastUsed = try container.decodeIfPresent(Date.self, forKey: .lastUsed)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(requestCount, forKey: .requestCount)
        try container.encode(totalCost, forKey: .totalCost)
        try container.encodeIfPresent(lastUsed, forKey: .lastUsed)
    }
}

enum AIServiceError: LocalizedError {
    case providerNotAvailable
    case notConfigured
    case invalidAPIKey
    case networkError
    case dailyLimitExceeded
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .providerNotAvailable:
            return "選択されたAIプロバイダーは利用できません"
        case .notConfigured:
            return "AIプロバイダーが設定されていません"
        case .invalidAPIKey:
            return "無効なAPIキーです"
        case .networkError:
            return "ネットワークエラーが発生しました"
        case .dailyLimitExceeded:
            return "1日の使用制限に達しました"
        case .unknown:
            return "不明なエラーが発生しました"
        }
    }
}