#!/bin/bash

# SwiftUIQualityKit - ファイル監視モード
# ファイル変更を監視してリアルタイムでUI品質チェックを実行

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS_DIR="$PROJECT_ROOT/scripts"
SWIFT_SOURCE_DIR="$PROJECT_ROOT/Tonton/Tonton"

# 設定
DEBOUNCE_SECONDS=2  # 変更後の待機時間
LAST_AUDIT_TIME=0
WATCH_EXTENSIONS="swift"

echo "🔍 SwiftUIQualityKit ファイル監視モードを開始"
echo "========================================"
echo "監視対象: $SWIFT_SOURCE_DIR"
echo "監視拡張子: $WATCH_EXTENSIONS"
echo "デバウンス: ${DEBOUNCE_SECONDS}秒"
echo ""
echo "終了するには Ctrl+C を押してください"
echo ""

# fswatch の存在確認
if ! command -v fswatch &> /dev/null; then
    echo "❌ fswatch が見つかりません。インストールしてください:"
    echo "   brew install fswatch"
    exit 1
fi

# デバウンス機能付きファイル変更処理
process_file_change() {
    local changed_file="$1"
    local current_time=$(date +%s)
    
    # Swift ファイル以外は無視
    if [[ ! "$changed_file" =~ \.swift$ ]]; then
        return 0
    fi
    
    # デバウンス処理
    if (( current_time - LAST_AUDIT_TIME < DEBOUNCE_SECONDS )); then
        return 0
    fi
    
    LAST_AUDIT_TIME=$current_time
    
    echo "📝 変更検出: $(basename "$changed_file")"
    echo "⏰ $(date '+%H:%M:%S') - 品質チェック実行中..."
    
    # 差分ベース監査を実行
    run_incremental_audit "$changed_file"
}

# 差分ベース監査（高速化のため変更ファイルのみ対象）
run_incremental_audit() {
    local target_file="$1"
    local temp_results="/tmp/swiftui_quality_check_$(date +%s)"
    
    echo "  🔍 $target_file を監査中..."
    
    # 言語混在チェック（該当ファイルのみ）
    if grep -q 'Text("[^"]*[A-Za-z]' "$target_file" 2>/dev/null; then
        echo "    ⚠️  言語混在の可能性を検出"
        grep -n 'Text("[^"]*[A-Za-z]' "$target_file" | head -3
    fi
    
    # 未実装ボタンチェック（該当ファイルのみ）
    if grep -q 'Button.*{' "$target_file" && grep -q '//.*TODO\|//.*Navigate\|//.*Handle' "$target_file" 2>/dev/null; then
        echo "    🚧 未実装ボタンを検出"
        grep -B2 -A2 '//.*TODO\|//.*Navigate\|//.*Handle' "$target_file" | head -3
    fi
    
    # SwiftUI特化チェック
    run_swiftui_specific_checks "$target_file"
    
    echo "  ✅ $(basename "$target_file") のチェック完了"
    echo ""
}

# SwiftUI特化品質チェック
run_swiftui_specific_checks() {
    local target_file="$1"
    
    # @State 過多チェック
    local state_count=$(grep -c '@State' "$target_file" 2>/dev/null || echo 0)
    if (( state_count > 7 )); then
        echo "    📊 @State変数が多すぎます ($state_count個) - 状態管理の見直しを検討"
    fi
    
    # Sheet過多チェック  
    local sheet_count=$(grep -c '\.sheet(' "$target_file" 2>/dev/null || echo 0)
    if (( sheet_count > 3 )); then
        echo "    📱 Sheet使用が多すぎます ($sheet_count個) - ナビゲーション設計の見直しを検討"
    fi
    
    # Preview不足チェック
    if grep -q 'struct.*View' "$target_file" && ! grep -q '#Preview\|struct.*_Previews' "$target_file" 2>/dev/null; then
        echo "    👁️  SwiftUI Previewがありません - 開発効率向上のため追加を推奨"
    fi
    
    # アクセシビリティ属性不足チェック
    if grep -q 'Button\|Text\|Image' "$target_file" && ! grep -q 'accessibilityLabel\|accessibilityHint' "$target_file" 2>/dev/null; then
        local ui_elements=$(grep -c 'Button\|Text\|Image' "$target_file" 2>/dev/null || echo 0)
        if (( ui_elements > 5 )); then
            echo "    ♿ アクセシビリティ属性の追加を推奨 (UI要素: $ui_elements個)"
        fi
    fi
}

# 全体監査実行（手動トリガー用）
run_full_audit() {
    echo ""
    echo "🔄 全体監査を実行中..."
    cd "$PROJECT_ROOT"
    ./scripts/ui_audit.sh
    echo ""
}

# シグナルハンドラー（Ctrl+C対応）
cleanup() {
    echo ""
    echo "🛑 ファイル監視を終了しています..."
    echo "👋 SwiftUIQualityKit 監視モード終了"
    exit 0
}

trap cleanup SIGINT SIGTERM

# メインループ：fswatch を使用してファイル監視
echo "🟢 監視開始 - ファイルを編集して品質チェックをテストしてください"

# 初回の全体チェック（オプション）
if [[ "${1:-}" == "--full-audit" ]]; then
    run_full_audit
fi

# fswatch でファイル変更を監視
fswatch -r \
    --event=Updated \
    --exclude='.*\.xcuserstate$' \
    --exclude='.*\.DS_Store$' \
    --exclude='.*/\.git/.*' \
    --exclude='.*/build/.*' \
    --exclude='.*/DerivedData/.*' \
    "$SWIFT_SOURCE_DIR" | while read changed_file; do
        process_file_change "$changed_file"
done