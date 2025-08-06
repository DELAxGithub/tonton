//
//  OpenAIService.swift
//  TonTon
//
//  OpenAI GPT-4V service for meal image analysis
//  Handles image processing and nutrition analysis
//

import Foundation
import UIKit

class OpenAIService: AIProviderServiceProtocol {
    let provider: AIProvider = .openai
    
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    private let keychainService: KeychainService
    
    init(keychainService: KeychainService = KeychainService()) {
        self.keychainService = keychainService
    }
    
    var isConfigured: Bool {
        return keychainService.hasAPIKey(for: provider)
    }
    
    func analyzeMealImage(_ image: UIImage) async throws -> MealAnalysisResult {
        guard let apiKey = keychainService.loadAPIKey(for: provider) else {
            throw AIServiceError.notConfigured
        }
        
        // Resize and compress image
        guard let processedImage = processImage(image),
              let imageData = processedImage.jpegData(compressionQuality: 0.8) else {
            throw AIServiceError.unknown
        }
        
        let base64Image = imageData.base64EncodedString()
        let prompt = createMealAnalysisPrompt()
        let requestBody = createOpenAIRequest(imageBase64: base64Image, prompt: prompt)
        
        guard let url = URL(string: baseURL) else {
            throw AIServiceError.unknown
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIServiceError.networkError
        }
        
        guard httpResponse.statusCode == 200 else {
            throw AIServiceError.networkError
        }
        
        return try parseOpenAIResponse(data)
    }
    
    func testConnection() async throws -> Bool {
        guard let apiKey = keychainService.loadAPIKey(for: provider) else {
            throw AIServiceError.notConfigured
        }
        
        // Simple test request
        guard let url = URL(string: baseURL) else { return false }
        
        let testRequest: [String: Any] = [
            "model": "gpt-4-vision-preview",
            "messages": [
                [
                    "role": "user",
                    "content": "Hello"
                ]
            ],
            "max_tokens": 10
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: testRequest)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            return httpResponse.statusCode == 200
        }
        
        return false
    }
    
    func estimateCost(for imageSize: Int) -> Double {
        return provider.estimatedCostPerRequest
    }
    
    // MARK: - Private Methods
    
    private func processImage(_ image: UIImage) -> UIImage? {
        // Similar to other services
        let maxSize: CGFloat = 1024
        let size = image.size
        
        if size.width <= maxSize && size.height <= maxSize {
            return image
        }
        
        let aspectRatio = size.width / size.height
        var newSize: CGSize
        
        if aspectRatio > 1 {
            newSize = CGSize(width: maxSize, height: maxSize / aspectRatio)
        } else {
            newSize = CGSize(width: maxSize * aspectRatio, height: maxSize)
        }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
    
    private func createMealAnalysisPrompt() -> String {
        return """
        この食事の画像を分析して、以下の情報をJSON形式で提供してください：

        {
            "meal_name": "料理名（日本語）",
            "description": "料理の詳細説明（日本語）",
            "calories": 推定カロリー数値,
            "protein": たんぱく質グラム数,
            "fat": 脂質グラム数,
            "carbs": 炭水化物グラム数,
            "confidence": 分析の信頼度（0-1）
        }

        栄養学的に正確な情報を提供し、健康的な食事管理をサポートしてください。
        """
    }
    
    private func createOpenAIRequest(imageBase64: String, prompt: String) -> [String: Any] {
        return [
            "model": "gpt-4-vision-preview",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": prompt
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(imageBase64)"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 1024,
            "temperature": 0.1
        ]
    }
    
    private func parseOpenAIResponse(_ data: Data) throws -> MealAnalysisResult {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AIServiceError.unknown
        }
        
        // Extract JSON from text response
        guard let jsonData = extractJSON(from: content)?.data(using: .utf8),
              let mealData = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            throw AIServiceError.unknown
        }
        
        let mealName = mealData["meal_name"] as? String ?? "不明な料理"
        let description = mealData["description"] as? String ?? ""
        let calories = mealData["calories"] as? Double ?? 0
        let protein = mealData["protein"] as? Double ?? 0
        let fat = mealData["fat"] as? Double ?? 0
        let carbs = mealData["carbs"] as? Double ?? 0
        let confidence = mealData["confidence"] as? Double ?? 0.5
        
        return MealAnalysisResult(
            mealName: mealName,
            description: description,
            calories: calories,
            protein: protein,
            fat: fat,
            carbs: carbs,
            confidence: confidence,
            provider: provider
        )
    }
    
    private func extractJSON(from text: String) -> String? {
        let pattern = #"\{[\s\S]*\}"#
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        
        if let match = regex?.firstMatch(in: text, range: range) {
            return String(text[Range(match.range, in: text)!])
        }
        
        return nil
    }
}