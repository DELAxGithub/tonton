# 🚀 GitHub Issue Processor インストール手順書

**完全自動化されたGitHub Issue修正システム**を新しいプロジェクトに導入する手順書です。
この手順書に従って実行すれば、Claude Codeと連携したissue自動修正環境が完成します。

## 📋 前提条件

以下のツールがインストールされていることを確認してください：

- [x] **Node.js 18+** - `node --version`
- [x] **pnpm** - `pnpm --version` (または npm)
- [x] **Git** - `git --version`
- [x] **Claude Code CLI** - `claude --version`
- [x] **Xcode** (iOS/macOSプロジェクトの場合) - `xcodebuild -version`
- [x] **SwiftLint** (推奨) - `swiftlint version`

### Claude Code CLIインストール（未導入の場合）
```bash
# Option 1: npm経由
npm install -g @anthropic-ai/claude-cli

# Option 2: 公式サイトから
# https://claude.ai/code
```

## 🎯 Step 1: プロジェクト構造の準備

### 1.1 作業ディレクトリに移動
```bash
# 新しいプロジェクトのルートディレクトリに移動
cd /path/to/your/project
```

### 1.2 Issue Processorをコピー
```bash
# このGitHub Issue Processorをコピー
cp -r /path/to/delax-shared-packages/automation/github-issue-processor ./automation/

# または Gitから直接取得
git clone https://github.com/your-org/delax-shared-packages.git temp-repo
cp -r temp-repo/automation/github-issue-processor ./automation/
rm -rf temp-repo
```

### 1.3 作業ディレクトリに移動
```bash
cd automation/github-issue-processor
```

## 📦 Step 2: 依存関係のインストール

### 2.1 パッケージインストール
```bash
# pnpm使用の場合
pnpm install

# npm使用の場合
npm install
```

### 2.2 プロジェクトビルド
```bash
# TypeScriptをビルド
pnpm build
# または npm run build
```

## ⚙️ Step 3: 設定ファイルの作成

### 3.1 設定テンプレート生成
```bash
# 設定テンプレートを生成
pnpm init
# または npm run init
```

### 3.2 プロジェクト設定ファイルをカスタマイズ

`config/project-config.yml` を編集：

```yaml
# GitHub Issue Processor Configuration

# プロジェクト基本情報
project:
  name: "YourProjectName"           # ← あなたのプロジェクト名
  type: "ios-swift"                 # ios-swift, typescript, python, generic

# Issue管理リポジトリ（GitHub Issues取得元）
issueRepository:
  owner: "your-github-username"     # ← あなたのGitHub Username/Org
  name: "project-issues"            # ← Issue管理用リポジトリ名

# 修正対象プロジェクトリポジトリ（PR作成先、オプション）
targetRepository:
  owner: "your-github-username"     # ← あなたのGitHub Username/Org
  name: "your-project-repo"         # ← 実際のプロジェクトリポジトリ名
  defaultBranch: "main"             # main または master

# ローカルプロジェクト設定
paths:
  root: "/Users/you/Projects/YourProject"  # ← あなたのプロジェクトパス
  source:
    - "YourProject/**/*.swift"      # ← プロジェクトのソースファイル
    - "Package.swift"               # 必要に応じて追加

# ビルド設定（iOS/Swift例）
build:
  command: "xcodebuild -project YourProject.xcodeproj -scheme YourProject build"
  testCommand: "xcodebuild test -project YourProject.xcodeproj -scheme YourProject -destination 'platform=iOS Simulator,name=iPhone 15'"
  lintCommand: "swiftlint --strict"

# Issue処理設定
issueProcessing:
  labels:
    - "auto-fix"                    # 自動修正対象ラベル
    - "bug"                         # バグ修正
    - "enhancement"                 # 機能改善
  maxConcurrentIssues: 3
  confidenceThreshold: 0.7

# コンテキスト収集設定
context:
  files:
    - "**/*.swift"                  # 分析対象ファイル
    - "*.xcodeproj/**/*"
    - "Package.swift"
    - "*.plist"
    - "*.entitlements"
  maxFiles: 10

# その他の設定はデフォルトのまま使用可能
```

## 🔑 Step 4: 環境変数の設定

### 4.1 環境変数ファイル作成
```bash
# .envファイルを作成
cp .env.example .env
```

### 4.2 .envファイルを編集
```bash
# GitHub Configuration
GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx    # ← GitHub Personal Access Token

# Issue管理リポジトリ
GITHUB_ISSUE_OWNER=your-github-username  # ← あなたのUsername/Org
GITHUB_ISSUE_REPO=project-issues         # ← Issue管理リポジトリ名

# 修正対象プロジェクトリポジトリ（オプション）
GITHUB_TARGET_OWNER=your-github-username # ← あなたのUsername/Org  
GITHUB_TARGET_REPO=your-project-repo     # ← 実際のプロジェクトリポジトリ名

# ローカルプロジェクト
PROJECT_ROOT=/Users/you/Projects/YourProject  # ← あなたのプロジェクトパス

# Claude Configuration (CLI使用時は不要、API使用時は設定)
# ANTHROPIC_API_KEY=sk-ant-xxxxxxxxxxxx

# Debug Settings
DEBUG_MODE=false
LOG_LEVEL=info
```

### 4.3 GitHub Personal Access Token取得

