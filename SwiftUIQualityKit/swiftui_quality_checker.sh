#!/bin/bash

# SwiftUIQualityKit - SwiftUI特化品質チェック
# SwiftUI固有の品質問題を検出し、改善提案を行う

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SWIFT_FILES=$(find "$PROJECT_ROOT" -name "*.swift" -type f | grep -v "/build/" | grep -v "/.build/" | grep -v "/DerivedData/")
RESULTS_DIR="$PROJECT_ROOT/scripts/audit_results"
mkdir -p "$RESULTS_DIR"

echo "🎨 SwiftUI特化品質チェックを開始..."
echo "====================================="

# SwiftUI品質チェック結果ファイル
SWIFTUI_ISSUES="$RESULTS_DIR/swiftui_quality_issues.txt"
> "$SWIFTUI_ISSUES"

# 1. State管理品質チェック
echo "📊 State管理品質をチェック中..."
echo "=== State管理品質問題 ===" >> "$SWIFTUI_ISSUES"

state_management_issues=0
for file in $SWIFT_FILES; do
    # @State過多チェック
    state_count=$(grep -c '@State' "$file" 2>/dev/null || echo 0)
    if (( state_count > 8 )); then
        echo "$file: $state_count個の@State変数 - 状態管理の統合を検討" >> "$SWIFTUI_ISSUES"
        ((state_management_issues++))
    fi
    
    # @Published + @State混在チェック
    if grep -q '@State' "$file" && grep -q '@Published' "$file" 2>/dev/null; then
        local state_line=$(grep -n '@State' "$file" | head -1 | cut -d: -f1)
        local published_line=$(grep -n '@Published' "$file" | head -1 | cut -d: -f1)
        echo "$file:${state_line}: @State と @Published の混在 - 状態管理戦略の統一を推奨" >> "$SWIFTUI_ISSUES"
        ((state_management_issues++))
    fi
    
    # @StateObject 不足チェック
    if grep -q 'ObservableObject' "$file" && ! grep -q '@StateObject' "$file" 2>/dev/null; then
        echo "$file: ObservableObject使用時に@StateObjectが未使用 - メモリリーク防止のため@StateObjectを使用" >> "$SWIFTUI_ISSUES"
        ((state_management_issues++))
    fi
done

# 2. パフォーマンス品質チェック
echo "⚡ パフォーマンス品質をチェック中..."
echo "=== パフォーマンス品質問題 ===" >> "$SWIFTUI_ISSUES"

performance_issues=0
for file in $SWIFT_FILES; do
    # Body内での複雑な計算チェック
    if grep -A 10 'var body:' "$file" | grep -q 'calculate\|compute\|process' 2>/dev/null; then
        local body_line=$(grep -n 'var body:' "$file" | head -1 | cut -d: -f1)
        echo "$file:${body_line}: body内で複雑な計算を検出 - @Memoizedまたはcomputed propertyの使用を推奨" >> "$SWIFTUI_ISSUES"
        ((performance_issues++))
    fi
    
    # ForEach でのIDなしオブジェクト使用チェック
    if grep -q 'ForEach(' "$file" && ! grep -q 'id:' "$file" 2>/dev/null; then
        local foreach_line=$(grep -n 'ForEach(' "$file" | head -1 | cut -d: -f1)
        echo "$file:${foreach_line}: ForEachでID未指定 - パフォーマンス向上のためidパラメータを指定" >> "$SWIFTUI_ISSUES"
        ((performance_issues++))
    fi
    
    # 不必要な .onAppear 重複チェック
    local onappear_count=$(grep -c '\.onAppear' "$file" 2>/dev/null || echo 0)
    if (( onappear_count > 3 )); then
        echo "$file: onAppear使用過多 ($onappear_count箇所) - 統合または@StateObject活用を検討" >> "$SWIFTUI_ISSUES"
        ((performance_issues++))
    fi
done

# 3. UI品質・アクセシビリティチェック
echo "♿ アクセシビリティ品質をチェック中..."
echo "=== アクセシビリティ品質問題 ===" >> "$SWIFTUI_ISSUES"

accessibility_issues=0
for file in $SWIFT_FILES; do
    # Button のアクセシビリティチェック
    local button_count=$(grep -c 'Button(' "$file" 2>/dev/null || echo 0)
    local accessibility_count=$(grep -c 'accessibilityLabel\|accessibilityHint\|accessibilityIdentifier' "$file" 2>/dev/null || echo 0)
    
    if (( button_count > 2 && accessibility_count == 0 )); then
        echo "$file: Button使用 ($button_count箇所) でアクセシビリティ属性なし" >> "$SWIFTUI_ISSUES"
        ((accessibility_issues++))
    fi
    
    # Image のアクセシビリティチェック
    if grep -q 'Image(' "$file" && ! grep -q 'accessibilityLabel\|\.decorative' "$file" 2>/dev/null; then
        local image_line=$(grep -n 'Image(' "$file" | head -1 | cut -d: -f1)
        echo "$file:${image_line}: Image要素にアクセシビリティ設定なし - .accessibilityLabel() または .decorative() を追加" >> "$SWIFTUI_ISSUES"
        ((accessibility_issues++))
    fi
    
    # 色のみでの情報伝達チェック（改善推奨）
    if grep -q '\.foregroundColor.*red\|\.foregroundColor.*green' "$file" && ! grep -q 'Text.*エラー\|Text.*成功\|Image.*systemName.*error\|Image.*systemName.*checkmark' "$file" 2>/dev/null; then
        echo "$file: 色のみでの情報伝達を検出 - アイコンやテキストとの併用を推奨" >> "$SWIFTUI_ISSUES"
        ((accessibility_issues++))
    fi
