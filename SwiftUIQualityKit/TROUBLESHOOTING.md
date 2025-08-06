# SwiftUIQualityKit トラブルシューティング

**よくある問題と解決方法**

## 🔧 インストール・セットアップの問題

### ❌ 「権限がありません」エラー

**症状:**
```
permission denied: ./ui_audit.sh
```

**解決方法:**
```bash
# 全スクリプトに実行権限付与
chmod +x SwiftUIQualityKit/*.sh
chmod +x scripts/*.sh

# 確認
ls -la SwiftUIQualityKit/*.sh
```

### ❌ fswatch が見つからない

**症状:**
```
❌ fswatch が見つかりません
```

**解決方法:**
```bash
# Homebrewでインストール
brew install fswatch

# インストール確認
fswatch --version

# Homebrew未インストールの場合
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### ❌ Xcodeプロジェクトが見つからない

**症状:**
```
❌ Xcodeプロジェクトが見つかりません
```

**解決方法:**
```bash
# プロジェクトルートディレクトリで実行
ls -la *.xcodeproj

# 正しいディレクトリに移動
cd /path/to/your/ios/project
./SwiftUIQualityKit/install.sh
```

## 🔍 品質チェックの問題

### ⚠️ 「検出問題が多すぎる」

**症状:**
```
🔴 多数の問題が検出されました。
合計: 150件
```

**段階的解決:**

**Step 1: 自動修正可能な問題から**
```bash
# 言語統一（最も効果的）
./scripts/language_fixer.sh

# 再チェック
./scripts/ui_audit.sh
```

**Step 2: 重要度別対応**
```bash
# クリティカル問題のみ
./scripts/swiftui_quality_runner.sh critical

# 高速チェック
./scripts/swiftui_quality_runner.sh fast
```

**Step 3: 監視モードで新規問題防止**
```bash
./SwiftUIQualityKit/watch_mode.sh
```

### ❌ 「偽陽性（誤検出）が多い」

**症状:**
- 正常なコードが問題として報告される
- 日本語テキストが英語として検出される

**調整方法:**

**ui_audit.sh の調整:**
```bash
# ファイル編集
nano SwiftUIQualityKit/ui_audit.sh

# 検出しきい値を調整（例：@State数）
# 8個 → 12個
if (( state_count > 12 )); then
```

**言語検出の調整:**
```bash
# language_fixer.sh の正規表現調整
# より厳密なパターンに変更
grep -q 'Text(".*[A-Za-z].*:' "$file"
```

### ⚠️ 「処理が遅すぎる」

**症状:**
- 全体チェックが5分以上かかる
- watchモードで応答遅延

**高速化対策:**

**1. ファイル除外設定**
```bash
# watch_mode.sh で除外パターン追加
--exclude='.*/Pods/.*'
--exclude='.*/Carthage/.*'
--exclude='.*/node_modules/.*'
```

**2. 対象ファイル制限**
```bash
# 最新変更ファイルのみチェック
find "$PROJECT_ROOT" -name "*.swift" -mtime -1
```

**3. 並列処理活用**
```bash
# 複数チェッカーの並列実行
./scripts/ui_audit.sh &
./scripts/swiftui_quality_checker.sh &
wait
```

## 🗂️ ファイル・ディレクトリの問題

### ❌ 「StandardComponents.swift が見つからない」

**症状:**
```
⚠️ Views/Componentsディレクトリが見つかりません
```

**手動配置:**
```bash
# 適切なディレクトリに手動コピー
cp SwiftUIQualityKit/StandardComponents.swift YourApp/Views/Components/

# または新規ディレクトリ作成
mkdir -p YourApp/Views/Components
cp SwiftUIQualityKit/StandardComponents.swift YourApp/Views/Components/

# Xcodeプロジェクトに追加を忘れずに
```

### ❌ 「audit_results ディレクトリ作成失敗」

**症状:**
```
mkdir: cannot create directory 'scripts/audit_results': Permission denied
```

**解決方法:**
```bash
# ディレクトリ権限確認
ls -la scripts/

# 権限修正
sudo chmod 755 scripts/
mkdir -p scripts/audit_results

