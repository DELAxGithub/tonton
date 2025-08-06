//
//  APIKeyInputView.swift
//  TonTon
//
//  API key input and validation view
//  Secure entry for AI provider API keys
//

import SwiftUI

struct APIKeyInputView: View {
    let provider: AIProvider
    let aiManager: AIServiceManager
    private let keychainService: KeychainService
    
    @Environment(\.dismiss) private var dismiss
    @State private var apiKey = ""
    @State private var isSecure = true
    @State private var isValidating = false
    @State private var validationResult: String?
    @State private var showingValidation = false
    
    init(provider: AIProvider, aiManager: AIServiceManager, keychainService: KeychainService = KeychainService()) {
        self.provider = provider
        self.aiManager = aiManager
        self.keychainService = keychainService
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Provider info section
                    providerInfoSection
                    
                    // API key input section
                    apiKeyInputSection
                    
                    // Validation section
                    if showingValidation {
                        validationSection
                    }
                    
                    // Instructions section
                    instructionsSection
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
            }
            .navigationTitle("\(provider.displayName)設定")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveAPIKey()
                    }
                    .disabled(apiKey.isEmpty || isValidating)
                }
            }
        }
        .onAppear {
            loadExistingKey()
        }
    }
    
    @ViewBuilder
    private var providerInfoSection: some View {
        VStack(spacing: 16) {
            Image(systemName: provider.iconName)
                .font(.system(size: 60))
                .foregroundColor(Color(provider.color))
            
            VStack(spacing: 8) {
                Text(provider.displayName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(provider.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(provider.color).opacity(0.1))
        )
    }
    
    @ViewBuilder
    private var apiKeyInputSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("APIキー")
                    .font(.headline)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Group {
                        if isSecure {
                            SecureField("APIキーを入力してください", text: $apiKey)
                        } else {
                            TextField("APIキーを入力してください", text: $apiKey)
                        }
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        isSecure.toggle()
                    }) {
                        Image(systemName: isSecure ? "eye" : "eye.slash")
                            .foregroundColor(.secondary)
                    }
                }
                
                if !apiKey.isEmpty {
                    HStack {
                        Image(systemName: isValidKey ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                            .foregroundColor(isValidKey ? .green : .red)
                        
                        Text(keyValidationMessage)
                            .font(.caption)
                            .foregroundColor(isValidKey ? .green : .red)
                        
                        Spacer()
                    }
                }
            }
            
            Button(action: testConnection) {
                HStack {
                    if isValidating {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "network")
                    }
                    
                    Text(isValidating ? "テスト中..." : "接続テスト")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isValidKey ? Color.accentColor : Color.gray)
                )
                .foregroundColor(.white)
            }
            .disabled(!isValidKey || isValidating)
        }
    }
    
    @ViewBuilder
    private var validationSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("テスト結果")
                    .font(.headline)
                Spacer()
            }
            
            HStack {
                Image(systemName: validationResult == "success" ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(validationResult == "success" ? .green : .red)
                
                Text(validationMessage)
                    .font(.subheadline)
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill((validationResult == "success" ? Color.green : Color.red).opacity(0.1))
            )
        }
    }
    
    @ViewBuilder
    private var instructionsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("APIキーの取得方法")
                    .font(.headline)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 12) {
                InstructionStep(
                    number: 1,
                    text: getInstructionStep1()
                )
                
                InstructionStep(
                    number: 2,
                    text: getInstructionStep2()
                )
                
                InstructionStep(
                    number: 3,
                    text: getInstructionStep3()
                )
                
                if !getWebsiteURL().isEmpty {
                    Button(action: {
                        if let url = URL(string: getWebsiteURL()) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "safari")
                            Text("\(provider.displayName)のウェブサイトを開く")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.accentColor, lineWidth: 1)
                        )
                        .foregroundColor(.accentColor)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
    
    // MARK: - Computed Properties
    
    private var isValidKey: Bool {
        keychainService.validateAPIKey(apiKey, for: provider)
    }
    
    private var keyValidationMessage: String {
        if apiKey.isEmpty {
            return ""
        } else if isValidKey {
            return "有効なAPIキー形式です"
        } else {
            return "無効なAPIキー形式です"
        }
    }
    
    private var validationMessage: String {
        switch validationResult {
        case "success":
            return "接続に成功しました"
        case "failure":
            return "接続に失敗しました。APIキーを確認してください"
        default:
            return ""
        }
    }
    
    // MARK: - Actions
    
    private func loadExistingKey() {
        if let existingKey = keychainService.loadAPIKey(for: provider) {
            apiKey = existingKey
        }
    }
    
    private func saveAPIKey() {
        let success = aiManager.configureProvider(provider, apiKey: apiKey)
        if success {
            dismiss()
        }
    }
    
    private func testConnection() {
        isValidating = true
        showingValidation = false
        
        Task {
            do {
                // Temporarily save the key for testing
                let tempSaved = keychainService.saveAPIKey(for: provider, apiKey: apiKey)
                
                if tempSaved {
                    let result = try await aiManager.testProvider(provider)
                    
                    await MainActor.run {
                        validationResult = result ? "success" : "failure"
                        showingValidation = true
                        isValidating = false
                    }
                } else {
                    await MainActor.run {
                        validationResult = "failure"
                        showingValidation = true
                        isValidating = false
                    }
                }
            } catch {
                await MainActor.run {
                    validationResult = "failure"
                    showingValidation = true
                    isValidating = false
                }
            }
        }
    }
    
    // MARK: - Provider-specific Instructions
    
    private func getInstructionStep1() -> String {
        switch provider {
        case .gemini:
            return "Google AI Studioにアクセスしてください"
        case .claude:
            return "Anthropic Consoleにアクセスしてください"
        case .openai:
            return "OpenAI Platform にアクセスしてください"
        }
    }
    
    private func getInstructionStep2() -> String {
        switch provider {
        case .gemini:
            return "「Get API key」をクリックしてAPIキーを作成します"
        case .claude:
            return "「API Keys」セクションで新しいAPIキーを作成します"
        case .openai:
            return "「API keys」セクションで新しいAPIキーを作成します"
        }
    }
    
    private func getInstructionStep3() -> String {
        return "作成されたAPIキーをコピーして、上のフィールドに貼り付けてください"
    }
    
    private func getWebsiteURL() -> String {
        switch provider {
        case .gemini:
            return "https://aistudio.google.com/app/apikey"
        case .claude:
            return "https://console.anthropic.com/account/keys"
        case .openai:
            return "https://platform.openai.com/api-keys"
        }
    }
}

struct InstructionStep: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(Circle().fill(Color.accentColor))
            
            Text(text)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}

#Preview {
    APIKeyInputView(provider: .gemini, aiManager: AIServiceManager(), keychainService: KeychainService())
}