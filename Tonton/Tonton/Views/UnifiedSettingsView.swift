//
//  UnifiedSettingsView.swift
//  TonTon
//
//  Unified settings interface combining AI, HealthKit, and CloudKit configurations
//  Central hub for all TonTon service integrations and preferences
//

import SwiftUI
import SwiftData

struct UnifiedSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var userProfiles: [UserProfile]
    
    @EnvironmentObject private var aiManager: AIServiceManager
    @EnvironmentObject private var healthKitService: HealthKitService
    @EnvironmentObject private var cloudKitService: CloudKitService
    
    @State private var selectedTab: SettingsTab = .overview
    @State private var showingAISettings = false
    @State private var showingHealthKitSettings = false
    @State private var showingCloudKitSettings = false
    @State private var isPerformingFullSync = false
    @State private var syncError: String?
    @State private var showingSyncError = false
    
    private var currentUserProfile: UserProfile? {
        userProfiles.first
    }
    
    enum SettingsTab: String, CaseIterable {
        case overview = "概要"
        case services = "サービス"
        case sync = "同期"
        case preferences = "設定"
        
        var icon: String {
            switch self {
            case .overview: return "house"
            case .services: return "gear.badge"
            case .sync: return "arrow.triangle.2.circlepath"
            case .preferences: return "slider.horizontal.3"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab selector
                tabSelector
                
                // Content based on selected tab
                ScrollView {
                    VStack(spacing: 24) {
                        switch selectedTab {
                        case .overview:
                            overviewContent
                        case .services:
                            servicesContent
                        case .sync:
                            syncContent
                        case .preferences:
                            preferencesContent
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("統合設定")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("全同期") {
                        performFullSync()
                    }
                    .disabled(isPerformingFullSync || !allServicesReady)
                }
            }
            .sheet(isPresented: $showingAISettings) {
                AISettingsView()
            }
            .sheet(isPresented: $showingHealthKitSettings) {
                HealthKitSettingsView()
            }
            .sheet(isPresented: $showingCloudKitSettings) {
                CloudKitSettingsView()
            }
            .alert("同期エラー", isPresented: $showingSyncError) {
                Button("了解") { }
            } message: {
                Text(syncError ?? "不明なエラーが発生しました")
            }
        }
        .onAppear {
            Task {
                await refreshServiceStatus()
            }
        }
    }
    
    @ViewBuilder
    private var tabSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(SettingsTab.allCases, id: \.self) { tab in
                    Button(action: {
                        selectedTab = tab
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: tab.icon)
                                .font(.caption)
                            
                            Text(tab.rawValue)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(selectedTab == tab ? Color.accentColor : Color(.systemGray5))
                        )
                        .foregroundColor(selectedTab == tab ? .white : .primary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
    
    @ViewBuilder
    private var overviewContent: some View {
        VStack(spacing: 20) {
            // System status overview
            SystemStatusCard(
                aiStatus: getAIStatus(),
                healthKitStatus: getHealthKitStatus(),
                cloudKitStatus: getCloudKitStatus(),
                lastSyncDate: getLastSyncDate()
            )
            
            // Quick actions
            QuickActionsCard(
                onAISettings: { showingAISettings = true },
                onHealthKitSettings: { showingHealthKitSettings = true },
                onCloudKitSettings: { showingCloudKitSettings = true },
                onFullSync: performFullSync,
                isAllReady: allServicesReady,
                isSyncing: isPerformingFullSync
            )
            
            // Integration health
            IntegrationHealthCard(
                aiManager: aiManager,
                healthKitService: healthKitService,
                cloudKitService: cloudKitService
            )
        }
    }
    
    @ViewBuilder
    private var servicesContent: some View {
        VStack(spacing: 20) {
            // AI Services
            ServiceConfigurationCard(
                title: "AI サービス",
                description: "食事分析用AIプロバイダーの設定",
                icon: "brain",
                color: .purple,
                status: getAIStatus(),
                isConfigured: aiManager.hasConfiguredProvider(),
                onConfigure: { showingAISettings = true }
            )
            
            // HealthKit
            ServiceConfigurationCard(
                title: "HealthKit",
                description: "体重・カロリーデータ連携",
                icon: "heart",
                color: .red,
                status: getHealthKitStatus(),
                isConfigured: healthKitService.isAuthorized,
                onConfigure: { showingHealthKitSettings = true }
            )
            
            // CloudKit
            ServiceConfigurationCard(
                title: "iCloud同期",
                description: "データのクラウド同期",
                icon: "icloud",
                color: .blue,
                status: getCloudKitStatus(),
                isConfigured: cloudKitService.isSignedIn,
                onConfigure: { showingCloudKitSettings = true }
            )
        }
    }
    
    @ViewBuilder
    private var syncContent: some View {
        VStack(spacing: 20) {
            // Sync overview
            SyncOverviewCard(
                isPerformingSync: isPerformingFullSync,
                lastSyncDate: getLastSyncDate(),
                onFullSync: performFullSync,
                isAllReady: allServicesReady
            )
            
            // Individual sync controls
            IndividualSyncCard(
                aiManager: aiManager,
                healthKitService: healthKitService,
                cloudKitService: cloudKitService,
                modelContext: modelContext
            )
            
            // Sync history
            SyncHistoryCard(
                aiLastUsed: aiManager.lastUsedDate,
                healthKitLastSync: healthKitService.lastSyncDate,
                cloudKitLastSync: cloudKitService.lastSyncDate
            )
        }
    }
    
    @ViewBuilder
    private var preferencesContent: some View {
        VStack(spacing: 20) {
            if let profile = currentUserProfile {
                // General preferences
                GeneralPreferencesCard(
                    profile: profile,
                    modelContext: modelContext
                )
                
                // AI preferences
                AIPreferencesCard(
                    profile: profile,
                    modelContext: modelContext
                )
                
                // Privacy preferences
                PrivacyPreferencesCard(
                    profile: profile,
                    modelContext: modelContext
                )
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private var allServicesReady: Bool {
        aiManager.hasConfiguredProvider() &&
        healthKitService.isAuthorized &&
        cloudKitService.isSignedIn
    }
    
    private func getAIStatus() -> String {
        if aiManager.hasConfiguredProvider() {
            return "設定済み"
        } else {
            return "未設定"
        }
    }
    
    private func getHealthKitStatus() -> String {
        return healthKitService.authorizationStatus
    }
    
    private func getCloudKitStatus() -> String {
        return cloudKitService.userAccountStatus
    }
    
    private func getLastSyncDate() -> Date? {
        let dates = [
            aiManager.lastUsedDate,
            healthKitService.lastSyncDate,
            cloudKitService.lastSyncDate
        ].compactMap { $0 }
        
        return dates.max()
    }
    
    private func refreshServiceStatus() async {
        await healthKitService.initialize()
        await cloudKitService.initialize()
    }
    
    private func performFullSync() {
        isPerformingFullSync = true
        
        Task {
            do {
                // Sync all services in sequence
                if healthKitService.isAuthorized {
                    if !healthKitService.isInitialized {
                        await healthKitService.initialize()
                    }
                    try await healthKitService.syncWeightData(with: modelContext)
                    try await healthKitService.syncCalorieData(with: modelContext)
                }
                
                if cloudKitService.isSignedIn {
                    if !cloudKitService.isInitialized {
                        await cloudKitService.initialize()
                    }
                    try await cloudKitService.syncAllData(with: modelContext)
                }
                
            } catch {
                await MainActor.run {
                    syncError = error.localizedDescription
                    showingSyncError = true
                }
            }
            
            await MainActor.run {
                isPerformingFullSync = false
            }
        }
    }
}

// MARK: - Supporting Views

struct SystemStatusCard: View {
    let aiStatus: String
    let healthKitStatus: String
    let cloudKitStatus: String
    let lastSyncDate: Date?
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("システム状態")
                    .font(.headline)
                Spacer()
                
                if let lastSync = lastSyncDate {
                    Text("最終同期: \(formatRelativeDate(lastSync))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatusIndicator(
                    title: "AI",
                    status: aiStatus,
                    color: aiStatus == "設定済み" ? .green : .red
                )
                
                StatusIndicator(
                    title: "HealthKit",
                    status: healthKitStatus,
                    color: healthKitStatus == "許可済み" ? .green : .red
                )
                
                StatusIndicator(
                    title: "iCloud",
                    status: cloudKitStatus,
                    color: cloudKitStatus == "利用可能" ? .green : .red
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    private func formatRelativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct StatusIndicator: View {
    let title: String
    let status: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
            
            Text(status)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

struct QuickActionsCard: View {
    let onAISettings: () -> Void
    let onHealthKitSettings: () -> Void
    let onCloudKitSettings: () -> Void
    let onFullSync: () -> Void
    let isAllReady: Bool
    let isSyncing: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("クイックアクション")
                    .font(.headline)
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickActionButton(
                    title: "AI設定",
                    icon: "brain",
                    color: .purple,
                    action: onAISettings
                )
                
                QuickActionButton(
                    title: "HealthKit",
                    icon: "heart",
                    color: .red,
                    action: onHealthKitSettings
                )
                
                QuickActionButton(
                    title: "iCloud同期",
                    icon: "icloud",
                    color: .blue,
                    action: onCloudKitSettings
                )
                
                QuickActionButton(
                    title: isSyncing ? "同期中..." : "全同期",
                    icon: isSyncing ? "arrow.triangle.2.circlepath" : "arrow.triangle.2.circlepath.circle",
                    color: .green,
                    isDisabled: !isAllReady || isSyncing,
                    action: onFullSync
                )
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

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let isDisabled: Bool
    let action: () -> Void
    
    init(title: String, icon: String, color: Color, isDisabled: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.color = color
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isDisabled ? .gray : color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isDisabled ? .gray : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isDisabled ? Color(.systemGray6) : color.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled)
    }
}

struct ServiceConfigurationCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let status: String
    let isConfigured: Bool
    let onConfigure: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("状態: \(status)")
                    .font(.caption)
                    .foregroundColor(isConfigured ? .green : .red)
            }
            
            Spacer()
            
            Button(action: onConfigure) {
                Text(isConfigured ? "編集" : "設定")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(color)
                    .foregroundColor(.white)
                    .cornerRadius(8)
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

struct IntegrationHealthCard: View {
    let aiManager: AIServiceManager
    let healthKitService: HealthKitService
    let cloudKitService: CloudKitService
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("統合状態")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 12) {
                HealthIndicatorRow(
                    title: "AI → HealthKit",
                    description: "食事データから健康データへ",
                    isHealthy: aiManager.hasConfiguredProvider() && healthKitService.isAuthorized
                )
                
                HealthIndicatorRow(
                    title: "HealthKit → CloudKit",
                    description: "健康データのクラウド同期",
                    isHealthy: healthKitService.isAuthorized && cloudKitService.isSignedIn
                )
                
                HealthIndicatorRow(
                    title: "AI → CloudKit",
                    description: "食事記録のクラウドバックアップ",
                    isHealthy: aiManager.hasConfiguredProvider() && cloudKitService.isSignedIn
                )
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

struct HealthIndicatorRow: View {
    let title: String
    let description: String
    let isHealthy: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isHealthy ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isHealthy ? .green : .red)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// Additional supporting views for sync and preferences tabs would be implemented similarly...

#Preview {
    UnifiedSettingsView()
        .modelContainer(for: [UserProfile.self, MealRecord.self, WeightRecord.self, CalorieSavingsRecord.self, DailySummary.self])
}