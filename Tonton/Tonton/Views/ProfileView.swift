//
//  ProfileView.swift
//  TonTon
//
//  User profile screen with settings and health goals
//  Migrated from Flutter profile screens
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]
    @State private var showingBugReport = false
    @State private var showingUnifiedSettings = false
    @State private var showingProfileEdit = false
    
    private var currentUserProfile: UserProfile? {
        userProfiles.first
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile header
                    profileHeaderSection
                    
                    // Health stats section
                    healthStatsSection
                    
                    // Goals section
                    goalsSection
                    
                    // Settings section
                    settingsSection
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
            }
            .navigationTitle("プロフィール")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingBugReport) {
                TonTonBugReportView(
                    currentScreen: "ProfileView",
                    healthContext: createHealthContext(),
                    mealLoggingContext: nil
                )
            }
            .sheet(isPresented: $showingUnifiedSettings) {
                UnifiedSettingsView()
            }
            .sheet(isPresented: $showingProfileEdit) {
                ProfileEditView()
            }
        }
    }
    
    @ViewBuilder
    private var profileHeaderSection: some View {
        VStack(spacing: 16) {
            // Profile image
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            // Name and basic info
            VStack(spacing: 8) {
                if let profile = currentUserProfile {
                    Text(profile.displayName ?? "ユーザー")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if let weight = profile.weight {
                        Text("現在の体重: \(String(format: "%.1f", weight)) kg")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if let dietGoal = profile.dietGoal {
                        Text("目標: \(dietGoalDisplayName(dietGoal))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Edit profile button
            Button(action: {
                showingProfileEdit = true
            }) {
                Text("プロフィールを編集")
                    .font(.subheadline)
                    .foregroundColor(.accentColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.accentColor, lineWidth: 1)
                    )
            }
        }
        .padding(.top)
    }
    
    @ViewBuilder
    private var healthStatsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("健康データ")
                    .font(.headline)
                Spacer()
            }
            
            if let profile = currentUserProfile {
                let stats = [
                    (title: "現在の体重", 
                     value: profile.weight != nil ? String(format: "%.1f", profile.weight!) : "--", 
                     unit: "kg", 
                     color: Color.blue),
                    (title: "目標体重", 
                     value: profile.targetWeight != nil ? String(format: "%.1f", profile.targetWeight!) : "--", 
                     unit: "kg", 
                     color: Color.green),
                    (title: "基礎代謝", 
                     value: profile.calculateBMR() != nil ? String(format: "%.0f", Double(profile.calculateBMR()!)) : "--", 
                     unit: "kcal", 
                     color: Color.orange),
                    (title: "目標期間", 
                     value: profile.targetDays != nil ? "\(profile.targetDays!)" : "--", 
                     unit: "日", 
                     color: Color.purple)
                ]
                
                TonTonStatsSummary(stats: stats)
            }
        }
    }
    
    @ViewBuilder
    private var goalsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("目標設定")
                    .font(.headline)
                Spacer()
                
                Button("編集") {
                    // Navigate to goals editing
                }
                .font(.subheadline)
                .foregroundColor(.accentColor)
            }
            
            VStack(spacing: 16) {
                GoalRowView(
                    icon: "target",
                    title: "ダイエット目標",
                    value: currentUserProfile?.dietGoal != nil ? dietGoalDisplayName(currentUserProfile!.dietGoal!) : "未設定",
                    color: .green
                )
                
                GoalRowView(
                    icon: "scalemass",
                    title: "目標体重",
                    value: currentUserProfile?.targetWeight != nil ? "\(String(format: "%.1f", currentUserProfile!.targetWeight!)) kg" : "未設定",
                    color: .blue
                )
                
                GoalRowView(
                    icon: "calendar",
                    title: "目標期間",
                    value: currentUserProfile?.targetDays != nil ? "\(currentUserProfile!.targetDays!)日" : "未設定",
                    color: .purple
                )
            }
        }
    }
    
    @ViewBuilder
    private var settingsSection: some View {
        TonTonSettingsGroup("設定") {
            TonTonSettingsRow(
                icon: "gear.badge",
                title: "統合設定",
                color: .indigo
            ) {
                showingUnifiedSettings = true
            }
            
            Divider()
                .padding(.leading, 44)
            
            TonTonSettingsRow(
                icon: "questionmark.circle",
                title: "バグレポート",
                color: .orange
            ) {
                showingBugReport = true
            }
            
            Divider()
                .padding(.leading, 44)
            
            TonTonSettingsRow(
                icon: "info.circle",
                title: "アプリについて",
                color: .gray
            ) {
                // TODO: Navigate to about
            }
        }
        
        // Logout button
        TonTonCard {
            Button(action: {
                // TODO: Handle logout
            }) {
                Text("ログアウト")
                    .font(.headline)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private func dietGoalDisplayName(_ goal: String) -> String {
        switch goal {
        case "weight_loss": return "減量"
        case "muscle_gain": return "筋肉増強"
        case "maintain": return "体重維持"
        default: return goal
        }
    }
    
    private func createHealthContext() -> HealthKitContext? {
        // Create health context for bug reporting
        let profile = currentUserProfile
        let lastWeightRecord = profile?.lastWeightDate
        
        return HealthKitContext(
            healthKitPermissions: ["体重", "歩数", "消費カロリー"], // TODO: Get actual permissions
            lastSyncDate: Date(), // TODO: Get actual last sync date
            syncStatus: "同期済み", // TODO: Get actual sync status
            availableDataTypes: ["weight", "steps", "calories"],
            lastWeightRecord: lastWeightRecord,
            calorieGoal: profile?.calorieGoal
        )
    }
}

// MARK: - Supporting Views

struct HealthStatCard: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(unit)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

struct GoalRowView: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
        )
    }
}

struct SettingsRowView: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: [UserProfile.self, MealRecord.self, WeightRecord.self, CalorieSavingsRecord.self, DailySummary.self])
}