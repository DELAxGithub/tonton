#!/bin/bash

# TonTon UI監査スクリプト
# アプリのUI品質をチェックし、問題箇所を特定する

echo "🔍 TonTon UI監査を開始します..."
echo "================================"

SWIFT_FILES=$(find Tonton/Tonton -name "*.swift" -type f)
RESULTS_DIR="scripts/audit_results"
mkdir -p "$RESULTS_DIR"

# 1. 言語混在チェック
echo "📝 言語混在チェック..."
> "$RESULTS_DIR/language_issues.txt"

echo "=== 英語テキスト検出 ===" >> "$RESULTS_DIR/language_issues.txt"
for file in $SWIFT_FILES; do
    # Text()内の英語テキストを検索
    grep -n 'Text("[^"]*[A-Za-z]' "$file" | grep -v 'systemName\|font\|color' >> "$RESULTS_DIR/language_issues.txt" 2>/dev/null
    
    # Button内の英語テキストを検索
    grep -n 'Button.*"[^"]*[A-Za-z]' "$file" >> "$RESULTS_DIR/language_issues.txt" 2>/dev/null
done

# PFC表記の検出
echo "=== PFC表記検出 ===" >> "$RESULTS_DIR/language_issues.txt"
for file in $SWIFT_FILES; do
    grep -n '"[PFC]:' "$file" >> "$RESULTS_DIR/language_issues.txt" 2>/dev/null
done

# 2. 未実装ボタンチェック
echo "🚧 未実装ボタンチェック..."
> "$RESULTS_DIR/unimplemented_buttons.txt"

echo "=== 空のアクションを持つボタン ===" >> "$RESULTS_DIR/unimplemented_buttons.txt"
for file in $SWIFT_FILES; do
    # 空のクロージャやコメントアウトを検索
    grep -A3 -B3 'Button.*{' "$file" | grep -B3 -A3 '//.*TODO\|//.*Navigate\|//.*Handle\|// ' >> "$RESULTS_DIR/unimplemented_buttons.txt" 2>/dev/null
done

# 3. ナビゲーション複雑度チェック
echo "🗺️ ナビゲーション複雑度チェック..."
> "$RESULTS_DIR/navigation_complexity.txt"

echo "=== Sheet使用状況 ===" >> "$RESULTS_DIR/navigation_complexity.txt"
for file in $SWIFT_FILES; do
    sheet_count=$(grep -c '\.sheet(' "$file" 2>/dev/null || echo 0)
    if [ "$sheet_count" -gt 2 ]; then
        echo "$file: $sheet_count sheets" >> "$RESULTS_DIR/navigation_complexity.txt"
    fi
done

echo "=== State変数の数 ===" >> "$RESULTS_DIR/navigation_complexity.txt"
for file in $SWIFT_FILES; do
    state_count=$(grep -c '@State' "$file" 2>/dev/null || echo 0)
    if [ "$state_count" -gt 5 ]; then
        echo "$file: $state_count @State variables" >> "$RESULTS_DIR/navigation_complexity.txt"
    fi
done

# 4. 重複コンポーネントチェック
echo "🔄 重複コンポーネントチェック..."
> "$RESULTS_DIR/duplicate_components.txt"

echo "=== 類似の設定項目 ===" >> "$RESULTS_DIR/duplicate_components.txt"
grep -r "AI設定\|HealthKit\|iCloud同期\|統合設定" $SWIFT_FILES >> "$RESULTS_DIR/duplicate_components.txt" 2>/dev/null

# 結果サマリー
echo ""
echo "📊 監査結果サマリー"
echo "==================="

language_issues=$(wc -l < "$RESULTS_DIR/language_issues.txt" 2>/dev/null || echo 0)
unimplemented=$(grep -c "TODO\|Navigate\|Handle" "$RESULTS_DIR/unimplemented_buttons.txt" 2>/dev/null || echo 0)
high_complexity_files=$(grep -c "sheets\|variables" "$RESULTS_DIR/navigation_complexity.txt" 2>/dev/null || echo 0)

echo "🌐 言語関連の問題: $language_issues 件"
echo "🚧 未実装ボタン: $unimplemented 件"
echo "🗺️ 高複雑度ファイル: $high_complexity_files 件"

echo ""
echo "詳細な結果は scripts/audit_results/ フォルダを確認してください"
echo "監査完了 ✅"