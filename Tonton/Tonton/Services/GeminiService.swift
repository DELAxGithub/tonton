//
//  GeminiService.swift
//  TonTon
//
//  Google Gemini AI service for meal image analysis
//  Handles image processing and nutrition analysis
//

import Foundation
import UIKit

class GeminiService: AIProviderServiceProtocol {
    let provider: AIProvider = .gemini
    
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"
    private let keychainService: KeychainService
    
    init(keychainService: KeychainService = KeychainService()) {
        self.keychainService = keychainService
    }
    
    var isConfigured: Bool {
        return keychainService.hasAPIKey(for: provider)
    }
    
    func analyzeMealImage(_ image: UIImage) async throws -> MealAnalysisResult {
        print("🔥 GeminiService.analyzeMealImage called")
        
        guard let apiKey = keychainService.loadAPIKey(for: provider) else {
            print("❌ Gemini API key not found in keychain")
            throw AIServiceError.notConfigured
        }
        
        print("✅ Gemini API key loaded successfully")
        
        // Resize and compress image
        print("🖼️ Processing image...")
        guard let processedImage = processImage(image),
              let imageData = processedImage.jpegData(compressionQuality: 0.8) else {
            print("❌ Image processing failed")
            throw AIServiceError.unknown
        }
        
        let imageSizeKB = imageData.count / 1024
        print("✅ Image processed successfully (\(imageSizeKB)KB)")
        
        let base64Image = imageData.base64EncodedString()
        print("✅ Image encoded to base64")
        
        let prompt = createMealAnalysisPrompt()
        let requestBody = createGeminiRequest(imageBase64: base64Image, prompt: prompt)
        
        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
            print("❌ Failed to create URL")
            throw AIServiceError.unknown
        }
        
        print("🌐 Sending request to Gemini API (gemini-1.5-flash)...")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 45.0
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        print("📦 Request body size: \((request.httpBody?.count ?? 0) / 1024)KB")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid HTTP response")
            throw AIServiceError.networkError
        }
        
        print("📡 Received response with status code: \(httpResponse.statusCode)")
        
        guard httpResponse.statusCode == 200 else {
            if let errorData = String(data: data, encoding: .utf8) {
                print("❌ Gemini API Error Response: \(errorData)")
            }
            print("❌ HTTP Status Code: \(httpResponse.statusCode)")
            if httpResponse.statusCode == 429 {
                throw AIServiceError.dailyLimitExceeded
            } else if httpResponse.statusCode == 401 {
                throw AIServiceError.invalidAPIKey
            } else {
                throw AIServiceError.networkError
            }
        }
        
        print("✅ Successfully received response from Gemini API")
        print("📊 Response data size: \(data.count) bytes")
        
        let result = try parseGeminiResponse(data)
        print("✅ Gemini analysis completed: \(result.mealName)")
        return result
    }
    
    func testConnection() async throws -> Bool {
        guard let apiKey = keychainService.loadAPIKey(for: provider) else {
            throw AIServiceError.notConfigured
        }
        
        // Simple test request with timeout
        let testURL = "https://generativelanguage.googleapis.com/v1beta/models?key=\(apiKey)"
        guard let url = URL(string: testURL) else { return false }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 15.0  // Shorter timeout for connection test
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            }
        } catch {
            print("❌ Gemini connection test failed: \(error)")
            throw AIServiceError.networkError
        }
        
        return false
    }
    
    func estimateCost(for imageSize: Int) -> Double {
        // Gemini pricing estimation (example)
        return provider.estimatedCostPerRequest
    }
    
    // MARK: - Private Methods
    
    private func processImage(_ image: UIImage) -> UIImage? {
        let maxSize: CGFloat = 1024
        let size = image.size
        
        // Check if resizing is needed
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
        
        // Use UIGraphicsImageRenderer for better memory efficiency
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
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

        注意：
        - 数値は正確に推定してください
        - 料理名と説明は日本語で提供してください
        - 複数の料理が写っている場合は、主要な料理を分析してください
        - 信頼度は画像の鮮明さと料理の認識しやすさに基づいて設定してください
        """
    }
    
    private func createGeminiRequest(imageBase64: String, prompt: String) -> [String: Any] {
        return [
            "contents": [
                [
                    "parts": [
                        [
                            "text": prompt
                        ],
                        [
                            "inline_data": [
                                "mime_type": "image/jpeg",
                                "data": imageBase64
                            ]
                        ]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.1,
                "topK": 32,
                "topP": 1,
                "maxOutputTokens": 1024
            ]
        ]
    }
    
    private func parseGeminiResponse(_ data: Data) throws -> MealAnalysisResult {
        print("🔍 Parsing Gemini API response...")
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            print("❌ Failed to parse JSON response")
            throw AIServiceError.unknown
        }
        
        // Check for API errors first
        if let error = json["error"] as? [String: Any] {
            let message = error["message"] as? String ?? "Unknown error"
            print("❌ Gemini API returned error: \(message)")
            throw AIServiceError.networkError
        }
        
        guard let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            print("❌ Invalid response structure from Gemini API")
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 Raw response: \(responseString.prefix(500))")
            }
            throw AIServiceError.unknown
        }
        
        print("📄 Gemini response text: \(text.prefix(200))...")
        
        // Extract JSON from text response
        guard let jsonData = extractJSON(from: text)?.data(using: .utf8) else {
            print("❌ Failed to extract JSON from response text")
            throw AIServiceError.unknown
        }
        
        guard let mealData = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            print("❌ Failed to parse meal data JSON")
            throw AIServiceError.unknown
        }
        
        print("✅ Successfully parsed meal data JSON")
        
        // Parse with better error handling
        let mealName = mealData["meal_name"] as? String ?? "不明な料理"
        let description = mealData["description"] as? String ?? ""
        
        // Handle numeric values more robustly
        let calories = parseNumericValue(mealData["calories"]) ?? 0
        let protein = parseNumericValue(mealData["protein"]) ?? 0
        let fat = parseNumericValue(mealData["fat"]) ?? 0
        let carbs = parseNumericValue(mealData["carbs"]) ?? 0
        let confidence = parseNumericValue(mealData["confidence"]) ?? 0.5
        
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
    
    private func parseNumericValue(_ value: Any?) -> Double? {
        if let doubleValue = value as? Double {
            return doubleValue
        } else if let intValue = value as? Int {
            return Double(intValue)
        } else if let stringValue = value as? String {
            return Double(stringValue)
        }
        return nil
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