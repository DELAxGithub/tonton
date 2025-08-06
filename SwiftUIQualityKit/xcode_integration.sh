#!/bin/bash

# SwiftUIQualityKit - Xcode統合スクリプト
# Build Phase統合とPre-commit hook自動セットアップ

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS_DIR="$PROJECT_ROOT/scripts"

echo "🔧 SwiftUIQualityKit Xcode統合セットアップ"
echo "============================================"

# 使用法表示
show_usage() {
    echo "使用方法:"
    echo "  $0 setup-build-phase    # Build Phase統合をセットアップ"
    echo "  $0 setup-pre-commit     # Pre-commit hookをセットアップ" 
    echo "  $0 build-time-audit     # ビルド時品質チェック（Build Phaseから呼び出し用）"
    echo "  $0 pre-commit-check     # Pre-commit品質チェック（Git hookから呼び出し用）"
    echo "  $0 install-fswatch      # fswatch依存関係をインストール"
}

# fswatch インストール確認・案内
install_fswatch() {
    echo "📦 fswatch インストール確認..."
    
    if command -v fswatch &> /dev/null; then
        echo "✅ fswatch はすでにインストール済みです"
        fswatch --version
        return 0
    fi
    
    echo "❌ fswatch が見つかりません"
    
    # Homebrew の確認
    if command -v brew &> /dev/null; then
        echo "🍺 Homebrew を使用してfswatch をインストールします..."
        brew install fswatch
        
        if command -v fswatch &> /dev/null; then
            echo "✅ fswatch のインストールが完了しました"
            return 0
        else
            echo "❌ fswatch のインストールに失敗しました"
            return 1
        fi
    else
        echo "❌ Homebrew が見つかりません"
        echo "手動でfswatch をインストールしてください:"
        echo "  1. Homebrew をインストール: https://brew.sh/"
        echo "  2. fswatch をインストール: brew install fswatch"
        return 1
    fi
}

# Build Phase統合セットアップ
setup_build_phase() {
    echo "🏗️ Build Phase統合をセットアップ中..."
    
    local build_script="$SCRIPTS_DIR/build_phase_script.sh"
    
    # Build Phase用スクリプト作成
    cat > "$build_script" << 'EOF'
#!/bin/bash

# SwiftUIQualityKit Build Phase Script
# Xcodeビルド時に品質チェックを実行

PROJECT_ROOT="$SRCROOT"
SCRIPTS_DIR="$PROJECT_ROOT/scripts"

# スクリプトが存在する場合のみ実行
if [[ -f "$SCRIPTS_DIR/xcode_integration.sh" ]]; then
    "$SCRIPTS_DIR/xcode_integration.sh" build-time-audit
else
    echo "⚠️ SwiftUIQualityKit scripts not found at $SCRIPTS_DIR"
fi
EOF
    
    chmod +x "$build_script"
    
    echo "✅ Build Phase スクリプトを作成: $build_script"
    echo ""
    echo "📋 Xcode設定手順:"
    echo "1. Xcodeでプロジェクトを開く"
    echo "2. プロジェクト設定 → TARGETS → Build Phases を選択"
    echo "3. '+' ボタンをクリック → 'New Run Script Phase' を選択"
    echo "4. スクリプト内容に以下を追加:"
    echo "   \"\${SRCROOT}/scripts/build_phase_script.sh\""
    echo "5. 'Run script only when installing' のチェックを外す"
    echo ""
}

# Pre-commit hook セットアップ
setup_pre_commit() {
    echo "🔒 Pre-commit hook をセットアップ中..."
    
    local git_hooks_dir="$PROJECT_ROOT/.git/hooks"
    local pre_commit_hook="$git_hooks_dir/pre-commit"
    
    # .gitディレクトリの確認
    if [[ ! -d "$PROJECT_ROOT/.git" ]]; then
        echo "❌ このディレクトリはGitリポジトリではありません"
        return 1
    fi
    
    # hooksディレクトリ作成
    mkdir -p "$git_hooks_dir"
    
    # 既存のpre-commit hookのバックアップ
    if [[ -f "$pre_commit_hook" ]]; then
        echo "📋 既存のpre-commit hookをバックアップ中..."
        cp "$pre_commit_hook" "$pre_commit_hook.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Pre-commit hook作成
    cat > "$pre_commit_hook" << 'EOF'
#!/bin/bash

# SwiftUIQualityKit Pre-commit Hook
# コミット前に品質チェックを実行

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
SCRIPTS_DIR="$PROJECT_ROOT/scripts"

echo "🔍 SwiftUIQualityKit Pre-commit チェック実行中..."

# スクリプトが存在する場合のみ実行
if [[ -f "$SCRIPTS_DIR/xcode_integration.sh" ]]; then
    "$SCRIPTS_DIR/xcode_integration.sh" pre-commit-check
    exit_code=$?
    
    if [[ $exit_code -ne 0 ]]; then
        echo ""
        echo "❌ 品質チェックに失敗しました。コミットを中止します。"
        echo "修正後に再度コミットしてください。"
        exit $exit_code
    fi
else
    echo "⚠️ SwiftUIQualityKit scripts not found"
fi

echo "✅ 品質チェック完了 - コミット続行"
EOF
    
    chmod +x "$pre_commit_hook"
    
    echo "✅ Pre-commit hook をインストール: $pre_commit_hook"
    echo "📋 以降、git commit 時に自動で品質チェックが実行されます"
    echo ""
}

