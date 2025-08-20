//
//  AISettingsView.swift
//  TonTon
//
//  AI provider configuration and management screen
//  Allows users to select and configure Gemini, Claude, and OpenAI
//

import SwiftUI
import SwiftData

struct AISettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var userProfiles: [UserProfile]
    
    @StateObject private var aiManager = AIServiceManager()
    @State private var showingAPIKeyInput = false
    @State private var selectedProviderForSetup: AIProvider?
    @State private var showingConnectionTest = false
    @State private var testResults: [AIProvider: Bool] = [:]
    private let keychainService = KeychainService()
    
    private var currentUserProfile: UserProfile? {
        userProfiles.first
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Current provider section
                    currentProviderSection
                    
                    // Provider selection section
                    providerSelectionSection
                    
                    // Provider configuration section
                    providerConfigurationSection
                    
                    // Usage statistics section
                    usageStatisticsSection
                    
                    // Advanced settings section
                    advancedSettingsSection
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
            }
            .navigationTitle("AI設定")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("テスト") {
                        testAllConnections()
                    }
                    .disabled(showingConnectionTest)
                }
            }
            .sheet(isPresented: $showingAPIKeyInput) {
                APIKeyInputView(
                    provider: selectedProviderForSetup ?? .gemini,
                    aiManager: aiManager,
                    keychainService: keychainService
                )
            }
            .alert("接続テスト結果", isPresented: $showingConnectionTest) {
                Button("了解") { }
            } message: {
                Text(testResultsMessage)
            }
        }
    }
    
    @ViewBuilder
    private var currentProviderSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("現在のAIプロバイダー")
                    .font(.headline)
                Spacer()
            }
            
            if let profile = currentUserProfile {
                CurrentProviderCard(
                    provider: profile.aiProvider,
                    isConfigured: aiManager.isProviderConfigured(profile.aiProvider)
                )
            }
        }
    }
    
    @ViewBuilder
    private var providerSelectionSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("AIプロバイダー選択")
                    .font(.headline)
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(AIProvider.allCases) { provider in
                    ProviderSelectionCard(
                        provider: provider,
                        isSelected: currentUserProfile?.aiProvider == provider,
                        isConfigured: aiManager.isProviderConfigured(provider)
                    ) {
                        selectProvider(provider)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var providerConfigurationSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("プロバイダー設定")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(AIProvider.allCases) { provider in
                    ProviderConfigurationRow(
                        provider: provider,
                        isConfigured: aiManager.isProviderConfigured(provider),
                        testResult: testResults[provider]
                    ) {
                        configureProvider(provider)
                    } onRemove: {
                        removeProviderConfiguration(provider)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
        }
    }
    
    @ViewBuilder
    private var usageStatisticsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("使用統計")
                    .font(.headline)
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(AIProvider.allCases) { provider in
                    let stats = aiManager.getDailyUsage(for: provider)
                    UsageStatsCard(provider: provider, stats: stats)
                }
            }
        }
    }
    
    @ViewBuilder
    private var advancedSettingsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("詳細設定")
                    .font(.headline)
                Spacer()
            }
            
            if let profile = currentUserProfile {
                AdvancedSettingsCard(profile: profile, modelContext: modelContext)
            }
        }
    }
    
    // MARK: - Actions
    
    private func selectProvider(_ provider: AIProvider) {
        guard let profile = currentUserProfile else { return }
        
        if aiManager.isProviderConfigured(provider) {
            profile.aiProvider = provider
            aiManager.setCurrentProvider(provider)
            try? modelContext.save()
        } else {
            selectedProviderForSetup = provider
            showingAPIKeyInput = true
        }
    }
    
    private func configureProvider(_ provider: AIProvider) {
        selectedProviderForSetup = provider
        showingAPIKeyInput = true
    }
    
    private func removeProviderConfiguration(_ provider: AIProvider) {
        _ = aiManager.removeProviderConfiguration(provider)
        testResults[provider] = nil
    }
    
    private func testAllConnections() {
        showingConnectionTest = true
        Task {
            testResults = await aiManager.testAllConfiguredProviders()
        }
    }
    
    private var testResultsMessage: String {
        var message = ""
        for (provider, result) in testResults {
            let status = result ? "✅" : "❌"
            message += "\(provider.displayName): \(status)\n"
        }
        return message.isEmpty ? "設定されたプロバイダーがありません" : message
    }
}

