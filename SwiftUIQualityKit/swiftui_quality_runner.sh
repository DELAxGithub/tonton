#!/bin/bash

# SwiftUIQualityKit - 統合実行スクリプト
# 全品質チェッカーを統合して実行する

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
RESULTS_DIR="$PROJECT_ROOT/scripts/audit_results"

# 設定
RUN_MODE="${1:-full}"  # full, fast, critical
OUTPUT_FORMAT="${2:-text}"  # text, json, markdown
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')

echo "🚀 SwiftUIQualityKit 統合品質チェック"
echo "===================================="
echo "実行モード: $RUN_MODE"
echo "出力形式: $OUTPUT_FORMAT"
echo "プロジェクト: $(basename "$PROJECT_ROOT")"
echo "時刻: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# 結果ディレクトリ作成
mkdir -p "$RESULTS_DIR"

# 統合レポートファイル
INTEGRATED_REPORT="$RESULTS_DIR/integrated_report_$TIMESTAMP.txt"
JSON_REPORT="$RESULTS_DIR/integrated_report_$TIMESTAMP.json"
SUMMARY_REPORT="$RESULTS_DIR/quality_summary_$TIMESTAMP.txt"

> "$INTEGRATED_REPORT"
> "$JSON_REPORT"
> "$SUMMARY_REPORT"

# JSON出力開始
if [[ "$OUTPUT_FORMAT" == "json" ]]; then
    echo '{' >> "$JSON_REPORT"
    echo '  "timestamp": "'$(date -Iseconds)'",' >> "$JSON_REPORT"
    echo '  "project": "'$(basename "$PROJECT_ROOT")'",' >> "$JSON_REPORT"
    echo '  "mode": "'$RUN_MODE'",' >> "$JSON_REPORT"
    echo '  "results": {' >> "$JSON_REPORT"
fi

# スクリプト実行状況追跡（連想配列の代替実装）
script_status_ui_audit=""
script_status_swiftui=""
script_status_cloudkit=""
script_issues_ui_audit=0
script_issues_swiftui=0
script_issues_cloudkit=0
total_issues=0
critical_issues=0

# ヘルプ表示
show_usage() {
    echo "使用方法:"
    echo "  $0 [モード] [出力形式]"
    echo ""
    echo "モード:"
    echo "  full     - 全チェックを実行（デフォルト）"
    echo "  fast     - 重要チェックのみ実行"
    echo "  critical - クリティカル問題のみチェック"
    echo ""
    echo "出力形式:"
    echo "  text     - テキスト形式（デフォルト）"
    echo "  json     - JSON形式"
    echo "  markdown - Markdown形式"
    echo ""
    echo "例:"
    echo "  $0 fast text"
    echo "  $0 full json"
}

# JSON用エスケープ関数
json_escape() {
    echo "$1" | sed 's/"/\\"/g' | sed 's/$/\\n/' | tr -d '\n'
}

# 個別スクリプト実行関数
run_checker() {
    local script_name="$1"
    local script_path="$SCRIPT_DIR/$script_name"
    local display_name="$2"
    
    if [[ ! -f "$script_path" ]]; then
        echo "⚠️ $display_name スクリプトが見つかりません: $script_path"
        script_status["$script_name"]="missing"
        return 1
    fi
    
    echo "🔍 $display_name を実行中..."
    
    # 一時ファイル
    local temp_output="/tmp/quality_check_${script_name}_$$"
    
    # スクリプト実行
    if timeout 120 "$script_path" > "$temp_output" 2>&1; then
        local issues_count=$(grep -c '件$' "$temp_output" 2>/dev/null || echo 0)
        script_status["$script_name"]="success"
        script_issues["$script_name"]=$issues_count
        total_issues=$((total_issues + issues_count))
        
        echo "  ✅ 完了 ($issues_count 件の問題)"
    else
        echo "  ❌ 実行エラーまたはタイムアウト"
        script_status["$script_name"]="error"
        script_issues["$script_name"]=0
    fi
    
    # 結果を統合レポートに追加
    echo "=== $display_name ===" >> "$INTEGRATED_REPORT"
    cat "$temp_output" >> "$INTEGRATED_REPORT"
    echo "" >> "$INTEGRATED_REPORT"
    
    # JSON形式の場合
    if [[ "$OUTPUT_FORMAT" == "json" ]]; then
        echo "    \"$script_name\": {" >> "$JSON_REPORT"
        echo "      \"status\": \"${script_status[$script_name]}\"," >> "$JSON_REPORT"
        echo "      \"issues_count\": ${script_issues[$script_name]}," >> "$JSON_REPORT"
        echo "      \"output\": \"$(json_escape "$(cat "$temp_output")")\"" >> "$JSON_REPORT"
        echo "    }," >> "$JSON_REPORT"
    fi
    
    rm -f "$temp_output"
}