done

# 4. SwiftUI Preview品質チェック
echo "👁️ SwiftUI Preview品質をチェック中..."
echo "=== SwiftUI Preview品質問題 ===" >> "$SWIFTUI_ISSUES"

preview_issues=0
for file in $SWIFT_FILES; do
    # View定義があるがPreviewがない
    if grep -q 'struct.*: View' "$file" && ! grep -q '#Preview\|struct.*_Previews' "$file" 2>/dev/null; then
        local struct_line=$(grep -n 'struct.*: View' "$file" | head -1 | cut -d: -f1)
        echo "$file:${struct_line}: SwiftUI Viewに対するPreviewがありません - 開発効率向上のため#Previewを追加" >> "$SWIFTUI_ISSUES"
        ((preview_issues++))
    fi
    
    # 古いPreview形式チェック
    if grep -q 'struct.*_Previews.*PreviewProvider' "$file" 2>/dev/null; then
        echo "$file: 古いPreview形式 - iOS 17+ では #Preview マクロの使用を推奨" >> "$SWIFTUI_ISSUES"
        ((preview_issues++))
    fi
done

# 5. ナビゲーション品質チェック
echo "🗺️ ナビゲーション品質をチェック中..."
echo "=== ナビゲーション品質問題 ===" >> "$SWIFTUI_ISSUES"

navigation_issues=0
for file in $SWIFT_FILES; do
    # Sheet過多チェック
    local sheet_count=$(grep -c '\.sheet(' "$file" 2>/dev/null || echo 0)
    if (( sheet_count > 4 )); then
        echo "$file: Sheet使用過多 ($sheet_count箇所) - NavigationStackまたは状態管理の見直しを推奨" >> "$SWIFTUI_ISSUES"
        ((navigation_issues++))
    fi
    
    # 古いNavigationView使用チェック
    if grep -q 'NavigationView' "$file" 2>/dev/null; then
        local nav_line=$(grep -n 'NavigationView' "$file" | head -1 | cut -d: -f1)
        echo "$file:${nav_line}: 非推奨のNavigationView使用 - NavigationStackまたはNavigationSplitViewの使用を推奨" >> "$SWIFTUI_ISSUES"
        ((navigation_issues++))
    fi
    
    # @Binding の過度な使用チェック
    local binding_count=$(grep -c '@Binding' "$file" 2>/dev/null || echo 0)
    if (( binding_count > 5 )); then
        echo "$file: @Binding使用過多 ($binding_count箇所) - 状態管理の見直しまたはObservableObjectの活用を検討" >> "$SWIFTUI_ISSUES"
        ((navigation_issues++))
    fi
done

# 6. SwiftUIベストプラクティスチェック
echo "✨ SwiftUIベストプラクティスをチェック中..."
echo "=== SwiftUIベストプラクティス問題 ===" >> "$SWIFTUI_ISSUES"

best_practice_issues=0
for file in $SWIFT_FILES; do
    # GeometryReader の不適切使用チェック
    if grep -q 'GeometryReader' "$file" && ! grep -q '\.frame\|\.size\|\.position' "$file" 2>/dev/null; then
        local geometry_line=$(grep -n 'GeometryReader' "$file" | head -1 | cut -d: -f1)
        echo "$file:${geometry_line}: GeometryReaderの使用目的不明 - 必要性を確認し、代替手法を検討" >> "$SWIFTUI_ISSUES"
        ((best_practice_issues++))
    fi
    
    # 長すぎるView定義チェック
    if grep -q 'var body: some View' "$file"; then
        # body から次の func または struct まで、または EOF までの行数を数える
        local body_start=$(grep -n 'var body: some View' "$file" | head -1 | cut -d: -f1)
        local total_lines=$(wc -l < "$file")
        local body_length=$((total_lines - body_start))
        
        if (( body_length > 50 )); then
            echo "$file:${body_start}: bodyが長すぎます (推定$body_length行) - 小さなViewコンポーネントへの分割を推奨" >> "$SWIFTUI_ISSUES"
            ((best_practice_issues++))
        fi
    fi
    
    # @Environment の未使用チェック
    if grep -q '@Environment' "$file" && ! grep -q '\.modelContext\|\.dismiss\|\.colorScheme\|\.openURL' "$file" 2>/dev/null; then
        local env_line=$(grep -n '@Environment' "$file" | head -1 | cut -d: -f1)
        echo "$file:${env_line}: @Environment定義の使用確認 - 未使用の場合は削除を推奨" >> "$SWIFTUI_ISSUES"
        ((best_practice_issues++))
    fi
done

# 結果サマリー
echo ""
echo "📊 SwiftUI品質チェック結果"
echo "========================="

total_issues=$((state_management_issues + performance_issues + accessibility_issues + preview_issues + navigation_issues + best_practice_issues))

echo "📊 状態管理の問題: $state_management_issues 件"
echo "⚡ パフォーマンスの問題: $performance_issues 件"
echo "♿ アクセシビリティの問題: $accessibility_issues 件"
echo "👁️ Previewの問題: $preview_issues 件"
echo "🗺️ ナビゲーションの問題: $navigation_issues 件"
echo "✨ ベストプラクティスの問題: $best_practice_issues 件"
echo "━━━━━━━━━━━━━━━━━━━━"
echo "🎯 合計: $total_issues 件"

echo ""
echo "詳細な結果: $SWIFTUI_ISSUES"

if (( total_issues == 0 )); then
    echo "🎉 SwiftUI品質に大きな問題は見つかりませんでした！"
else
    echo "💡 改善により、アプリの品質とパフォーマンスが向上します"
fi

echo "SwiftUI特化品質チェック完了 ✅"