# ビルド時品質チェック（軽量版）
build_time_audit() {
    echo "🏗️ ビルド時品質チェック実行中..."
    
    # 高速チェックのため、重要な問題のみに絞る
    local swift_files=$(find "$PROJECT_ROOT" -name "*.swift" -type f | grep -v "/build/" | head -20)
    local issues_found=0
    
    # 言語混在の重要な問題のみ
    echo "📝 重要な言語混在をチェック中..."
    for file in $swift_files; do
        if grep -q '"[PFC]:' "$file" 2>/dev/null; then
            echo "⚠️ PFC表記の言語混在: $(basename "$file")"
            ((issues_found++))
        fi
    done
    
    # 重大な未実装問題のみ
    echo "🚧 重要な未実装箇所をチェック中..."
    for file in $swift_files; do
        if grep -q '// TODO.*CRITICAL\|// FIXME.*CRITICAL' "$file" 2>/dev/null; then
            echo "🔴 CRITICAL未実装: $(basename "$file")"
            ((issues_found++))
        fi
    done
    
    if (( issues_found > 0 )); then
        echo "⚠️ $issues_found 件の重要な問題を発見しました"
        echo "詳細確認: ./scripts/ui_audit.sh を実行してください"
    else
        echo "✅ ビルド時品質チェック完了"
    fi
    
    # 警告レベルなので、ビルドは継続
    return 0
}

# Pre-commit品質チェック（厳格版）
pre_commit_check() {
    echo "🔒 Pre-commit品質チェック実行中..."
    
    # Gitでステージングされたファイルのみチェック
    local staged_swift_files=$(git diff --cached --name-only --diff-filter=ACM | grep '\.swift$' || true)
    
    if [[ -z "$staged_swift_files" ]]; then
        echo "📄 Swiftファイルの変更なし - チェックスキップ"
        return 0
    fi
    
    local critical_issues=0
    
    echo "📝 ステージングされたファイルをチェック中..."
    for file in $staged_swift_files; do
        local full_path="$PROJECT_ROOT/$file"
        
        if [[ ! -f "$full_path" ]]; then
            continue
        fi
        
        # 重要な言語混在チェック
        if grep -q '"[PFC]:' "$full_path" 2>/dev/null; then
            echo "❌ PFC表記の統一が必要: $file"
            echo "   自動修正: ./scripts/language_fixer.sh を実行してください"
            ((critical_issues++))
        fi
        
        # クリティカルな未実装チェック
        if grep -q '// TODO.*CRITICAL\|// FIXME.*CRITICAL\|throw.*NotImplemented' "$full_path" 2>/dev/null; then
            echo "❌ クリティカルな未実装: $file"
            ((critical_issues++))
        fi
        
        # @State過多チェック（厳格）
        local state_count=$(grep -c '@State' "$full_path" 2>/dev/null || echo 0)
        if (( state_count > 10 )); then
            echo "⚠️ @State過多 ($state_count個): $file - リファクタリング推奨"
        fi
    done
    
    if (( critical_issues > 0 )); then
        echo ""
        echo "❌ $critical_issues 件のクリティカルな問題があります"
        echo "修正してから再度コミットしてください"
        return 1
    fi
    
    echo "✅ Pre-commit品質チェック完了"
    return 0
}

# メイン処理
main() {
    case "${1:-}" in
        "setup-build-phase")
            setup_build_phase
            ;;
        "setup-pre-commit")
            setup_pre_commit
            ;;
        "build-time-audit")
            build_time_audit
            ;;
        "pre-commit-check")
            pre_commit_check
            ;;
        "install-fswatch")
            install_fswatch
            ;;
        *)
            show_usage
            exit 1
            ;;
    esac
}

main "$@"