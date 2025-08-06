# SwiftUIQualityKit

**SwiftUI + CloudKit iOS開発専用の自動化品質管理システム**

## 🎯 概要

SwiftUIQualityKitは、SwiftUI + CloudKit を使用するiOSプロジェクトの品質管理を自動化するためのツールキットです。UI整理、言語統一、コンポーネント標準化、リアルタイム監視機能を提供します。

### 主な特徴
- **🔍 リアルタイム品質監視**: ファイル変更を監視して即座に品質チェック
- **🎨 SwiftUI特化分析**: 状態管理、パフォーマンス、アクセシビリティの専門的チェック
- **☁️ CloudKit統合最適化**: SwiftData連携、同期パターン、スキーマ設計の品質分析
- **📝 日本語統一自動化**: P/F/C表記の自動変換など言語混在の解決
- **🏗️ Xcode統合**: Build Phase、Pre-commit hookでの品質ゲート
- **🧩 標準コンポーネント**: TonTonボタン、カード、テキスト表示の統一ライブラリ

## 📦 インストール方法

### 1. delax-shared-packagesからの導入

```bash
# 共有パッケージリポジトリからSwiftUIQualityKitをコピー
cp -r /path/to/delax-shared-packages/SwiftUIQualityKit ./scripts/
```

### 2. 依存関係のインストール

```bash
# fswatch（ファイル監視用）のインストール
brew install fswatch

# 権限設定
chmod +x scripts/SwiftUIQualityKit/*.sh
```

### 3. 初期セットアップ

```bash
# Xcode統合設定
./scripts/SwiftUIQualityKit/xcode_integration.sh setup-build-phase
./scripts/SwiftUIQualityKit/xcode_integration.sh setup-pre-commit
```

## 🚀 基本的な使用方法

### 🏃‍♂️ クイックスタート（推奨）
```bash
# 1コマンドセットアップ
./SwiftUIQualityKit/quick_setup.sh

# 統合品質チェック
./scripts/swiftui_quality_runner.sh fast
```

### UI品質監査の実行
```bash
# 包括的なUI品質チェック
./scripts/ui_audit.sh

# 言語混在の自動修正
./scripts/language_fixer.sh
```

### リアルタイム監視モードの開始
```bash
# ファイル変更を監視して自動チェック
./SwiftUIQualityKit/watch_mode.sh

# 初回全体チェック付きで開始
./SwiftUIQualityKit/watch_mode.sh --full-audit
```

### 統合品質チェック（新機能）
```bash
# 高速チェック（重要問題のみ）
./scripts/swiftui_quality_runner.sh fast

# 全チェック実行
./scripts/swiftui_quality_runner.sh full

# クリティカル問題のみ
./scripts/swiftui_quality_runner.sh critical

# JSON形式出力
./scripts/swiftui_quality_runner.sh full json
```

### SwiftUI特化品質チェック
```bash
# SwiftUI品質の詳細分析
./SwiftUIQualityKit/swiftui_quality_checker.sh

# CloudKit統合品質の詳細分析
./SwiftUIQualityKit/cloudkit_quality_checker.sh
```

## 🛠️ 高度な機能

### 標準コンポーネントの使用

プロジェクトに標準コンポーネントライブラリを統合:

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            // 統一されたボタンスタイル
            TonTonPrimaryButton(
                title: "保存",
                action: { /* action */ },
                isEnabled: true
            )
            
            // 統一された値表示
            TonTonText.calories(1200)
            TonTonText.protein(85.2)
            TonTonText.carbs(150.0)
            TonTonText.fat(45.8)
            
            // 統一されたカードデザイン
            TonTonCard {
                Text("コンテンツ")
            }
        }
    }
}
```

### 自動化ワークフローの設定

#### Build Phase統合
1. Xcodeでプロジェクトを開く
2. Build Phases → New Run Script Phase
3. スクリプト内容: `"${SRCROOT}/scripts/SwiftUIQualityKit/build_phase_script.sh"`

#### Pre-commit Hook
Git コミット時に自動品質チェックが実行されます。

## 📊 品質メトリクス

SwiftUIQualityKitは以下の品質指標を追跡します:

### UI品質
- 言語混在の問題数
- 未実装ボタンの数
- ナビゲーション複雑度
- 重複コンポーネント

### SwiftUI品質
- @State変数の過度使用
- パフォーマンス問題
- アクセシビリティ不足
- Preview不足
- ナビゲーションアンチパターン

### CloudKit品質
- SwiftData統合問題
- 同期パターンの品質
- Schema設計問題
- 認証・権限管理
- パフォーマンス最適化
- デバッグ・監視設定

## 🔧 設定とカスタマイズ

### 監視設定の調整

`watch_mode.sh`内の設定変更:
```bash
DEBOUNCE_SECONDS=2      # 変更後の待機時間
WATCH_EXTENSIONS="swift" # 監視するファイル拡張子
```

### 品質チェックレベルの調整

各チェッカースクリプトで閾値を調整可能:
- `state_count > 8` → 状態管理の複雑度警告レベル
- `sheet_count > 4` → Sheet過多の警告レベル
- `save_count > 5` → CloudKit保存操作の頻度警告レベル

## 💡 推奨ワークフロー

### 日常開発
1. `watch_mode.sh` でリアルタイム監視を有効化
2. コード変更時の自動フィードバックを活用
3. 定期的に `ui_audit.sh` で全体チェック

### リリース前
1. `language_fixer.sh` で言語統一
2. 全品質チェッカーを実行して問題解決
3. 標準コンポーネントの統合度を確認

### チーム開発
1. Pre-commit hookでコード品質の自動保証
2. Build Phase統合でCI/CD品質ゲート
3. 共通コンポーネントライブラリの活用

## 🎨 対応プロジェクト

- **対象**: SwiftUI + CloudKit を使用するiOSアプリ
- **要件**: iOS 15.0+, Xcode 14.0+
- **言語**: 日本語・英語混在プロジェクトに最適化

## 📈 効果

- **開発効率**: リアルタイムフィードバックにより即座の問題解決
- **コード品質**: 自動化された品質ゲートによる一貫した品質維持
- **保守性**: 標準コンポーネントと統一されたパターンによる保守コスト削減
- **チーム開発**: 共通の品質基準と自動化によるチーム効率向上

## 🤝 貢献

このツールキットは `delax-shared-packages` リポジトリで管理されています。改善提案や機能追加は共有パッケージのガイドラインに従って貢献してください。

## 📄 ライセンス

内部使用のための共有技術パッケージです。