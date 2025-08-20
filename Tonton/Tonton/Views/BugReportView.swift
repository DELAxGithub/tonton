//
//  BugReportView.swift
//  TonTon
//
//  DELAX-inspired bug reporting system for TonTon health tracking app
//  Health and meal logging specific bug reporting UI
//

import SwiftUI

struct TonTonBugReportView: View {
    let currentScreen: String
    let healthContext: HealthKitContext?
    let mealLoggingContext: MealLoggingContext?
    
    @Environment(\.dismiss) private var dismiss
    @State private var bugTitle = ""
    @State private var bugDescription = ""
    @State private var bugCategory: TonTonBugCategory = .other
    @State private var reproductionSteps = ""
    @State private var expectedBehavior = ""
    @State private var actualBehavior = ""
    @State private var includeDeviceInfo = true
    @State private var includeHealthContext = true
    @State private var includeMealContext = true
    @State private var isSubmitting = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    init(
        currentScreen: String,
        healthContext: HealthKitContext? = nil,
        mealLoggingContext: MealLoggingContext? = nil
    ) {
        self.currentScreen = currentScreen
        self.healthContext = healthContext
        self.mealLoggingContext = mealLoggingContext
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Bug Details Section
                Section("バグの詳細") {
                    TextField("バグのタイトル", text: $bugTitle)
                        .textInputAutocapitalization(.sentences)
                    
                    Picker("カテゴリ", selection: $bugCategory) {
                        ForEach(TonTonBugCategory.allCases, id: \.self) { category in
                            Label {
                                Text(category.displayName)
                            } icon: {
                                Image(systemName: category.icon)
                                    .foregroundColor(Color.blue)
                            }
                            .tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("問題の説明")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $bugDescription)
                            .frame(minHeight: 100)
                            .scrollContentBackground(.hidden)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
                
                // Detailed Information Section
                Section("詳細情報") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("再現手順")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $reproductionSteps)
                            .frame(minHeight: 80)
                            .scrollContentBackground(.hidden)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("期待される動作")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $expectedBehavior)
                            .frame(minHeight: 60)
                            .scrollContentBackground(.hidden)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("実際の動作")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $actualBehavior)
                            .frame(minHeight: 60)
                            .scrollContentBackground(.hidden)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
                
                // Context Information Section
                Section("含める情報") {
                    Toggle("デバイス情報", isOn: $includeDeviceInfo)
                        .help("デバイスモデル、iOS バージョン、メモリ使用量など")
                    
                    if healthContext != nil {
                        Toggle("ヘルスケア情報", isOn: $includeHealthContext)
                            .help("HealthKit 権限、同期状況、体重記録など")
                    }
                    
                    if mealLoggingContext != nil {
                        Toggle("食事記録情報", isOn: $includeMealContext)
                            .help("AI分析状況、画像処理状況、記録ステップなど")
                    }
                }
                
                // Current Context Display
                Section("現在の状況") {
                    LabeledContent("画面", value: currentScreen)
                    
                    if let healthContext = healthContext, includeHealthContext {
                        if !healthContext.healthKitPermissions.isEmpty {
                            LabeledContent("HealthKit権限", value: "\(healthContext.healthKitPermissions.count)個")
                        }
                        if let syncStatus = healthContext.syncStatus {
                            LabeledContent("同期状況", value: syncStatus)
                        }
                    }
                    
                    if let mealContext = mealLoggingContext, includeMealContext {
                        LabeledContent("食事記録ステップ", value: mealContext.currentStep)
                        if let aiStatus = mealContext.aiAnalysisStatus {
                            LabeledContent("AI分析", value: aiStatus)
                        }
                    }
                    
                    LabeledContent("アプリバージョン", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
                    LabeledContent("報告日時", value: Date().formatted(date: .abbreviated, time: .shortened))
                }
            }
            .navigationTitle("バグレポート")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("送信") {
                        submitBugReport()
                    }
                    .disabled(isSubmitting || bugTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .alert("送信完了", isPresented: $showSuccessAlert) {
            Button("了解") {
                dismiss()
            }
        } message: {
            Text("バグレポートを送信しました。ご協力ありがとうございます。")
        }
        .alert("送信エラー", isPresented: $showErrorAlert) {
            Button("了解") { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            // Pre-fill category based on current screen context
            suggestCategoryFromContext()
        }
    }
    
    private func suggestCategoryFromContext() {
        // Suggest category based on current screen
        switch currentScreen.lowercased() {
        case let screen where screen.contains("meal"):
            bugCategory = .mealLoggingFlow
        case let screen where screen.contains("weight"):
            bugCategory = .weightTracking
        case let screen where screen.contains("health"):
            bugCategory = .healthKitSync
        case let screen where screen.contains("photo"), let screen where screen.contains("camera"):
            bugCategory = .mealPhotoUpload
        case let screen where screen.contains("ai"), let screen where screen.contains("analysis"):
            bugCategory = .aiAnalysisError
        default:
            if mealLoggingContext != nil {
                bugCategory = .mealLoggingFlow
            } else if healthContext != nil {
                bugCategory = .healthKitSync
            }
        }
    }
    
    private func submitBugReport() {
        isSubmitting = true
        
        let bugReport = TonTonBugReport(
            category: bugCategory,
            title: bugTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            description: bugDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            reproductionSteps: reproductionSteps.trimmingCharacters(in: .whitespacesAndNewlines),
            expectedBehavior: expectedBehavior.trimmingCharacters(in: .whitespacesAndNewlines),
            actualBehavior: actualBehavior.trimmingCharacters(in: .whitespacesAndNewlines),
            currentScreen: currentScreen,
            healthContext: includeHealthContext ? healthContext : nil,
            mealLoggingContext: includeMealContext ? mealLoggingContext : nil
        )
        
        // Simulate submission delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isSubmitting = false
            
            // For now, just show success. In production, implement actual submission
            saveBugReportLocally(bugReport)
            showSuccessAlert = true
        }
    }
    
    private func saveBugReportLocally(_ report: TonTonBugReport) {
        // Save to UserDefaults for now - in production, send to backend
        if let encoded = try? JSONEncoder().encode(report) {
            let key = "tonton_bug_reports"
            var reports = UserDefaults.standard.data(forKey: key).flatMap {
                try? JSONDecoder().decode([Data].self, from: $0)
            } ?? []
            
            reports.append(encoded)
            
            // Keep only last 50 reports
            if reports.count > 50 {
                reports = Array(reports.suffix(50))
            }
            
            if let reportsData = try? JSONEncoder().encode(reports) {
                UserDefaults.standard.set(reportsData, forKey: key)
            }
        }
        
        print("🐛 Bug Report Saved Locally:")
        print("Title: \(report.title ?? "Untitled")")
        print("Category: \(report.category.displayName)")
        print("Screen: \(report.currentScreen)")
        print("Health Context: \(report.healthContext != nil)")
        print("Meal Context: \(report.mealLoggingContext != nil)")
    }
}

// MARK: - Preview

struct TonTonBugReportView_Previews: PreviewProvider {
    static var previews: some View {
        TonTonBugReportView(
            currentScreen: "HomeView",
            healthContext: HealthKitContext(
                healthKitPermissions: ["体重", "歩数", "消費カロリー"],
                lastSyncDate: Date(),
                syncStatus: "同期済み"
            ),
            mealLoggingContext: MealLoggingContext(
                currentStep: "写真撮影",
                aiAnalysisStatus: "分析中",
                todayMealCount: 2
            )
        )
    }
}