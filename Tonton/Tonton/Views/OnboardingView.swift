//
//  OnboardingView.swift
//  TonTon
//
//  Onboarding flow for new users
//  Migrated from Flutter onboarding screens
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]
    
    @State private var currentStep = 0
    @State private var displayName = ""
    @State private var weight = ""
    @State private var selectedGender: Gender?
    @State private var selectedAgeGroup: AgeGroup?
    @State private var selectedDietGoal: DietGoal?
    @State private var targetWeight = ""
    @State private var targetDays = ""
    @State private var healthKitEnabled = false
    
    private var currentUserProfile: UserProfile? {
        userProfiles.first
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress indicator
                progressIndicator
                
                // Content
                TabView(selection: $currentStep) {
                    welcomeStep.tag(0)
                    basicInfoStep.tag(1)
                    healthGoalsStep.tag(2)
                    healthKitStep.tag(3)
                    completionStep.tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)
                
                // Navigation buttons
                navigationButtons
            }
            .navigationBarHidden(true)
        }
    }
    
    @ViewBuilder
    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<5) { index in
                Rectangle()
                    .fill(index <= currentStep ? Color.accentColor : Color.gray.opacity(0.3))
                    .frame(height: 4)
                    .animation(.easeInOut, value: currentStep)
            }
        }
        .padding(.horizontal)
        .padding(.top, 60)
    }
    
    @ViewBuilder
    private var welcomeStep: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // App icon or illustration
            Image(systemName: "creditcard.fill")
                .font(.system(size: 100))
                .foregroundColor(.pink)
            
            VStack(spacing: 16) {
                Text("TonTonへようこそ")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("カロリー貯金で\n健康管理を楽しく")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 12) {
                FeatureRow(icon: "camera.fill", text: "AI食事認識で簡単記録")
                FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "カロリー貯金で目標達成")
                FeatureRow(icon: "heart.fill", text: "HealthKit連携で自動同期")
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var basicInfoStep: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("基本情報")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("あなたについて教えてください")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("お名前")
                        .font(.headline)
                    TextField("お名前を入力してください", text: $displayName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("現在の体重")
                        .font(.headline)
                    TextField("kg", text: $weight)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("性別")
                        .font(.headline)
                    
                    HStack(spacing: 16) {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Button(action: {
                                selectedGender = gender
                            }) {
                                Text(gender.displayName)
                                    .font(.subheadline)
                                    .foregroundColor(selectedGender == gender ? .white : .primary)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 25)
                                            .fill(selectedGender == gender ? Color.accentColor : Color(.systemGray6))
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("年齢層")
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        ForEach(AgeGroup.allCases, id: \.self) { ageGroup in
                            Button(action: {
                                selectedAgeGroup = ageGroup
                            }) {
                                Text(ageGroup.displayName)
                                    .font(.subheadline)
                                    .foregroundColor(selectedAgeGroup == ageGroup ? .white : .primary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 25)
                                            .fill(selectedAgeGroup == ageGroup ? Color.accentColor : Color(.systemGray6))
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var healthGoalsStep: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("健康目標")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("あなたの目標を設定しましょう")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("ダイエット目標")
                        .font(.headline)
                    
                    VStack(spacing: 12) {
                        ForEach(DietGoal.allCases, id: \.self) { goal in
                            Button(action: {
                                selectedDietGoal = goal
                            }) {
                                HStack {
                                    Image(systemName: goal.icon)
                                        .font(.title3)
                                        .foregroundColor(selectedDietGoal == goal ? .white : .accentColor)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(goal.displayName)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Text(goal.description)
                                            .font(.caption)
                                            .opacity(0.8)
                                    }
                                    
                                    Spacer()
                                }
                                .foregroundColor(selectedDietGoal == goal ? .white : .primary)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedDietGoal == goal ? Color.accentColor : Color(.systemGray6))
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("目標体重")
                            .font(.headline)
                        TextField("kg", text: $targetWeight)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("期間")
                            .font(.headline)
                        TextField("日数", text: $targetDays)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var healthKitStep: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.red)
            
            VStack(spacing: 16) {
                Text("HealthKit連携")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("体重や運動データを自動で同期します")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 16) {
                HealthKitFeatureRow(icon: "scalemass.fill", text: "体重データの自動記録")
                HealthKitFeatureRow(icon: "figure.walk", text: "運動量の自動計算")
                HealthKitFeatureRow(icon: "chart.bar.fill", text: "詳細な健康データ分析")
            }
            
            Toggle("HealthKit連携を有効にする", isOn: $healthKitEnabled)
                .font(.headline)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var completionStep: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.green)
            
            VStack(spacing: 16) {
                Text("設定完了！")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("TonTonで健康管理を\n始めましょう")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var navigationButtons: some View {
        HStack {
            if currentStep > 0 {
                Button("戻る") {
                    withAnimation {
                        currentStep -= 1
                    }
                }
                .font(.headline)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(currentStep == 4 ? "開始" : "次へ") {
                if currentStep == 4 {
                    completeOnboarding()
                } else {
                    withAnimation {
                        currentStep += 1
                    }
                }
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 30)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(canProceed ? Color.accentColor : Color.gray)
            )
            .disabled(!canProceed)
        }
        .padding(.horizontal)
        .padding(.bottom, 40)
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case 0: return true
        case 1: return !displayName.isEmpty && !weight.isEmpty && selectedGender != nil && selectedAgeGroup != nil
        case 2: return selectedDietGoal != nil && !targetWeight.isEmpty && !targetDays.isEmpty
        case 3: return true
        case 4: return true
        default: return false
        }
    }
    
    private func completeOnboarding() {
        guard let profile = currentUserProfile else { return }
        
        profile.updateProfile(
            displayName: displayName,
            weight: Double(weight),
            gender: selectedGender?.rawValue,
            ageGroup: selectedAgeGroup?.rawValue,
            dietGoal: selectedDietGoal?.rawValue,
            targetWeight: Double(targetWeight),
            targetDays: Int(targetDays),
            onboardingCompleted: true
        )
        
        try? modelContext.save()
    }
}

// MARK: - Supporting Types and Views

enum Gender: String, CaseIterable {
    case male, female
    
    var displayName: String {
        switch self {
        case .male: return "男性"
        case .female: return "女性"
        }
    }
}

enum AgeGroup: String, CaseIterable {
    case young, middle, senior
    
    var displayName: String {
        switch self {
        case .young: return "20-39歳"
        case .middle: return "40-59歳"
        case .senior: return "60歳以上"
        }
    }
}

enum DietGoal: String, CaseIterable {
    case weightLoss = "weight_loss"
    case muscleGain = "muscle_gain"
    case maintain = "maintain"
    
    var displayName: String {
        switch self {
        case .weightLoss: return "減量"
        case .muscleGain: return "筋肉増強"
        case .maintain: return "体重維持"
        }
    }
    
    var description: String {
        switch self {
        case .weightLoss: return "カロリー貯金で健康的に体重を減らす"
        case .muscleGain: return "筋トレとバランスの良い食事で筋肉をつける"
        case .maintain: return "現在の体重を健康的に維持する"
        }
    }
    
    var icon: String {
        switch self {
        case .weightLoss: return "arrow.down.circle"
        case .muscleGain: return "arrow.up.circle"
        case .maintain: return "equal.circle"
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.accentColor)
                .frame(width: 30)
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct HealthKitFeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.red)
                .frame(width: 30)
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
        .modelContainer(for: [UserProfile.self, MealRecord.self, WeightRecord.self, CalorieSavingsRecord.self, DailySummary.self])
}