# 実行モードに応じたチェック実行
case "$RUN_MODE" in
    "fast")
        echo "⚡ 高速モード - 重要チェックのみ実行"
        echo ""
        
        run_checker "ui_audit.sh" "UI品質監査（重要問題）"
        run_checker "swiftui_quality_checker.sh" "SwiftUI品質チェック"
        ;;
        
    "critical")
        echo "🔴 クリティカルモード - 重大問題のみチェック"
        echo ""
        
        # カスタムクリティカルチェック
        echo "🔍 クリティカル問題を検索中..."
        
        local swift_files=$(find "$PROJECT_ROOT" -name "*.swift" -type f | grep -v "/build/")
        local critical_count=0
        
        for file in $swift_files; do
            if grep -q '// TODO.*CRITICAL\|// FIXME.*CRITICAL\|throw.*NotImplemented' "$file" 2>/dev/null; then
                echo "🔴 CRITICAL: $(basename "$file")" >> "$INTEGRATED_REPORT"
                ((critical_count++))
            fi
        done
        
        script_issues["critical"]=$critical_count
        total_issues=$critical_count
        critical_issues=$critical_count
        
        echo "  ✅ クリティカル問題: $critical_count 件"
        ;;
        
    "full")
        echo "🎯 フルモード - 全品質チェック実行"
        echo ""
        
        run_checker "ui_audit.sh" "UI品質監査"
        run_checker "swiftui_quality_checker.sh" "SwiftUI品質チェック"
        run_checker "cloudkit_quality_checker.sh" "CloudKit統合品質チェック"
        
        # 言語統一チェック（実際の修正はしない）
        echo "🔍 言語統一状況をチェック中..."
        local language_issues=$(find "$PROJECT_ROOT" -name "*.swift" -exec grep -l '"[PFC]:' {} \; 2>/dev/null | wc -l)
        language_issues=${language_issues// /}  # 空白削除
        script_issues["language_check"]=$language_issues
        total_issues=$((total_issues + language_issues))
        echo "  ✅ 言語混在問題: $language_issues 件"
        
        echo "=== 言語統一状況 ===" >> "$INTEGRATED_REPORT"
        echo "言語混在問題: $language_issues 件" >> "$INTEGRATED_REPORT"
        echo "" >> "$INTEGRATED_REPORT"
        ;;
        
    *)
        show_usage
        exit 1
        ;;
esac

# サマリーレポート作成
echo ""
echo "📊 品質チェック結果サマリー"
echo "=========================="

{
    echo "SwiftUIQualityKit 統合品質レポート"
    echo "=================================="
    echo "実行日時: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "プロジェクト: $(basename "$PROJECT_ROOT")"
    echo "実行モード: $RUN_MODE"
    echo ""
    echo "📈 実行結果:"
    
    for script in "${!script_status[@]}"; do
        local status="${script_status[$script]}"
        local issues="${script_issues[$script]}"
        local icon="❓"
        
        case "$status" in
            "success") icon="✅" ;;
            "error") icon="❌" ;;
            "missing") icon="⚠️" ;;
        esac
        
        echo "$icon $script: $issues 件の問題"
    done
    
    echo ""
    echo "📊 統計:"
    echo "合計問題数: $total_issues 件"
    echo "クリティカル: $critical_issues 件"
    echo ""
    
    if (( total_issues == 0 )); then
        echo "🎉 検出された品質問題はありません！"
        echo "プロジェクトは良好な状態です。"
    elif (( total_issues <= 10 )); then
        echo "✨ 軽微な問題のみです。"
        echo "必要に応じて修正を検討してください。"
    elif (( total_issues <= 50 )); then
        echo "⚠️ 中程度の問題があります。"
        echo "段階的な改善をお勧めします。"
    else
        echo "🔴 多数の問題が検出されました。"
        echo "組織的な改善計画の策定をお勧めします。"
    fi
    
} | tee -a "$SUMMARY_REPORT"

# JSON出力終了
if [[ "$OUTPUT_FORMAT" == "json" ]]; then
    # 最後のカンマを削除
    sed -i '' '$s/,$//' "$JSON_REPORT"
    echo '  },' >> "$JSON_REPORT"
    echo '  "summary": {' >> "$JSON_REPORT"
    echo '    "total_issues": '$total_issues',' >> "$JSON_REPORT"
    echo '    "critical_issues": '$critical_issues',' >> "$JSON_REPORT"
    echo '    "status": "'$([ $total_issues -eq 0 ] && echo "excellent" || [ $total_issues -le 10 ] && echo "good" || [ $total_issues -le 50 ] && echo "moderate" || echo "needs_attention")'"' >> "$JSON_REPORT"
    echo '  }' >> "$JSON_REPORT"
    echo '}' >> "$JSON_REPORT"
fi

# 出力ファイル情報
echo ""
echo "📄 出力ファイル:"
echo "統合レポート: $INTEGRATED_REPORT"
echo "サマリー: $SUMMARY_REPORT"
if [[ "$OUTPUT_FORMAT" == "json" ]]; then
    echo "JSON形式: $JSON_REPORT"
fi

# 次のアクション提案
echo ""
echo "🎯 推奨次アクション:"

if (( total_issues > 20 )); then
    echo "1. 自動修正可能な問題から対応:"
    echo "   ./language_fixer.sh  # 言語統一"
    echo ""
    echo "2. 段階的改善を開始:"
    echo "   ./watch_mode.sh      # リアルタイム監視で新規問題防止"
fi

if (( critical_issues > 0 )); then
    echo "🔴 クリティカル問題を優先対応してください"
fi

if (( total_issues <= 5 )); then
    echo "✨ 品質維持のため定期監視を継続:"
    echo "   ./watch_mode.sh      # リアルタイム監視"
fi

echo ""
echo "SwiftUIQualityKit 統合実行完了 ✅"

# 終了コード決定
if (( critical_issues > 0 )); then
    exit 2  # クリティカル問題あり
elif (( total_issues > 50 )); then
    exit 1  # 多数の問題あり
else
    exit 0  # 正常終了
fi