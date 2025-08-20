//
//  MealLoggingView.swift
//  TonTon
//
//  Meal logging screen with AI-powered image analysis
//  Migrated from Flutter meal logging flow
//

import SwiftUI
import SwiftData

struct MealLoggingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var mealRecords: [MealRecord]
    @Query private var userProfiles: [UserProfile]
    @State private var showingCamera = false
    @State private var showingImagePicker = false
    @StateObject private var aiServiceManager = AIServiceManager()
    @State private var isAnalyzing = false
    @State private var analysisResult: MealAnalysisResult?
    @State private var showingErrorAlert = false
    @State private var errorAlertMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Camera section for meal photo
                cameraSection
                
                // Recent meals section
                recentMealsSection
                
                Spacer()
            }
            .padding(.horizontal)
            .navigationTitle("食事記録")
            .navigationBarTitleDisplayMode(.large)
.overlay {
                if isAnalyzing {
                    VStack(spacing: 12) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .scaleEffect(1.2)
                        
                        VStack(spacing: 4) {
                            Text("AIが分析中...")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("数秒お待ちください")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .shadow(radius: 10)
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.3))
                }
            }
            .sheet(isPresented: $showingCamera) {
                ImagePicker(sourceType: .camera) { image in
                    analyzeImage(image)
                    showingCamera = false
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(sourceType: .photoLibrary) { image in
                    analyzeImage(image)
                    showingImagePicker = false
                }
            }
.sheet(item: $analysisResult) { result in
                MealAnalysisResultView(analysisResult: result) { mealRecord in
                    modelContext.insert(mealRecord)
                    do {
                        try modelContext.save()
                    } catch {
                        print("Failed to save meal record: \(error)")
                        errorAlertMessage = "食事記録の保存に失敗しました"
                        showingErrorAlert = true
                    }
                }
            }
            .alert("エラー", isPresented: $showingErrorAlert) {
                Button("OK") { }
            } message: {
                Text(errorAlertMessage)
            }
        }
    }
    
    @ViewBuilder
    private var cameraSection: some View {
        VStack(spacing: 16) {
            Text("食事の写真を撮って、AIが自動でカロリーを計算します")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            HStack {
                TonTonPrimaryButton("写真を撮る") {
                    showingCamera = true
                }
                TonTonSecondaryButton("アルバムから選択") {
                    showingImagePicker = true
                }
            }
        }
        .padding(.top)
    }

    private func analyzeImage(_ image: UIImage) {
        isAnalyzing = true
        Task {
            do {
                guard let userProfile = userProfiles.first else { 
                    print("❌ UserProfile not found")
                    await MainActor.run { isAnalyzing = false }
                    return 
                }
                
                print("🔍 Starting AI analysis with provider: \(userProfile.aiProvider.displayName)")
                print("🔑 Provider configured: \(aiServiceManager.isProviderConfigured(userProfile.aiProvider))")
                
                let result = try await aiServiceManager.analyzeMealImage(image, userProfile: userProfile)
                await MainActor.run {
                    self.analysisResult = result
                    print("✅ AI analysis completed: \(result.mealName)")
                }
} catch AIServiceError.notConfigured {
                print("❌ AI Provider not configured: \(userProfiles.first?.aiProvider.displayName ?? "unknown")")
                errorAlertMessage = "AIプロバイダーが設定されていません。\n設定でAPIキーを登録してください。"
                showingErrorAlert = true
            } catch AIServiceError.providerNotAvailable {
                print("❌ AI Provider not available")
                errorAlertMessage = "AIプロバイダーが利用できません。\nしばらくしてから再度お試しください。"
                showingErrorAlert = true
            } catch AIServiceError.invalidAPIKey {
                print("❌ Invalid API Key")
                errorAlertMessage = "APIキーが無効です。\n設定で正しいAPIキーを登録してください。"
                showingErrorAlert = true
            } catch AIServiceError.networkError {
                print("❌ Network error during AI analysis")
                errorAlertMessage = "ネットワークエラーが発生しました。\nインターネット接続を確認してから再度お試しください。"
                showingErrorAlert = true
            } catch AIServiceError.dailyLimitExceeded {
                print("❌ Daily limit exceeded")
                errorAlertMessage = "今日の使用制限に達しました。\n明日再度お試しください。"
                showingErrorAlert = true
            } catch {
                print("❌ AI Analysis error: \(error)")
                if let localizedError = error as? LocalizedError {
                    print("   Error description: \(localizedError.errorDescription ?? "No description")")
                    errorAlertMessage = localizedError.errorDescription ?? "不明なエラーが発生しました"
                } else {
                    errorAlertMessage = "不明なエラーが発生しました。\nしばらくしてから再度お試しください。"
                }
                showingErrorAlert = true
            }
            await MainActor.run { isAnalyzing = false }
        }
    }
    
    @ViewBuilder
    private var recentMealsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("最近の食事")
                    .font(.headline)
                Spacer()
                
                Button("すべて見る") {
                    // Navigate to all meals
                }
                .font(.subheadline)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(Array(mealRecords.prefix(5))) { meal in
                    MealRecordRowView(meal: meal)
                }
            }
            
            if mealRecords.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "fork.knife.circle")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("まだ食事が記録されていません")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("写真を撮って最初の食事を記録しましょう")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 40)
            }
        }
    }
}

struct MealRecordRowView: View {
    let meal: MealRecord
    
    var body: some View {
        HStack(spacing: 12) {
            // Meal type icon
            Image(systemName: mealTypeIcon)
                .font(.title2)
                .foregroundColor(mealTypeColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.mealName)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(meal.mealTimeType.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(meal.formattedDate())
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(meal.calories)) kcal")
                    .font(.headline)
                    .fontWeight(.bold)
                
                HStack(spacing: 8) {
                    TonTonText.protein(meal.protein)
                    TonTonText.fat(meal.fat)
                    TonTonText.carbs(meal.carbs)
                }
                .font(.caption2)
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    private var mealTypeIcon: String {
        switch meal.mealTimeType {
        case .breakfast: return "sunrise"
        case .lunch: return "sun.max"
        case .dinner: return "moon"
        case .snack: return "cup.and.saucer"
        }
    }
    
    private var mealTypeColor: Color {
        switch meal.mealTimeType {
        case .breakfast: return .orange
        case .lunch: return .yellow
        case .dinner: return .purple
        case .snack: return .green
        }
    }
}

#Preview {
    MealLoggingView()
        .modelContainer(for: [UserProfile.self, MealRecord.self, WeightRecord.self, CalorieSavingsRecord.self, DailySummary.self])
}