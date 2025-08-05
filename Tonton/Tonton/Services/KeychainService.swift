//
//  KeychainService.swift
//  TonTon
//
//  Secure API key storage using iOS Keychain
//  Stores AI provider API keys safely
//

import Foundation
import Security

class KeychainService {
    static let shared = KeychainService()
    
    private let service = "com.delax.tonton"
    
    private init() {}
    
    func save(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // Delete existing item first
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return string
    }
    
    func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
    
    func deleteAll() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
    
    // MARK: - AI Provider API Keys
    
    func saveAPIKey(for provider: AIProvider, apiKey: String) -> Bool {
        return save(key: "api_key_\(provider.rawValue)", value: apiKey)
    }
    
    func loadAPIKey(for provider: AIProvider) -> String? {
        return load(key: "api_key_\(provider.rawValue)")
    }
    
    func deleteAPIKey(for provider: AIProvider) -> Bool {
        return delete(key: "api_key_\(provider.rawValue)")
    }
    
    func hasAPIKey(for provider: AIProvider) -> Bool {
        return loadAPIKey(for: provider) != nil
    }
    
    // MARK: - Validation
    
    func validateAPIKey(_ apiKey: String, for provider: AIProvider) -> Bool {
        // Basic validation - check format and length
        switch provider {
        case .gemini:
            return apiKey.hasPrefix("AIza") && apiKey.count > 30
        case .claude:
            return apiKey.hasPrefix("sk-ant-") && apiKey.count > 40
        case .openai:
            return apiKey.hasPrefix("sk-") && apiKey.count > 40
        }
    }
}