1. [GitHub Settings > Developer settings > Personal access tokens](https://github.com/settings/tokens)
2. "Generate new token (classic)" をクリック
3. 必要なスコープを選択：
   - [x] `repo` - リポジトリアクセス
   - [x] `issues` - Issue管理
   - [x] `pull_requests` - PR作成
4. トークンをコピーして `.env` ファイルの `GITHUB_TOKEN` に設定

## 🔍 Step 5: セットアップ検証

### 5.1 設定検証
```bash
# セットアップを検証
pnpm validate
# または npm run validate

# 期待される出力:
# 🔍 Validating setup...
# ✅ GitHub connection valid
# ✅ Claude Code CLI available
# ✅ Project root path exists
# ✅ Git repository detected
# ✅ Project setup is valid
```

### 5.2 ドライラン実行
```bash
# 変更を適用せずにテスト実行
pnpm process:once -- --dry-run
# または npm run process:once -- --dry-run

# 期待される出力:
# 🔄 Processing issues (single run)
# 📥 Found 0 new issues (issueがない場合)
# 🔍 Dry run mode - would apply the following changes: (変更がある場合)
```

## 🎯 Step 6: GitHub Issue作成とテスト

### 6.1 Issue管理リポジトリの準備

GitHub上でissue管理用のリポジトリを準備：

```bash
# 例: project-issues リポジトリを作成
# https://github.com/your-username/project-issues
```

### 6.2 テスト用Issue作成

1. Issue管理リポジトリ（例: `project-issues`）でIssueを作成
2. 以下の設定でテスト用Issueを作成：
   
   **Title**: "テスト用バグ修正"
   
   **Body**:
   ```markdown
   ## 問題の説明
   アプリのボタンをタップしても反応しないことがあります。
   
   ## 再現手順
   1. アプリを起動
   2. メインボタンをタップ
   3. 反応しない
   
   ## 期待される動作
   ボタンタップ時に適切なアクションが実行される
   ```
   
   **Labels**: `auto-fix`, `bug`

### 6.3 自動処理テスト
```bash
# テスト実行（1回のみ）
pnpm process:once
# または npm run process:once

# 継続監視モード（本格運用）
pnpm process  
# または npm run process
```

## 📊 Step 7: 運用モニタリング

### 7.1 処理状況確認
```bash
# 処理統計を確認
pnpm status
# または npm run status

# 出力例:
# 📊 Issue Processor Status
# 📋 Processing Statistics:
#   Total issues: 1
#   Pending: 0
#   Processing: 0
#   Completed: 1
#   Failed: 0
```

### 7.2 ログ確認
```bash
# 詳細ログ出力で実行
pnpm process:once -- --verbose
# または npm run process:once -- --verbose
```

### 7.3 クリーンアップ
```bash
# 古いファイル・ブランチを削除（週1回程度）
pnpm clean
# または npm run clean
```

## 🎉 Step 8: 本格運用開始

### 8.1 継続監視モード
```bash
# バックグラウンド実行で継続監視
nohup pnpm process > logs/issue-processor.log 2>&1 &

# または screen/tmux使用
screen -S issue-processor
pnpm process
# Ctrl+A, D でデタッチ
```

### 8.2 システムサービス化（オプション）

macOS launchd設定例:
```bash
# ~/Library/LaunchAgents/com.yourorg.issue-processor.plist
cat > ~/Library/LaunchAgents/com.yourorg.issue-processor.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.yourorg.issue-processor</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/node</string>
        <string>/path/to/your/project/automation/github-issue-processor/dist/index.js</string>
        <string>process</string>
    </array>
    <key>WorkingDirectory</key>
    <string>/path/to/your/project/automation/github-issue-processor</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
EOF

# サービス開始
launchctl load ~/Library/LaunchAgents/com.yourorg.issue-processor.plist
```

## 🛠️ トラブルシューティング

### よくある問題

**Q: Claude CLI not found エラー**
```bash
# Claude CLIを確認
which claude

# インストール
npm install -g @anthropic-ai/claude-cli

# パス設定
export PATH="$PATH:$(npm prefix -g)/bin"
```

**Q: GitHub 認証エラー**
```bash
# トークンのテスト
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user

# トークンスコープの確認が必要
```

**Q: プロジェクトパスエラー**
```bash
# パスが正しいか確認
ls -la /path/to/your/project

# 設定ファイルのpaths.rootを修正
```

**Q: ビルドエラー**
```bash
# 手動ビルドテスト
cd /path/to/your/project
xcodebuild -project YourProject.xcodeproj -scheme YourProject -list

# config/project-config.ymlのbuild.commandを修正
```

## 📚 参考資料

- [ARCHITECTURE.md](./ARCHITECTURE.md) - 詳細アーキテクチャ
- [README.md](./README.md) - 完全ドキュメント  
- [SETUP_GUIDE.md](./SETUP_GUIDE.md) - 詳細セットアップ
- [config/project-config.example.yml](./config/project-config.example.yml) - 設定リファレンス

## 🆘 サポート

問題が発生した場合：

1. **詳細ログで確認**: `pnpm process:once -- --verbose`
2. **セットアップ再検証**: `pnpm validate`
3. **ドライラン実行**: `pnpm process:once -- --dry-run`
4. **Issue報告**: プロジェクトのIssueで報告

---

<div align="center">
  <sub>🎉 GitHub Issue Processor インストール完了おめでとうございます！</sub><br>
  <sub>🤖 自動修正システムで開発効率を大幅に向上させましょう</sub>
</div>