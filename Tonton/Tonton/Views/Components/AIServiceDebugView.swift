//
//  AIServiceDebugView.swift
//  TonTon
//
//  AI service diagnostic and configuration view
//  Helps debug AI analysis issues
//

import SwiftUI
import SwiftData

struct AIServiceDebugView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]
    @StateObject private var aiServiceManager = AIServiceManager()
    @State private var selectedProvider: AIProvider = .gemini
    @State private var apiKeyInput = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var testResults: [AIProvider: Bool] = [:]
    @State private var isTesting = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("現在の状態") {
                    statusSection
                }
                
                Section("プロバイダー設定") {
                    providerConfigSection
                }
                
                Section("診断テスト") {
                    diagnosticSection
                }
                
                Section("UserProfile情報") {
                    userProfileSection
                }
            }
            .navigationTitle("AI診断")
            .navigationBarTitleDisplayMode(.large)
            .alert("結果", isPresented: $showingAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    @ViewBuilder
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("設定済みプロバイダー")
                Spacer()
                Text("\(configuredProviders.count)/3")
                    .foregroundColor(.secondary)
            }
            
            ForEach(AIProvider.allCases, id: \.self) { provider in
                HStack {
                    Image(systemName: aiServiceManager.isProviderConfigured(provider) ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(aiServiceManager.isProviderConfigured(provider) ? .green : .red)
                    
                    Text(provider.displayName)
                    
                    Spacer()
                    
                    if let result = testResults[provider] {
                        Image(systemName: result ? "wifi" : "wifi.slash")
                            .foregroundColor(result ? .green : .red)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var providerConfigSection: some View {
        Picker("プロバイダー", selection: $selectedProvider) {
            ForEach(AIProvider.allCases, id: \.self) { provider in
                Text(provider.displayName).tag(provider)
            }
        }
        .pickerStyle(.segmented)
        
        HStack {
            TextField("APIキーを入力", text: $apiKeyInput)
                .textFieldStyle(.roundedBorder)
                .textContentType(.password)
            
            Button("保存") {
                saveAPIKey()
            }
            .disabled(apiKeyInput.isEmpty)
        }
        
        if aiServiceManager.isProviderConfigured(selectedProvider) {
            Button("設定を削除", role: .destructive) {
                removeConfiguration()
            }
        }
    }
    
    @ViewBuilder
    private var diagnosticSection: some View {
        Button("すべてのプロバイダーをテスト") {
            testAllProviders()
        }
        .disabled(isTesting || configuredProviders.isEmpty)
        
        if isTesting {
            HStack {
                ProgressView()
                    .scaleEffect(0.8)
                Text("テスト中...")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private var userProfileSection: some View {
        if let profile = userProfiles.first {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("選択されたプロバイダー")
                    Spacer()
                    Text(profile.aiProvider.displayName)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("最大リトライ回数")
                    Spacer()
                    Text("\(profile.aiProviderPreferences.maxRetries)")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("日次制限")
                    Spacer()
                    Text("¥\(String(format: "%.2f", profile.aiProviderPreferences.maxDailyCost))")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("フォールバック有効")
                    Spacer()
                    Text(profile.aiProviderPreferences.enableFallback ? "有効" : "無効")
                        .foregroundColor(.secondary)
                }
            }
        } else {
            Text("UserProfileが見つかりません")
                .foregroundColor(.red)
            
            Button("デフォルトプロファイルを作成") {
                createDefaultProfile()
            }
        }
    }
    
    // MARK: - Helper Properties
    
    private var configuredProviders: [AIProvider] {
        AIProvider.allCases.filter { aiServiceManager.isProviderConfigured($0) }
    }
    
    // MARK: - Actions
    
    private func saveAPIKey() {
        let success = aiServiceManager.configureProvider(selectedProvider, apiKey: apiKeyInput)
        if success {
            alertMessage = "\(selectedProvider.displayName)のAPIキーが正常に保存されました"
            apiKeyInput = ""
        } else {
            alertMessage = "APIキーの保存に失敗しました: \(aiServiceManager.errorMessage ?? "不明なエラー")"
        }
        showingAlert = true
    }
    
    private func removeConfiguration() {
        let success = aiServiceManager.removeProviderConfiguration(selectedProvider)
        alertMessage = success ? "設定が削除されました" : "設定の削除に失敗しました"
        showingAlert = true
    }
    
    private func testAllProviders() {
        isTesting = true
        Task {
            let results = await aiServiceManager.testAllConfiguredProviders()
            await MainActor.run {
                testResults = results
                isTesting = false
                
                let successCount = results.values.filter { $0 }.count
                alertMessage = "\(results.count)件のテスト完了。成功: \(successCount)件"
                showingAlert = true
            }
        }
    }
    
    private func createDefaultProfile() {
        let profile = UserProfile()
        profile.displayName = "デフォルトユーザー"
        profile.aiProvider = .gemini
        profile.aiProviderPreferences = AIProviderPreferences()
        
        modelContext.insert(profile)
        
        do {
            try modelContext.save()
            alertMessage = "デフォルトプロファイルが作成されました"
        } catch {
            alertMessage = "プロファイル作成に失敗しました: \(error.localizedDescription)"
        }
        showingAlert = true
    }
}

#Preview {
    AIServiceDebugView()
        .modelContainer(for: [UserProfile.self, MealRecord.self, WeightRecord.self, CalorieSavingsRecord.self, DailySummary.self])
}