//
//  AIProvider.swift
//  TonTon
//
//  AI Provider enumeration and configuration
//  Supports Gemini, Claude, and OpenAI selection
//

import Foundation

enum AIProvider: String, CaseIterable, Codable, Identifiable {
    case gemini = "gemini"
    case claude = "claude"
    case openai = "openai"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .gemini: return "Google Gemini"
        case .claude: return "Anthropic Claude"
        case .openai: return "OpenAI GPT"
        }
    }
    
    var shortName: String {
        switch self {
        case .gemini: return "Gemini"
        case .claude: return "Claude"
        case .openai: return "OpenAI"
        }
    }
    
    var iconName: String {
        switch self {
        case .gemini: return "star.fill"
        case .claude: return "brain.head.profile"
        case .openai: return "cpu.fill"
        }
    }
    
    var color: String {
        switch self {
        case .gemini: return "blue"
        case .claude: return "orange"
        case .openai: return "green"
        }
    }
    
    var description: String {
        switch self {
        case .gemini:
            return "Googleの最新AI。画像認識に優れ、高精度な食事分析が可能"
        case .claude:
            return "Anthropicの高性能AI。詳細な栄養分析と健康アドバイスが得意"
        case .openai:
            return "OpenAIの汎用AI。バランスの取れた食事分析と提案を提供"
        }
    }
    
    var modelName: String {
        switch self {
        case .gemini:
            return "gemini-pro-vision"
        case .claude:
            return "claude-3-5-sonnet-20241022"
        case .openai:
            return "gpt-4-vision-preview"
        }
    }
    
    var modelDisplayName: String {
        switch self {
        case .gemini:
            return "Gemini Pro Vision"
        case .claude:
            return "Claude 3.5 Sonnet"
        case .openai:
            return "GPT-4 Vision"
        }
    }
    
    var estimatedCostPerRequest: Double {
        switch self {
        case .gemini: return 0.002  // $0.002 per request (example)
        case .claude: return 0.003  // $0.003 per request (example)
        case .openai: return 0.004  // $0.004 per request (example)
        }
    }
    
    var maxImageSize: Int {
        switch self {
        case .gemini: return 4 * 1024 * 1024  // 4MB
        case .claude: return 5 * 1024 * 1024  // 5MB
        case .openai: return 3 * 1024 * 1024  // 3MB
        }
    }
    
    var supportedFeatures: [AIFeature] {
        switch self {
        case .gemini:
            return [.imageAnalysis, .nutritionAnalysis, .portionEstimation, .multiLanguage]
        case .claude:
            return [.imageAnalysis, .nutritionAnalysis, .healthAdvice, .multiLanguage]
        case .openai:
            return [.imageAnalysis, .nutritionAnalysis, .mealSuggestions, .multiLanguage]
        }
    }
}

enum AIFeature: String, CaseIterable {
    case imageAnalysis = "画像分析"
    case nutritionAnalysis = "栄養分析"
    case portionEstimation = "分量推定"
    case healthAdvice = "健康アドバイス"
    case mealSuggestions = "食事提案"
    case multiLanguage = "多言語対応"
}

struct AIProviderPreferences: Codable, Equatable {
    var fallbackProvider: AIProvider?
    var maxRetries: Int = 3
    var timeoutSeconds: Int = 30
    var enableFallback: Bool = true
    var logUsage: Bool = true
    var maxDailyCost: Double = 1.0  // Maximum daily cost in USD
    
    init() {}
}