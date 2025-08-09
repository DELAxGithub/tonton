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

struct MealAnalysisResult: Identifiable {
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

    var id: String { requestId }
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
        print("🚀 AIServiceManager.analyzeMealImage called")
        isAnalyzing = true
        errorMessage = nil
        
        defer { 
            isAnalyzing = false 
            print("🏁 AIServiceManager analysis completed")
        }
        
        let provider = userProfile.aiProvider
        let preferences = userProfile.aiProviderPreferences
        
        print("📋 Using provider: \(provider.displayName)")
        print("⚙️ Preferences - maxRetries: \(preferences.maxRetries), enableFallback: \(preferences.enableFallback)")
        
        // Check daily usage limit before making request
        if !canMakeRequest(for: provider, userProfile: userProfile) {
            print("❌ Daily cost limit exceeded for \(provider.displayName)")
            errorMessage = "日々の使用制限に達しました"
            throw AIServiceError.dailyLimitExceeded
        }
        
        do {
            let result = try await performAnalysis(image, provider: provider, preferences: preferences)
            lastAnalysisResult = result
            lastUsedDate = Date()
            recordUsage(for: provider, cost: provider.estimatedCostPerRequest)
            print("✅ Analysis successful with \(provider.displayName)")
            return result
        } catch {
            print("❌ Primary provider \(provider.displayName) failed: \(error)")
            
            // Try fallback if enabled and the error is not rate limiting
            if preferences.enableFallback, 
               let fallbackProvider = preferences.fallbackProvider,
               fallbackProvider != provider,
               !isNonFallbackError(error) {
                
                // Check fallback provider's daily limit
                if !canMakeRequest(for: fallbackProvider, userProfile: userProfile) {
                    print("❌ Fallback provider \(fallbackProvider.displayName) daily limit also exceeded")
                    errorMessage = "メイン及びフォールバックプロバイダーで日々の制限に達しました"
                    throw AIServiceError.dailyLimitExceeded
                }
                
                print("🔄 Trying fallback provider: \(fallbackProvider.displayName)")
                do {
                    let result = try await performAnalysis(image, provider: fallbackProvider, preferences: preferences)
                    lastAnalysisResult = result
                    lastUsedDate = Date()
                    recordUsage(for: fallbackProvider, cost: fallbackProvider.estimatedCostPerRequest)
                    print("✅ Fallback analysis successful with \(fallbackProvider.displayName)")
                    return result
                } catch {
                    print("❌ Fallback provider \(fallbackProvider.displayName) also failed: \(error)")
                    errorMessage = "メイン及びフォールバックプロバイダーでエラーが発生しました"
                    throw error
                }
            } else {
                if isNonFallbackError(error) {
                    print("❌ Non-fallback error, skipping fallback: \(error)")
                }
                errorMessage = getLocalizedErrorMessage(error)
                throw error
            }
        }
    }
    
    private func isNonFallbackError(_ error: Error) -> Bool {
        // Don't try fallback for these errors
        if let aiError = error as? AIServiceError {
            switch aiError {
            case .dailyLimitExceeded, .invalidAPIKey, .notConfigured:
                return true
            case .networkError, .unknown, .providerNotAvailable:
                return false
            }
        }
        return false
    }
    
    private func getLocalizedErrorMessage(_ error: Error) -> String {
        if let aiError = error as? AIServiceError {
            return aiError.localizedDescription
        } else if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut:
                return "タイムアウトが発生しました"
            case .notConnectedToInternet:
                return "インターネット接続がありません"
            case .cannotConnectToHost:
                return "サーバーに接続できません"
            default:
                return "ネットワークエラーが発生しました"
            }
        }
        return error.localizedDescription
    }
    
    private func performAnalysis(_ image: UIImage, provider: AIProvider, preferences: AIProviderPreferences) async throws -> MealAnalysisResult {
        print("🔧 performAnalysis called for \(provider.displayName)")
        
        guard let service = services[provider] else {
            print("❌ Service not available for \(provider.displayName)")
            throw AIServiceError.providerNotAvailable
        }
        
        print("🔍 Checking if \(provider.displayName) service is configured...")
        guard service.isConfigured else {
            print("❌ \(provider.displayName) service not configured")
            throw AIServiceError.notConfigured
        }
        
        print("✅ \(provider.displayName) service is configured, starting analysis...")
        
        // Enhanced retry logic with exponential backoff and jitter
        var lastError: Error?
        for attempt in 1...preferences.maxRetries {
            print("🔄 Attempt \(attempt)/\(preferences.maxRetries) for \(provider.displayName)")
            do {
                let result = try await service.analyzeMealImage(image)
                print("✅ \(provider.displayName) analysis successful on attempt \(attempt)")
                return result
            } catch AIServiceError.dailyLimitExceeded {
                print("❌ Daily limit exceeded for \(provider.displayName) - not retrying")
                throw AIServiceError.dailyLimitExceeded
            } catch AIServiceError.invalidAPIKey {
                print("❌ Invalid API key for \(provider.displayName) - not retrying")
                throw AIServiceError.invalidAPIKey
            } catch {
                print("❌ \(provider.displayName) attempt \(attempt) failed: \(error)")
                lastError = error
                
                // Only retry on network errors or unknown errors
                if attempt < preferences.maxRetries && isRetryableError(error) {
                    // Exponential backoff with jitter: base delay * 2^(attempt-1) + random jitter
                    let baseDelay = 1.0 // 1 second
                    let exponentialDelay = baseDelay * pow(2.0, Double(attempt - 1))
                    let jitter = Double.random(in: 0...0.5) // Up to 500ms jitter
                    let totalDelay = min(exponentialDelay + jitter, 10.0) // Max 10 seconds
                    
                    print("⏳ Waiting \(String(format: "%.1f", totalDelay)) seconds before retry...")
                    try await Task.sleep(nanoseconds: UInt64(totalDelay * 1_000_000_000))
                } else if !isRetryableError(error) {
                    print("❌ Non-retryable error for \(provider.displayName): \(error)")
                    break
                }
            }
        }
        
        print("❌ All attempts failed for \(provider.displayName)")
        throw lastError ?? AIServiceError.unknown
    }
    
    private func isRetryableError(_ error: Error) -> Bool {
        // Only retry on network errors and unknown errors
        if let aiError = error as? AIServiceError {
            switch aiError {
            case .networkError, .unknown:
                return true
            case .dailyLimitExceeded, .invalidAPIKey, .notConfigured, .providerNotAvailable:
                return false
            }
        }
        
        // For URLError, only retry on network-related issues
        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut, .cannotConnectToHost, .networkConnectionLost, .notConnectedToInternet:
                return true
            default:
                return false
            }
        }
        
        return false
    }
    
    // MARK: - Testing
    
    func testProvider(_ provider: AIProvider) async throws -> Bool {
        guard let service = services[provider] else {
            throw AIServiceError.providerNotAvailable
        }
        
        return try await service.testConnection()
    }
    
    func performSimpleTest(for provider: AIProvider) async throws -> AITestResult {
        guard let service = services[provider] else {
            throw AIServiceError.providerNotAvailable
        }
        
        guard service.isConfigured else {
            throw AIServiceError.notConfigured
        }
        
        let startTime = Date()
        
        // Create a simple test image (solid color square)
        let testImage = createTestImage()
        
        do {
            _ = try await service.analyzeMealImage(testImage)
            let responseTime = Date().timeIntervalSince(startTime)
            
            return AITestResult(
                success: true,
                provider: provider,
                responseTime: responseTime,
                testMessage: "テスト画像を正常に分析できました",
                errorMessage: nil,
                timestamp: Date()
            )
        } catch {
            let responseTime = Date().timeIntervalSince(startTime)
            return AITestResult(
                success: false,
                provider: provider,
                responseTime: responseTime,
                testMessage: nil,
                errorMessage: error.localizedDescription,
                timestamp: Date()
            )
        }
    }
    
    private func createTestImage() -> UIImage {
        let size = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            // Create a simple colored square for testing
            UIColor.systemBlue.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Add some text to make it more recognizable as a test
            let text = "TEST"
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 20, weight: .bold)
            ]
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            text.draw(in: textRect, withAttributes: attributes)
        }
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

struct AITestResult {
    let success: Bool
    let provider: AIProvider
    let responseTime: TimeInterval
    let testMessage: String?
    let errorMessage: String?
    let timestamp: Date
    
    var responseTimeFormatted: String {
        return String(format: "%.2f秒", responseTime)
    }
}

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