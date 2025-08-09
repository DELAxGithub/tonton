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
    private let service = "com.delax.tonton"
    private var isInitialized = false
    private var initializationError: String?
    
    init() {
        initialize()
    }
    
    private func initialize() {
        do {
            // Test keychain accessibility by attempting a safe operation
            let testQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecMatchLimit as String: kSecMatchLimitOne
            ]
            
            var result: AnyObject?
            let status = SecItemCopyMatching(testQuery as CFDictionary, &result)
            
            // If keychain is accessible (even if no items found), we're initialized
            if status == errSecSuccess || status == errSecItemNotFound {
                isInitialized = true
                initializationError = nil
            } else {
                throw KeychainError.unknown(status)
            }
        } catch {
            initializationError = error.localizedDescription
            isInitialized = false
            print("[KeychainService] Initialization failed: \(error)")
        }
    }
    
    private func ensureInitialized() throws {
        guard isInitialized else {
            throw KeychainError.notInitialized
        }
    }
    
    func save(key: String, value: String) -> Bool {
        do {
            try ensureInitialized()
        } catch {
            print("[KeychainService] Save failed: \(error)")
            return false
        }
        
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
        do {
            try ensureInitialized()
        } catch {
            print("[KeychainService] Load failed: \(error)")
            return nil
        }
        
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
        do {
            try ensureInitialized()
        } catch {
            print("[KeychainService] Delete failed: \(error)")
            return false
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
    
    func deleteAll() -> Bool {
        do {
            try ensureInitialized()
        } catch {
            print("[KeychainService] DeleteAll failed: \(error)")
            return false
        }
        
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

// MARK: - Keychain Error Types

enum KeychainError: LocalizedError {
    case notInitialized
    case accessDenied
    case itemNotFound
    case duplicateItem
    case unknown(OSStatus)
    
    var errorDescription: String? {
        switch self {
        case .notInitialized:
            return "キーチェーンサービスが初期化されていません"
        case .accessDenied:
            return "キーチェーンへのアクセスが拒否されました"
        case .itemNotFound:
            return "キーチェーン項目が見つかりません"
        case .duplicateItem:
            return "キーチェーンに重複した項目があります"
        case .unknown(let status):
            return "不明なキーチェーンエラー: \(status)"
        }
    }
}