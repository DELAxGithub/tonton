//
//  StandardComponents.swift
//  TonTon
//
//  標準UIコンポーネントライブラリ
//  アプリ全体で一貫したUIを提供する統一コンポーネント群
//

import SwiftUI

// MARK: - ボタンコンポーネント

/// 標準プライマリボタン
struct TonTonPrimaryButton: View {
    let title: String
    let action: () -> Void
    let isEnabled: Bool
    
    init(_ title: String, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isEnabled ? Color.accentColor : Color.gray)
                )
        }
        .disabled(!isEnabled)
        .buttonStyle(PlainButtonStyle())
    }
}

/// 標準セカンダリボタン
struct TonTonSecondaryButton: View {
    let title: String
    let action: () -> Void
    let isEnabled: Bool
    
    init(_ title: String, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(isEnabled ? .accentColor : .gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isEnabled ? Color.accentColor : Color.gray, lineWidth: 1)
                )
        }
        .disabled(!isEnabled)
        .buttonStyle(PlainButtonStyle())
    }
}

/// アイコン付きアクションボタン
struct TonTonIconButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    let isEnabled: Bool
    
    init(_ title: String, icon: String, color: Color = .accentColor, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.color = color
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isEnabled ? color : .gray)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isEnabled ? .primary : .gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isEnabled ? color.opacity(0.1) : Color(.systemGray6))
            )
        }
        .disabled(!isEnabled)
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - カードコンポーネント

/// 標準カードコンテナ
struct TonTonCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
    }
}

/// 統計表示カード
struct TonTonStatCard: View {
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

// MARK: - 設定行コンポーネント

/// 標準設定行
struct TonTonSettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    let showsDisclosure: Bool
    
    init(icon: String, title: String, color: Color, showsDisclosure: Bool = true, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.color = color
        self.showsDisclosure = showsDisclosure
        self.action = action
    }
    
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
                
                if showsDisclosure {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// 設定グループコンテナ
struct TonTonSettingsGroup<Content: View>: View {
    let title: String?
    let content: Content
    
    init(_ title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 12) {
            if let title = title {
                HStack {
                    Text(title)
                        .font(.headline)
                    Spacer()
                }
            }
            
            VStack(spacing: 0) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
        }
    }
}

// MARK: - 状態表示コンポーネント

/// ステータス表示インジケーター
struct TonTonStatusIndicator: View {
    let title: String
    let status: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
            
            Text(status)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

/// 統計概要表示
struct TonTonStatsSummary: View {
    let stats: [(title: String, value: String, unit: String, color: Color)]
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(Array(stats.enumerated()), id: \.offset) { _, stat in
                TonTonStatCard(
                    title: stat.title,
                    value: stat.value,
                    unit: stat.unit,
                    color: stat.color
                )
            }
        }
    }
}

// MARK: - テキスト関連コンポーネント

/// 日本語統一テキスト
struct TonTonText {
    /// カロリー表示用テキスト
    static func calories(_ value: Int) -> some View {
        Text("\(value) kcal")
    }
    
    static func calories(_ value: Double) -> some View {
        Text("\(String(format: "%.0f", value)) kcal")
    }
    
    /// 体重表示用テキスト
    static func weight(_ value: Double) -> some View {
        Text("\(String(format: "%.1f", value)) kg")
    }
    
    /// PFC表示用テキスト（日本語統一）
    static func protein(_ value: Double) -> some View {
        Text("タンパク質: \(String(format: "%.1f", value)) g")
    }
    
    static func fat(_ value: Double) -> some View {
        Text("脂質: \(String(format: "%.1f", value)) g")
    }
    
    static func carbs(_ value: Double) -> some View {
        Text("炭水化物: \(String(format: "%.1f", value)) g")
    }
    
    /// パーセンテージ表示
    static func percentage(_ value: Double) -> some View {
        Text("\(String(format: "%.1f", value))%")
    }
}

// MARK: - 空状態コンポーネント

/// 空状態表示
struct TonTonEmptyState: View {
    let icon: String
    let title: String
    let description: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(icon: String, title: String, description: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.description = description
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if let actionTitle = actionTitle, let action = action {
                TonTonPrimaryButton(actionTitle, action: action)
                    .frame(maxWidth: 200)
            }
        }
        .padding(.vertical, 40)
    }
}

// MARK: - プレビュー

#Preview("Buttons") {
    VStack(spacing: 20) {
        TonTonPrimaryButton("プライマリボタン") { }
        TonTonSecondaryButton("セカンダリボタン") { }
        
        HStack(spacing: 12) {
            TonTonIconButton("AI設定", icon: "brain", color: .purple) { }
            TonTonIconButton("同期", icon: "arrow.triangle.2.circlepath", color: .green) { }
        }
    }
    .padding()
}

#Preview("Cards") {
    VStack(spacing: 20) {
        TonTonCard {
            VStack {
                Text("カードコンテンツ")
                Text("詳細情報")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        
        TonTonStatCard(title: "現在の体重", value: "65.5", unit: "kg", color: .blue)
    }
    .padding()
}

#Preview("Settings") {
    TonTonSettingsGroup("設定") {
        TonTonSettingsRow(icon: "gear", title: "一般設定", color: .gray) { }
        
        Divider()
            .padding(.leading, 44)
        
        TonTonSettingsRow(icon: "bell", title: "通知", color: .orange) { }
    }
    .padding()
}