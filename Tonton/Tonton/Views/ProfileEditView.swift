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
    
    private var currentUserProfile: UserProfile? {
        userProfiles.first
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
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
}

#Preview {
    ProfileEditView()
        .modelContainer(for: [UserProfile.self, MealRecord.self, WeightRecord.self, CalorieSavingsRecord.self, DailySummary.self])
}