# または別の場所を使用
export RESULTS_DIR="$HOME/SwiftUIQualityResults"
mkdir -p "$RESULTS_DIR"
```

## ⚡ リアルタイム監視の問題

### ❌ watch_mode.sh が途中で停止

**症状:**
- Ctrl+C後も監視が継続
- CPU使用率が異常に高い

**解決方法:**
```bash
# プロセス強制終了
pkill -f watch_mode.sh
pkill -f fswatch

# 監視プロセス確認
ps aux | grep fswatch

# 正常再開
./SwiftUIQualityKit/watch_mode.sh
```

### ⚠️ 「変更検出の感度が高すぎる」

**症状:**
- 自動保存のたびに大量のアラート
- 一時ファイルも監視対象になる

**調整方法:**
```bash
# デバウンス時間延長（watch_mode.sh）
DEBOUNCE_SECONDS=5  # 2秒 → 5秒

# 除外パターン追加
--exclude='.*\.swp$'
--exclude='.*\.tmp$'
--exclude='.*~$'
```

## 🔗 Xcode統合の問題

### ❌ Build Phase でエラー

**症状:**
```
Build Phase script failed
```

**デバッグ方法:**
```bash
# 手動でBuild Phaseスクリプト実行
SRCROOT="$(pwd)" ./scripts/build_phase_script.sh

# ログ確認
tail -f /tmp/xcode_build_log
```

**修正例:**
```bash
# build_phase_script.sh の修正
if [[ -z "$SRCROOT" ]]; then
    SRCROOT="$(pwd)"
fi

# タイムアウト追加
timeout 60 "$SCRIPTS_DIR/ui_audit.sh"
```

### ❌ Pre-commit hook が動作しない

**症状:**
- `git commit` 時にチェックが実行されない

**確認・修正:**
```bash
# Hook確認
ls -la .git/hooks/pre-commit

# 権限確認
chmod +x .git/hooks/pre-commit

# 手動テスト
.git/hooks/pre-commit

# Hook再インストール
./SwiftUIQualityKit/xcode_integration.sh setup-pre-commit
```

## 📊 出力・レポートの問題

### ❌ 日本語文字化け

**症状:**
- ターミナルで日本語が文字化け
- レポートファイルが読めない

**解決方法:**
```bash
# ロケール設定
export LANG=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8

# ターミナル設定確認
locale

# VSCode設定（settings.json）
"terminal.integrated.env.osx": {
    "LANG": "ja_JP.UTF-8"
}
```

### ⚠️ レポートファイルが大きすぎる

**症状:**
- audit_results/ が数GB
- ディスク容量不足

**自動クリーンアップ:**
```bash
# 古いレポート削除（7日以上）
find scripts/audit_results/ -name "*.txt" -mtime +7 -delete

# 自動クリーンアップスクリプト
cat >> ~/.bashrc << 'EOF'
cleanup_quality_reports() {
    find scripts/audit_results/ -mtime +7 -delete
}
EOF
```

## 🔄 アップデート・メンテナンス

### 新版の適用

```bash
# 現在のバージョン確認
head -5 SwiftUIQualityKit/CHANGELOG.md

# バックアップ
cp -r SwiftUIQualityKit SwiftUIQualityKit.backup

# 新版適用
cp -r /path/to/delax-shared-packages/SwiftUIQualityKit ./

# 設定復元（必要な場合）
```

### 定期メンテナンス

**月次:**
```bash
# 一時ファイルクリーンアップ
rm -rf /tmp/*quality*
find scripts/audit_results/ -mtime +30 -delete

# 設定確認
./SwiftUIQualityKit/quick_setup.sh
```

## 🆘 緊急時対応

### すべてリセット

```bash
# SwiftUIQualityKit完全削除
rm -rf SwiftUIQualityKit/
rm -rf scripts/audit_results/
rm -f .git/hooks/pre-commit

# クリーンインストール  
cp -r /path/to/delax-shared-packages/SwiftUIQualityKit ./
./SwiftUIQualityKit/install.sh
```

### 最小限復旧

```bash
# コアスクリプトのみ復旧
cp SwiftUIQualityKit/ui_audit.sh scripts/
cp SwiftUIQualityKit/language_fixer.sh scripts/
chmod +x scripts/*.sh
```

## 📞 サポート情報

**delax-shared-packages リポジトリ**
- 課題報告
- 機能要求
- 改善提案

**ログ収集（報告時に添付）**
```bash
./scripts/swiftui_quality_runner.sh full > quality_debug.log 2>&1
```