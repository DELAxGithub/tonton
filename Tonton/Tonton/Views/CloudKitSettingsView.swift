//
//  CloudKitSettingsView.swift
//  TonTon
//
//  CloudKit integration settings for data synchronization and backup
//  User interface for managing iCloud sync and account settings
//

import SwiftUI
import SwiftData
import CloudKit

struct CloudKitSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var cloudKitService = CloudKitService()
    @State private var showingSignInAlert = false
    @State private var showingDeleteConfirmation = false
    @State private var showingPermissionAlert = false
    @State private var lastSyncError: String?
    @State private var showingErrorAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Account status section
                    accountStatusSection
                    
                    // Sync controls section
                    syncControlsSection
                    
                    // Data management section
                    dataManagementSection
                    
                    // Advanced settings section
                    advancedSettingsSection
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
            }
            .navigationTitle("データ同期")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("同期") {
                        syncAllData()
                    }
                    .disabled(cloudKitService.isSyncing || !cloudKitService.isSignedIn)
                }
            }
            .alert("iCloudサインインが必要", isPresented: $showingSignInAlert) {
                Button("設定を開く") {
                    openCloudSettings()
                }
                Button("キャンセル", role: .cancel) { }
            } message: {
                Text("データを同期するには、iCloudにサインインする必要があります。")
            }
            .alert("データ削除の確認", isPresented: $showingDeleteConfirmation) {
                Button("削除", role: .destructive) {
                    deleteCloudData()
                }
                Button("キャンセル", role: .cancel) { }
            } message: {
                Text("iCloudに保存されているすべてのTonTonデータが削除されます。この操作は取り消せません。")
            }
            .alert("許可が必要", isPresented: $showingPermissionAlert) {
                Button("了解") { }
            } message: {
                Text("CloudKitの機能を使用するには、アプリの権限が必要です。")
            }
            .alert("同期エラー", isPresented: $showingErrorAlert) {
                Button("了解") { }
            } message: {
                Text(lastSyncError ?? "不明なエラーが発生しました")
            }
        }
        .onAppear {
            initializeService()
        }
    }
    
    @ViewBuilder
    private var accountStatusSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("iCloudアカウント")
                    .font(.headline)
                Spacer()
            }
            
            CloudKitAccountCard(
                isSignedIn: cloudKitService.isSignedIn,
                accountStatus: cloudKitService.userAccountStatus,
                lastSyncDate: cloudKitService.lastSyncDate,
                syncStatus: cloudKitService.syncStatus
            ) {
                if !cloudKitService.isSignedIn {
                    showingSignInAlert = true
                }
            }
        }
    }
    
    @ViewBuilder
    private var syncControlsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("データ同期")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 12) {
                SyncControlCard(
                    title: "全データ同期",
                    description: "プロフィール、食事記録、体重、カロリー貯金をすべて同期",
                    icon: "arrow.triangle.2.circlepath",
                    isEnabled: cloudKitService.isSignedIn,
                    isSyncing: cloudKitService.isSyncing,
                    lastSyncDate: cloudKitService.lastSyncDate
                ) {
                    syncAllData()
                }
                
                Divider()
                    .padding(.leading, 16)
                
                Toggle("自動同期", isOn: .constant(cloudKitService.isSignedIn))
                    .disabled(!cloudKitService.isSignedIn)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                
                Toggle("バックグラウンド同期", isOn: .constant(cloudKitService.isSignedIn))
                    .disabled(!cloudKitService.isSignedIn)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
        }
    }
    
    @ViewBuilder
    private var dataManagementSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("データ管理")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 12) {
                DataTypeRow(
                    icon: "person.crop.circle",
                    title: "プロフィール",
                    description: "個人情報、目標設定、AI設定",
                    color: .blue,
                    isEnabled: cloudKitService.isSignedIn
                )
                
                Divider()
                    .padding(.leading, 44)
                
                DataTypeRow(
                    icon: "camera.on.rectangle",
                    title: "食事記録",
                    description: "食事の写真、カロリー、栄養情報",
                    color: .green,
                    isEnabled: cloudKitService.isSignedIn
                )
                
                Divider()
                    .padding(.leading, 44)
                
                DataTypeRow(
                    icon: "scalemass",
                    title: "体重記録",
                    description: "体重の履歴データ",
                    color: .orange,
                    isEnabled: cloudKitService.isSignedIn
                )
                
                Divider()
                    .padding(.leading, 44)
                
                DataTypeRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "カロリー貯金",
                    description: "日別のカロリー貯金記録",
                    color: .purple,
                    isEnabled: cloudKitService.isSignedIn
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
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
            
            VStack(spacing: 12) {
                Button(action: {
                    requestPermissions()
                }) {
                    HStack {
                        Image(systemName: "key")
                            .foregroundColor(Color.blue)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("権限の要求")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("CloudKit機能への追加権限を要求")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(!cloudKitService.isSignedIn)
                
                Divider()
                    .padding(.leading, 44)
                
                Button(action: {
                    showingDeleteConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("クラウドデータを削除")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.red)
                            
                            Text("iCloudに保存されたすべてのデータを削除")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(!cloudKitService.isSignedIn)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
        }
    }
    
    // MARK: - Actions
    
    private func initializeService() {
        Task {
            await cloudKitService.initialize()
        }
    }
    
    private func syncAllData() {
        Task {
            do {
                if !cloudKitService.isInitialized {
                    await cloudKitService.initialize()
                }
                try await cloudKitService.syncAllData(with: modelContext)
            } catch {
                lastSyncError = error.localizedDescription
                showingErrorAlert = true
            }
        }
    }
    
    private func requestPermissions() {
        Task {
            do {
                if !cloudKitService.isInitialized {
                    await cloudKitService.initialize()
                }
                let granted = try await cloudKitService.requestPermissions()
                if !granted {
                    showingPermissionAlert = true
                }
            } catch {
                lastSyncError = error.localizedDescription
                showingErrorAlert = true
            }
        }
    }
    
    private func deleteCloudData() {
        Task {
            do {
                if !cloudKitService.isInitialized {
                    await cloudKitService.initialize()
                }
                try await cloudKitService.deleteAllCloudData()
            } catch {
                lastSyncError = error.localizedDescription
                showingErrorAlert = true
            }
        }
    }
    
    private func openCloudSettings() {
        if let url = URL(string: "prefs:root=CASTLE") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Supporting Views

struct CloudKitAccountCard: View {
    let isSignedIn: Bool
    let accountStatus: String
    let lastSyncDate: Date?
    let syncStatus: String
    let onSignInTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "icloud.fill")
                    .font(.title)
                    .foregroundColor(isSignedIn ? .blue : .gray)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("iCloud")
                        .font(.headline)
                    
                    Text(accountStatus)
                        .font(.subheadline)
                        .foregroundColor(isSignedIn ? .green : .red)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Image(systemName: isSignedIn ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                        .foregroundColor(isSignedIn ? .green : .red)
                    
                    if let lastSync = lastSyncDate {
                        Text(formatSyncTime(lastSync))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if !isSignedIn {
                Button(action: onSignInTapped) {
                    Text("iCloudにサインイン")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            } else {
                HStack {
                    Text("同期状態:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(syncStatus)
                        .font(.subheadline)
                        .fontWeight(.medium)
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
    
    private func formatSyncTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }
}

struct SyncControlCard: View {
    let title: String
    let description: String
    let icon: String
    let isEnabled: Bool
    let isSyncing: Bool
    let lastSyncDate: Date?
    let onSync: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isEnabled ? .blue : .gray)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let lastSync = lastSyncDate {
                    Text("最終同期: \(formatLastSync(lastSync))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: onSync) {
                HStack {
                    if isSyncing {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                    
                    Text(isSyncing ? "同期中" : "同期")
                        .font(.caption)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isEnabled ? Color.accentColor : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .disabled(!isEnabled || isSyncing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private func formatLastSync(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct DataTypeRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let isEnabled: Bool
    
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
            }
            
            Spacer()
            
            Image(systemName: isEnabled ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isEnabled ? .green : .gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

#Preview {
    CloudKitSettingsView()
        .modelContainer(for: [UserProfile.self, MealRecord.self, WeightRecord.self, CalorieSavingsRecord.self, DailySummary.self])
}