// MARK: - Supporting Views

struct CurrentProviderCard: View {
    let provider: AIProvider
    let isConfigured: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: provider.iconName)
                .font(.title)
                .foregroundColor(Color(provider.color))
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(provider.displayName)
                    .font(.headline)
                
                Text(isConfigured ? "設定済み" : "未設定")
                    .font(.subheadline)
                    .foregroundColor(isConfigured ? .green : .red)
            }
            
            Spacer()
            
            if isConfigured {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color.green)
            } else {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

struct ProviderSelectionCard: View {
    let provider: AIProvider
    let isSelected: Bool
    let isConfigured: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: provider.iconName)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : Color(provider.color))
                
                Text(provider.shortName)
                    .font(.caption)
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundColor(isSelected ? .white : .primary)
                
                if !isConfigured {
                    Text("未設定")
                        .font(.caption2)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .red)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color(provider.color) : Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ProviderConfigurationRow: View {
    let provider: AIProvider
    let isConfigured: Bool
    let testResult: Bool?
    let onConfigure: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: provider.iconName)
                .font(.title3)
                .foregroundColor(Color(provider.color))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(provider.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    Text(isConfigured ? "設定済み" : "未設定")
                        .font(.caption)
                        .foregroundColor(isConfigured ? .green : .secondary)
                    
                    if let result = testResult {
                        Text(result ? "接続OK" : "接続エラー")
                            .font(.caption)
                            .foregroundColor(result ? .green : .red)
                    }
                }
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Button(action: onConfigure) {
                    Text(isConfigured ? "編集" : "設定")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                if isConfigured {
                    Button(action: onRemove) {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

struct UsageStatsCard: View {
    let provider: AIProvider
    let stats: AIUsageStats
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: provider.iconName)
                    .foregroundColor(Color(provider.color))
                Text(provider.shortName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("今日の使用:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(stats.requestCount)回")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("推定コスト:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("$\(String(format: "%.3f", stats.totalCost))")
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

struct AdvancedSettingsCard: View {
    let profile: UserProfile
    let modelContext: ModelContext
    
    @State private var preferences: AIProviderPreferences
    
    init(profile: UserProfile, modelContext: ModelContext) {
        self.profile = profile
        self.modelContext = modelContext
        self._preferences = State(initialValue: profile.aiProviderPreferences)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Fallback provider
            HStack {
                Text("フォールバックプロバイダー")
                    .font(.subheadline)
                Spacer()
                
                Picker("Fallback", selection: Binding(
                    get: { preferences.fallbackProvider ?? .gemini },
                    set: { preferences.fallbackProvider = $0 }
                )) {
                    ForEach(AIProvider.allCases) { provider in
                        Text(provider.shortName).tag(provider)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            
            // Daily cost limit
            HStack {
                Text("1日のコスト上限")
                    .font(.subheadline)
                Spacer()
                
                HStack {
                    Text("$")
                    TextField("1.00", value: Binding(
                        get: { preferences.maxDailyCost },
                        set: { preferences.maxDailyCost = $0 }
                    ), format: .number.precision(.fractionLength(2)))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
                }
            }
            
            // Enable fallback toggle
            Toggle("フォールバック有効", isOn: Binding(
                get: { preferences.enableFallback },
                set: { preferences.enableFallback = $0 }
            ))
            
            // Usage logging toggle
            Toggle("使用ログ記録", isOn: Binding(
                get: { preferences.logUsage },
                set: { preferences.logUsage = $0 }
            ))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .onChange(of: preferences) { _, newValue in
            profile.aiProviderPreferences = newValue
            try? modelContext.save()
        }
    }
}

#Preview {
    AISettingsView()
        .modelContainer(for: [UserProfile.self, MealRecord.self, WeightRecord.self, CalorieSavingsRecord.self, DailySummary.self])
}