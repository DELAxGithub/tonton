//
//  HealthKitSettingsView.swift
//  TonTon
//
//  HealthKit integration settings and synchronization management
//  User interface for configuring health data sync
//

import SwiftUI
import SwiftData
import HealthKit

struct HealthKitSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var userProfiles: [UserProfile]
    
    @StateObject private var healthKitService = HealthKitService()
    @State private var showingPermissionAlert = false
    @State private var isSyncing = false
    @State private var lastSyncError: String?
    @State private var showingErrorAlert = false
    
    private var currentUserProfile: UserProfile? {
        userProfiles.first
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // HealthKit status section
                    healthKitStatusSection
                    
                    // Permission management section
                    permissionManagementSection
                    
                    // Sync controls section
                    syncControlsSection
                    
                    // Data types section
                    dataTypesSection
                    
                    // Usage statistics section
                    usageStatisticsSection
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
            }
            .navigationTitle("HealthKit連携")
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
                    .disabled(isSyncing || !healthKitService.isAuthorized)
                }
            }
            .alert("HealthKit許可が必要", isPresented: $showingPermissionAlert) {
                Button("設定を開く") {
                    openHealthKitSettings()
                }
                Button("キャンセル", role: .cancel) { }
            } message: {
                Text("体重とカロリーデータを同期するには、HealthKitへのアクセス許可が必要です。")
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
    private var healthKitStatusSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("HealthKit状態")
                    .font(.headline)
                Spacer()
            }
            
            HealthKitStatusCard(
                isAuthorized: healthKitService.isAuthorized,
                authorizationStatus: healthKitService.authorizationStatus,
                lastSyncDate: healthKitService.lastSyncDate,
                syncStatus: healthKitService.syncStatus
            )
        }
    }
    
    @ViewBuilder
    private var permissionManagementSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("アクセス許可")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 12) {
                if !healthKitService.isAuthorized {
                    PermissionRequestCard {
                        requestHealthKitPermission()
                    }
                } else {
                    PermissionStatusCard(
                        permissions: healthKitService.getHealthKitPermissions()
                    )
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
                SyncControlRow(
                    title: "体重データ同期",
                    description: "HealthKitと体重データを双方向同期",
                    isEnabled: healthKitService.isAuthorized,
                    isSyncing: isSyncing,
                    lastSyncDate: healthKitService.lastSyncDate
                ) {
                    syncWeightData()
                }
                
                Divider()
                    .padding(.leading, 16)
                
                SyncControlRow(
                    title: "カロリーデータ同期",
                    description: "消費・摂取カロリーをHealthKitと同期",
                    isEnabled: healthKitService.isAuthorized,
                    isSyncing: isSyncing,
                    lastSyncDate: healthKitService.lastSyncDate
                ) {
                    syncCalorieData()
                }
                
                Divider()
                    .padding(.leading, 16)
                
                Toggle("バックグラウンド同期", isOn: .constant(healthKitService.isAuthorized))
                    .disabled(!healthKitService.isAuthorized)
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
    private var dataTypesSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("利用可能なデータタイプ")
                    .font(.headline)
                Spacer()
            }
            
            DataTypesCard(
                availableTypes: healthKitService.getAvailableDataTypes(),
                isAuthorized: healthKitService.isAuthorized
            )
        }
    }
    
    @ViewBuilder
    private var usageStatisticsSection: some View {
        if let profile = currentUserProfile {
            VStack(spacing: 16) {
                HStack {
                    Text("健康データ統計")
                        .font(.headline)
                    Spacer()
                }
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    HealthStatCard(
                        title: "現在の体重",
                        value: profile.weight != nil ? String(format: "%.1f", profile.weight!) : "--",
                        unit: "kg",
                        color: .blue
                    )
                    
                    HealthStatCard(
                        title: "最終記録",
                        value: profile.lastWeightDate != nil ? formatDate(profile.lastWeightDate!) : "--",
                        unit: "",
                        color: .green
                    )
                    
                    HealthStatCard(
                        title: "消費カロリー",
                        value: profile.dailyCaloriesBurned != nil ? String(format: "%.0f", profile.dailyCaloriesBurned!) : "--",
                        unit: "kcal",
                        color: .orange
                    )
                    
                    HealthStatCard(
                        title: "同期状態",
                        value: healthKitService.syncStatus,
                        unit: "",
                        color: .purple
                    )
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func initializeService() {
        Task {
            await healthKitService.initialize()
        }
    }
    
    private func requestHealthKitPermission() {
        Task {
            do {
                if !healthKitService.isInitialized {
                    await healthKitService.initialize()
                }
                let authorized = try await healthKitService.requestAuthorization()
                if authorized {
                    try await healthKitService.enableBackgroundDelivery()
                } else {
                    showingPermissionAlert = true
                }
            } catch {
                lastSyncError = error.localizedDescription
                showingErrorAlert = true
            }
        }
    }
    
    private func syncAllData() {
        isSyncing = true
        
        Task {
            do {
                if !healthKitService.isInitialized {
                    await healthKitService.initialize()
                }
                try await healthKitService.syncWeightData(with: modelContext)
                try await healthKitService.syncCalorieData(with: modelContext)
            } catch {
                lastSyncError = error.localizedDescription
                showingErrorAlert = true
            }
            
            isSyncing = false
        }
    }
    
    private func syncWeightData() {
        isSyncing = true
        
        Task {
            do {
                if !healthKitService.isInitialized {
                    await healthKitService.initialize()
                }
                try await healthKitService.syncWeightData(with: modelContext)
            } catch {
                lastSyncError = error.localizedDescription
                showingErrorAlert = true
            }
            
            isSyncing = false
        }
    }
    
    private func syncCalorieData() {
        isSyncing = true
        
        Task {
            do {
                if !healthKitService.isInitialized {
                    await healthKitService.initialize()
                }
                try await healthKitService.syncCalorieData(with: modelContext)
            } catch {
                lastSyncError = error.localizedDescription
                showingErrorAlert = true
            }
            
            isSyncing = false
        }
    }
    
    private func openHealthKitSettings() {
        if let url = URL(string: "x-apple-health://") {
            UIApplication.shared.open(url)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views

struct HealthKitStatusCard: View {
    let isAuthorized: Bool
    let authorizationStatus: String
    let lastSyncDate: Date?
    let syncStatus: String
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "heart.fill")
                    .font(.title)
                    .foregroundColor(isAuthorized ? .red : .gray)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("HealthKit")
                        .font(.headline)
                    
                    Text(authorizationStatus)
                        .font(.subheadline)
                        .foregroundColor(isAuthorized ? .green : .red)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Image(systemName: isAuthorized ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                        .foregroundColor(isAuthorized ? .green : .red)
                    
                    if let lastSync = lastSyncDate {
                        Text(formatSyncTime(lastSync))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
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

struct PermissionRequestCard: View {
    let onRequest: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 40))
                .foregroundColor(.red)
            
            VStack(spacing: 8) {
                Text("HealthKit連携を有効化")
                    .font(.headline)
                
                Text("体重とカロリーデータを自動で同期するには、HealthKitへのアクセス許可が必要です。")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: onRequest) {
                Text("アクセス許可を要求")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(12)
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

struct PermissionStatusCard: View {
    let permissions: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("データアクセス許可状況")
                .font(.subheadline)
                .fontWeight(.medium)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(permissions, id: \.self) { permission in
                    HStack {
                        let components = permission.components(separatedBy: ": ")
                        if components.count == 2 {
                            Text(components[0])
                                .font(.caption)
                            
                            Spacer()
                            
                            Text(components[1])
                                .font(.caption)
                                .foregroundColor(components[1] == "許可" ? .green : .red)
                        }
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
    }
}

struct SyncControlRow: View {
    let title: String
    let description: String
    let isEnabled: Bool
    let isSyncing: Bool
    let lastSyncDate: Date?
    let onSync: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
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
        .padding(.vertical, 8)
    }
}

struct DataTypesCard: View {
    let availableTypes: [String]
    let isAuthorized: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("利用可能なデータ")
                .font(.subheadline)
                .fontWeight(.medium)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(availableTypes, id: \.self) { dataType in
                    DataTypeChip(
                        name: dataType,
                        isEnabled: isAuthorized
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

struct DataTypeChip: View {
    let name: String
    let isEnabled: Bool
    
    var body: some View {
        HStack {
            Image(systemName: dataTypeIcon(for: name))
                .font(.caption)
                .foregroundColor(isEnabled ? .green : .gray)
            
            Text(name)
                .font(.caption)
                .foregroundColor(isEnabled ? .primary : .secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill((isEnabled ? Color.green : Color.gray).opacity(0.1))
        )
    }
    
    private func dataTypeIcon(for type: String) -> String {
        switch type {
        case "体重":
            return "scalemass"
        case "消費カロリー", "摂取カロリー":
            return "flame"
        case "基礎代謝":
            return "bolt"
        case "歩数":
            return "figure.walk"
        default:
            return "heart"
        }
    }
}

#Preview {
    HealthKitSettingsView()
        .modelContainer(for: [UserProfile.self, MealRecord.self, WeightRecord.self, CalorieSavingsRecord.self, DailySummary.self])
}