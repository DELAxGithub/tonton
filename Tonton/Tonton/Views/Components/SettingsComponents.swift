//
//  SettingsComponents.swift
//  TonTon
//
//  Reusable components for unified settings interface
//  Supporting views for sync controls and preferences management
//

import SwiftUI
import SwiftData

// MARK: - Sync Components

struct SyncOverviewCard: View {
    let isPerformingSync: Bool
    let lastSyncDate: Date?
    let onFullSync: () -> Void
    let isAllReady: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("同期概要")
                    .font(.headline)
                Spacer()
                
                if let lastSync = lastSyncDate {
                    Text("最終: \(formatRelativeDate(lastSync))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(spacing: 12) {
                SyncStatusIndicator(
                    isActive: isPerformingSync,
                    isReady: isAllReady
                )
                
                Button(action: onFullSync) {
                    HStack {
                        if isPerformingSync {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.triangle.2.circlepath")
                        }
                        
                        Text(isPerformingSync ? "同期中..." : "全サービス同期開始")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isAllReady ? Color.accentColor : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(!isAllReady || isPerformingSync)
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

struct SyncStatusIndicator: View {
    let isActive: Bool
    let isReady: Bool
    
    var body: some View {
        HStack {
            Circle()
                .fill(isActive ? Color.blue : (isReady ? Color.green : Color.red))
                .frame(width: 12, height: 12)
                .scaleEffect(isActive ? 1.5 : 1.0)
                .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isActive)
            
            Text(syncStatusText)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
    
    private var syncStatusText: String {
        if isActive {
            return "同期実行中..."
        } else if isReady {
            return "同期準備完了"
        } else {
            return "サービス設定が必要"
        }
    }
}

struct IndividualSyncCard: View {
    let aiManager: AIServiceManager
    let healthKitService: HealthKitService
    let cloudKitService: CloudKitService
    let modelContext: ModelContext
    
    @State private var isSyncingHealth = false
    @State private var isSyncingCloud = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("個別同期")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 12) {
                IndividualSyncRow(
                    title: "HealthKit同期",
                    description: "体重・カロリーデータ",
                    icon: "heart",
                    color: .red,
                    isEnabled: healthKitService.isAuthorized,
                    isSyncing: isSyncingHealth,
                    lastSyncDate: healthKitService.lastSyncDate
                ) {
                    syncHealthKit()
                }
                
                Divider()
                
                IndividualSyncRow(
                    title: "iCloud同期",
                    description: "全データのバックアップ",
                    icon: "icloud",
                    color: .blue,
                    isEnabled: cloudKitService.isSignedIn,
                    isSyncing: isSyncingCloud,
                    lastSyncDate: cloudKitService.lastSyncDate
                ) {
                    syncCloudKit()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    private func syncHealthKit() {
        isSyncingHealth = true
        Task {
            do {
                try await healthKitService.syncWeightData(with: modelContext)
                try await healthKitService.syncCalorieData(with: modelContext)
            } catch {
                print("HealthKit sync error: \(error)")
            }
            await MainActor.run {
                isSyncingHealth = false
            }
        }
    }
    
    private func syncCloudKit() {
        isSyncingCloud = true
        Task {
            do {
                try await cloudKitService.syncAllData(with: modelContext)
            } catch {
                print("CloudKit sync error: \(error)")
            }
            await MainActor.run {
                isSyncingCloud = false
            }
        }
    }
}

struct IndividualSyncRow: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let isEnabled: Bool
    let isSyncing: Bool
    let lastSyncDate: Date?
    let onSync: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(isEnabled ? color : .gray)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let lastSync = lastSyncDate {
                    Text("最終: \(formatSyncTime(lastSync))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: onSync) {
                HStack {
                    if isSyncing {
                        ProgressView()
                            .scaleEffect(0.7)
                    } else {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.caption)
                    }
                    
                    Text(isSyncing ? "同期中" : "同期")
                        .font(.caption)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isEnabled ? color : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .disabled(!isEnabled || isSyncing)
        }
    }
    
    private func formatSyncTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }
}

struct SyncHistoryCard: View {
    let aiLastUsed: Date?
    let healthKitLastSync: Date?
    let cloudKitLastSync: Date?
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("同期履歴")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 8) {
                SyncHistoryRow(
                    service: "AI サービス",
                    lastActivity: aiLastUsed,
                    icon: "brain",
                    color: .purple
                )
                
                SyncHistoryRow(
                    service: "HealthKit",
                    lastActivity: healthKitLastSync,
                    icon: "heart",
                    color: .red
                )
                
                SyncHistoryRow(
                    service: "iCloud",
                    lastActivity: cloudKitLastSync,
                    icon: "icloud",
                    color: .blue
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

struct SyncHistoryRow: View {
    let service: String
    let lastActivity: Date?
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(service)
                .font(.subheadline)
            
            Spacer()
            
            if let lastActivity = lastActivity {
                Text(formatRelativeDate(lastActivity))
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("未使用")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
    
    private func formatRelativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Preferences Components

struct GeneralPreferencesCard: View {
    let profile: UserProfile
    let modelContext: ModelContext
    
    @State private var displayName: String
    @State private var enableNotifications = true
    @State private var dataRetentionDays = 30
    
    init(profile: UserProfile, modelContext: ModelContext) {
        self.profile = profile
        self.modelContext = modelContext
        self._displayName = State(initialValue: profile.displayName ?? "")
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("一般設定")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 12) {
                HStack {
                    Text("表示名")
                        .font(.subheadline)
                    Spacer()
                    TextField("名前を入力", text: $displayName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 150)
                }
                
                Divider()
                
                Toggle("通知を有効化", isOn: $enableNotifications)
                
                Divider()
                
                HStack {
                    Text("データ保持期間")
                        .font(.subheadline)
                    Spacer()
                    Picker("Days", selection: $dataRetentionDays) {
                        Text("7日").tag(7)
                        Text("30日").tag(30)
                        Text("90日").tag(90)
                        Text("1年").tag(365)
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .onChange(of: displayName) { _, newValue in
            profile.displayName = newValue.isEmpty ? nil : newValue
            try? modelContext.save()
        }
    }
}

struct AIPreferencesCard: View {
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
            HStack {
                Text("AI設定")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 12) {
                HStack {
                    Text("フォールバック有効")
                        .font(.subheadline)
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { preferences.enableFallback },
                        set: { preferences.enableFallback = $0 }
                    ))
                }
                
                Divider()
                
                HStack {
                    Text("使用ログ記録")
                        .font(.subheadline)
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { preferences.logUsage },
                        set: { preferences.logUsage = $0 }
                    ))
                }
                
                Divider()
                
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
            }
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

struct PrivacyPreferencesCard: View {
    let profile: UserProfile
    let modelContext: ModelContext
    
    @State private var shareDataWithApple = false
    @State private var allowAnalytics = true
    @State private var syncPhotos = true
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("プライバシー設定")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 12) {
                Toggle("Appleとのデータ共有", isOn: $shareDataWithApple)
                
                Divider()
                
                Toggle("使用状況分析", isOn: $allowAnalytics)
                
                Divider()
                
                Toggle("食事写真の同期", isOn: $syncPhotos)
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("データの削除")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("すべてのローカルデータを削除します")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("削除") {
                        // Implement data deletion
                    }
                    .foregroundColor(.red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.red, lineWidth: 1)
                    )
                }
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