# SwiftUIQualityKit クイックスタート

**5分で始めるSwiftUI品質管理自動化**

## 🚀 超高速セットアップ（30秒）

```bash
# 1. delax-shared-packagesからコピー
cp -r /path/to/delax-shared-packages/SwiftUIQualityKit ./

# 2. クイックセットアップ実行
./SwiftUIQualityKit/quick_setup.sh
```

**完了！** 基本的な品質チェックが使用可能になりました。

## 📋 すぐに使える3つのコマンド

### 1️⃣ 基本品質チェック
```bash
./scripts/ui_audit.sh
```
**結果例:**
```
UI品質監査結果
==============
📝 言語混在の問題: 5件
🚧 未実装ボタンの問題: 2件  
🗺️ ナビゲーション複雑度の問題: 1件
📊 合計: 8件
```

### 2️⃣ 言語統一自動修正
```bash
./scripts/language_fixer.sh
```
**実行内容:**
- `P:` → `タンパク質:`
- `F:` → `脂質:`
- `C:` → `炭水化物:`
- `OK` → `了解`

### 3️⃣ 高速統合チェック
```bash
./scripts/swiftui_quality_runner.sh fast
```
**チェック内容:**
- UI品質問題
- SwiftUI状態管理
- パフォーマンス問題
- アクセシビリティ

## ⚡ リアルタイム監視（推奨）

**fswatch依存:**
```bash
brew install fswatch  # 初回のみ
```

**監視開始:**
```bash
./SwiftUIQualityKit/watch_mode.sh
```

**効果:**
- ファイル保存時に即座品質チェック
- 問題を早期発見
- 開発フローを中断せずフィードバック

## 🎯 効果的な使用パターン

### 開発開始時
```bash
# 1. 現状把握
./scripts/ui_audit.sh

# 2. 基本修正
./scripts/language_fixer.sh

# 3. 監視開始
./SwiftUIQualityKit/watch_mode.sh
```

### 定期メンテナンス（週1回）
```bash
# 全体チェック
./scripts/swiftui_quality_runner.sh full

# 結果確認
ls scripts/audit_results/
```

### リリース前
```bash
# 1. 最終チェック
./scripts/swiftui_quality_runner.sh full

# 2. 問題修正
./scripts/language_fixer.sh

# 3. 再確認
./scripts/ui_audit.sh
```

## 🔧 高度なセットアップ（必要な場合）

### Xcode統合（ビルド時チェック）
```bash
./SwiftUIQualityKit/xcode_integration.sh setup-build-phase
```

### Git統合（コミット前チェック）
```bash
./SwiftUIQualityKit/xcode_integration.sh setup-pre-commit
```

## 📊 結果の見方

### 正常な状態
```
🎉 検出された品質問題はありません！
プロジェクトは良好な状態です。
```

### 改善推奨
```
⚠️ 中程度の問題があります。
段階的な改善をお勧めします。
合計: 23件
```

### 要注意
```
🔴 多数の問題が検出されました。
組織的な改善計画の策定をお勧めします。
合計: 67件
```

## 🎨 標準コンポーネント使用

**統一ボタン:**
```swift
TonTonPrimaryButton(
    title: "保存",
    action: { /* action */ }
)
```

**統一データ表示:**
```swift
TonTonText.calories(1200)    // "1200 kcal"
TonTonText.protein(85.2)     // "タンパク質: 85.2 g"
```

## 🆘 トラブルシューティング

### 権限エラー
```bash
chmod +x SwiftUIQualityKit/*.sh
```

### fswatch未インストール
```bash
brew install fswatch
```

### スクリプト見つからない
```bash
# パスの確認
ls -la SwiftUIQualityKit/
ls -la scripts/
```

## 📈 最初の1週間でやること

**Day 1:** クイックセットアップ + 現状把握
```bash
./SwiftUIQualityKit/quick_setup.sh
./scripts/ui_audit.sh
```

**Day 2-3:** 基本修正
```bash
./scripts/language_fixer.sh
./scripts/swiftui_quality_runner.sh fast
```

**Day 4-7:** 監視モード習慣化
```bash
./SwiftUIQualityKit/watch_mode.sh
# 開発中は常時実行
```

## 🎉 成功の指標

**1週間後:**
- 言語混在問題: 0件
- 未実装ボタン: 50%削減
- 新規問題: リアルタイム検出・修正

**1ヶ月後:**
- 品質問題: 80%削減
- コード統一性: 大幅向上
- 開発効率: フィードバック即座化

---

**🚀 今すぐ始める:** `./SwiftUIQualityKit/quick_setup.sh`