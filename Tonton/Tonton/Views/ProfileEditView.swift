//
//  ProfileEditView.swift
//  TonTon
//
//  プロフィール編集画面
//  ユーザーの基本情報と健康目標を設定する
//

import SwiftUI
import SwiftData

struct ProfileEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var userProfiles: [UserProfile]
    
    @State private var displayName: String = ""
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var age: String = ""
    @State private var gender: String = "male"
    @State private var targetWeight: String = ""
    @State private var targetDays: String = ""
    @State private var dietGoal: String = "weight_loss"
    @State private var calorieGoal: String = ""
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // AI Settings state
    @StateObject private var aiManager = AIServiceManager()
    @State private var isTestingAI = false
    @State private var aiTestResult: AITestResult?
    @State private var showingAITestResult = false
    
    private var currentUserProfile: UserProfile? {
        userProfiles.first
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // デバッグ情報（一時的）
                    debugInfoSection
                    
                    // AI設定セクション（デバッグのため最上部に移動）
                    aiSettingsSection
                    
                    // 基本情報セクション
                    basicInfoSection
                    
                    // 体格情報セクション
                    physicalInfoSection
                    
                    // 目標設定セクション
                    goalsSection
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
            }
            .navigationTitle("プロフィール編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveProfile()
                    }
                }
            }
            .alert("保存結果", isPresented: $showingAlert) {
                Button("了解") {
                    if alertMessage.contains("成功") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
        .onAppear {
            loadCurrentProfile()
        }
    }
    
    @ViewBuilder
    private var basicInfoSection: some View {
        TonTonCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("基本情報")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("表示名")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("ニックネームを入力", text: $displayName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("性別")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Picker("性別", selection: $gender) {
                        Text("男性").tag("male")
                        Text("女性").tag("female")
                        Text("その他").tag("other")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("年齢")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("年齢", text: $age)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
            }
        }
    }
    
    @ViewBuilder
    private var physicalInfoSection: some View {
        TonTonCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("体格情報")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("身長 (cm)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("身長を入力", text: $height)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("現在の体重 (kg)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("体重を入力", text: $weight)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
            }
        }
    }
    
    @ViewBuilder
    private var goalsSection: some View {
        TonTonCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("健康目標")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("ダイエット目標")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Picker("ダイエット目標", selection: $dietGoal) {
                        Text("減量").tag("weight_loss")
                        Text("体重維持").tag("maintain")
                        Text("筋肉増強").tag("muscle_gain")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("目標体重 (kg)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("目標体重を入力", text: $targetWeight)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("達成期間 (日)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("達成までの日数", text: $targetDays)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("1日の目標カロリー (kcal)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("目標カロリーを入力", text: $calorieGoal)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
            }
        }
    }
    
    @ViewBuilder
    private var debugInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🐛 DEBUG情報")
                .font(.headline)
                .foregroundColor(.red)
            
            Text("User Profiles Count: \(userProfiles.count)")
                .font(.caption)
            
            if let profile = currentUserProfile {
                Text("✅ Current Profile Found")
                    .font(.caption)
                    .foregroundColor(.green)
                
                Text("AI Provider: \(profile.aiProvider.displayName)")
                    .font(.caption)
                
                Text("Model: \(profile.aiProvider.modelDisplayName)")
                    .font(.caption)
                
                Text("AI Manager Configured: \(aiManager.hasConfiguredProvider() ? "✅" : "❌")")
                    .font(.caption)
                    .foregroundColor(aiManager.hasConfiguredProvider() ? .green : .red)
            } else {
                Text("❌ No Current Profile Found")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.yellow.opacity(0.3))
        .cornerRadius(8)
    }
    
    @ViewBuilder
    private var aiSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AI設定")
                .font(.headline)
                .foregroundColor(.primary)
                
                // Current AI Provider display
                VStack(alignment: .leading, spacing: 8) {
                    Text("使用中のAIプロバイダー")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    if let profile = currentUserProfile {
                        HStack {
                            Image(systemName: profile.aiProvider.iconName)
                                .foregroundColor(colorFromString(profile.aiProvider.color))
                            Text(profile.aiProvider.displayName)
                                .font(.body)
                                .fontWeight(.medium)
                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(colorFromString(profile.aiProvider.color).opacity(0.1))
                        )
                        
                        // Model name display
                        VStack(alignment: .leading, spacing: 4) {
                            Text("使用モデル")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(profile.aiProvider.modelDisplayName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .padding(.top, 8)
                    }
                }
                
                // AI Test section
                VStack(alignment: .leading, spacing: 12) {
                    Text("接続テスト")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Button(action: {
                        performAITest()
                    }) {
                        HStack {
                            if isTestingAI {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .padding(.trailing, 4)
                                Text("テスト中...")
                            } else {
                                Image(systemName: "checkmark.circle")
                                Text("AI接続をテスト")
                            }
                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isTestingAI ? Color.gray.opacity(0.3) : Color.blue.opacity(0.1))
                        )
                        .foregroundColor(isTestingAI ? .gray : .blue)
                    }
                    .disabled(isTestingAI || currentUserProfile == nil)
                    
                    // Test result display
                    if let testResult = aiTestResult {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: testResult.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(testResult.success ? .green : .red)
                                Text(testResult.success ? "テスト成功" : "テスト失敗")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(testResult.success ? .green : .red)
                                Spacer()
                                Text(testResult.responseTimeFormatted)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            if let message = testResult.testMessage ?? testResult.errorMessage {
                                Text(message)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill((testResult.success ? Color.green : Color.red).opacity(0.1))
                        )
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue, lineWidth: 2)
                )
        )
    }
    
    private func colorFromString(_ colorString: String) -> Color {
        switch colorString.lowercased() {
        case "blue": return .blue
        case "orange": return .orange
        case "green": return .green
        case "purple": return .purple
        case "red": return .red
        default: return .gray
        }
    }
    
    private func performAITest() {
        guard let profile = currentUserProfile else { return }
        
        isTestingAI = true
        aiTestResult = nil
        
        Task {
            do {
                let testResult = try await aiManager.performSimpleTest(for: profile.aiProvider)
                await MainActor.run {
                    self.aiTestResult = testResult
                }
            } catch {
                await MainActor.run {
                    self.aiTestResult = AITestResult(
                        success: false,
                        provider: profile.aiProvider,
                        responseTime: 0,
                        testMessage: nil,
                        errorMessage: error.localizedDescription,
                        timestamp: Date()
                    )
                }
            }
            
            await MainActor.run {
                isTestingAI = false
            }
        }
    }
    
    private func loadCurrentProfile() {
        guard let profile = currentUserProfile else { return }
        
        displayName = profile.displayName ?? ""
        weight = profile.weight != nil ? String(format: "%.1f", profile.weight!) : ""
        height = profile.height != nil ? String(format: "%.1f", profile.height!) : ""
        age = profile.age != nil ? "\(profile.age!)" : ""
        gender = profile.gender ?? "male"
        targetWeight = profile.targetWeight != nil ? String(format: "%.1f", profile.targetWeight!) : ""
        targetDays = profile.targetDays != nil ? "\(profile.targetDays!)" : ""
        dietGoal = profile.dietGoal ?? "weight_loss"
        calorieGoal = profile.calorieGoal != nil ? String(format: "%.0f", profile.calorieGoal!) : ""
    }
    
    private func saveProfile() {
        guard validateInputs() else {
            showingAlert = true
            return
        }

        let profile = currentUserProfile ?? UserProfile()
        
        profile.displayName = displayName.isEmpty ? nil : displayName
        profile.weight = Double(weight)
        profile.height = Double(height)
        profile.age = Int(age)
        profile.gender = gender
        profile.targetWeight = Double(targetWeight)
        profile.targetDays = Int(targetDays)
        profile.dietGoal = dietGoal
        profile.calorieGoal = Double(calorieGoal)
        profile.lastModified = Date()
        
        // 新規プロフィールの場合はmodelContextに追加
        if currentUserProfile == nil {
            // AIプロバイダーのデフォルト値を明示的に設定
            profile.selectedAIProvider = AIProvider.gemini.rawValue
            modelContext.insert(profile)
        }
        
        do {
            try modelContext.save()
            alertMessage = "プロフィールを保存しました"
            showingAlert = true
        } catch {
            alertMessage = "プロフィールの保存に失敗しました: \(error.localizedDescription)"
            showingAlert = true
        }
    }

    private func validateInputs() -> Bool {
        if !weight.isEmpty && Double(weight) == nil {
            alertMessage = "体重には数値を入力してください"
            return false
        }
        if !height.isEmpty && Double(height) == nil {
            alertMessage = "身長には数値を入力してください"
            return false
        }
        if !age.isEmpty && Int(age) == nil {
            alertMessage = "年齢には整数を入力してください"
            return false
        }
        if !targetWeight.isEmpty && Double(targetWeight) == nil {
            alertMessage = "目標体重には数値を入力してください"
            return false
        }
        if !targetDays.isEmpty && Int(targetDays) == nil {
            alertMessage = "達成期間には整数を入力してください"
            return false
        }
        if !calorieGoal.isEmpty && Double(calorieGoal) == nil {
            alertMessage = "目標カロリーには数値を入力してください"
            return false
        }
        return true
    }

#Preview {
    ProfileEditView()
        .modelContainer(for: [UserProfile.self, MealRecord.self, WeightRecord.self, CalorieSavingsRecord.self, DailySummary.self])
}