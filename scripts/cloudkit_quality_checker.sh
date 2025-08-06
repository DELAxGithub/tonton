#!/bin/bash

# SwiftUIQualityKit - CloudKit特化品質チェック
# CloudKit + SwiftData統合の品質問題を検出し、改善提案を行う

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SWIFT_FILES=$(find "$PROJECT_ROOT" -name "*.swift" -type f | grep -v "/build/" | grep -v "/.build/" | grep -v "/DerivedData/")
RESULTS_DIR="$PROJECT_ROOT/scripts/audit_results"
mkdir -p "$RESULTS_DIR"

echo "☁️ CloudKit特化品質チェックを開始..."
echo "==================================="

# CloudKit品質チェック結果ファイル
CLOUDKIT_ISSUES="$RESULTS_DIR/cloudkit_quality_issues.txt"
> "$CLOUDKIT_ISSUES"

# 1. SwiftData + CloudKit統合品質チェック
echo "🗄️ SwiftData + CloudKit統合をチェック中..."
echo "=== SwiftData + CloudKit統合問題 ===" >> "$CLOUDKIT_ISSUES"

swiftdata_issues=0
for file in $SWIFT_FILES; do
    # @Model without CloudKit attributes
    if grep -q '@Model' "$file" && grep -q 'CloudKit' "$file" 2>/dev/null; then
        # CloudKit関連の@Modelクラスを特定
        if ! grep -q '@Attribute.*cloudKitPersistencePolicy\|@Relationship.*mergePolicy' "$file" 2>/dev/null; then
            local model_line=$(grep -n '@Model' "$file" | head -1 | cut -d: -f1)
            echo "$file:${model_line}: CloudKit対応@ModelでCloudKit属性が不足 - @Attribute(.cloudKitPersistencePolicy)等の設定を推奨" >> "$CLOUDKIT_ISSUES"
            ((swiftdata_issues++))
        fi
        
        # CKRecord関連の型安全性チェック
        if grep -q 'CKRecord\|CloudKitService' "$file" && ! grep -q 'CloudKitError\|CKError' "$file" 2>/dev/null; then
            echo "$file: CloudKit操作でエラーハンドリングが不足 - CKErrorの適切な処理を追加" >> "$CLOUDKIT_ISSUES"
            ((swiftdata_issues++))
        fi
    fi
    
    # @Query最適化チェック（CloudKit用）
    if grep -q '@Query' "$file" 2>/dev/null; then
        local query_count=$(grep -c '@Query' "$file" 2>/dev/null || echo 0)
        if (( query_count > 3 )); then
            echo "$file: @Query使用過多 ($query_count箇所) - CloudKit同期パフォーマンス向上のため統合を検討" >> "$CLOUDKIT_ISSUES"
            ((swiftdata_issues++))
        fi
        
        # @Query でのソート不足チェック（CloudKitでは重要）
        if grep -q '@Query' "$file" && ! grep -q 'sort:\|order:\|FetchDescriptor' "$file" 2>/dev/null; then
            local query_line=$(grep -n '@Query' "$file" | head -1 | cut -d: -f1)
            echo "$file:${query_line}: @Queryでソート未指定 - CloudKit同期の一貫性のためソート順を指定" >> "$CLOUDKIT_ISSUES"
            ((swiftdata_issues++))
        fi
    fi
done

# 2. CloudKit同期パターン品質チェック
echo "🔄 CloudKit同期パターンをチェック中..."
echo "=== CloudKit同期パターン問題 ===" >> "$CLOUDKIT_ISSUES"

sync_pattern_issues=0
for file in $SWIFT_FILES; do
    if grep -q 'CloudKit\|CK' "$file" 2>/dev/null; then
        # 同期エラー処理の適切性チェック
        if grep -q '\.save()\|try.*modelContext' "$file" && ! grep -q 'catch.*CloudKitError\|catch.*CKError' "$file" 2>/dev/null; then
            echo "$file: modelContext.save()でCloudKit特化エラー処理なし - CloudKitErrorの詳細処理を追加" >> "$CLOUDKIT_ISSUES"
            ((sync_pattern_issues++))
        fi
        
        # バッチ操作の適切性チェック
        local save_count=$(grep -c '\.save()' "$file" 2>/dev/null || echo 0)
        if (( save_count > 5 )); then
            echo "$file: modelContext.save()呼び出し過多 ($save_count箇所) - バッチ処理またはバックグラウンド同期の検討" >> "$CLOUDKIT_ISSUES"
            ((sync_pattern_issues++))
        fi
        
        # CloudKit制限の考慮チェック
        if grep -q '\.insert\|\.delete' "$file" && ! grep -q 'batch\|background\|queue' "$file" 2>/dev/null; then
            local operation_line=$(grep -n '\.insert\|\.delete' "$file" | head -1 | cut -d: -f1)
            echo "$file:${operation_line}: CloudKit操作でバックグラウンド処理未使用 - UIブロック回避のため検討" >> "$CLOUDKIT_ISSUES"
            ((sync_pattern_issues++))
        fi
    fi
done

# 3. CloudKit Schema設計品質チェック
echo "🏗️ CloudKit Schema設計をチェック中..."
echo "=== CloudKit Schema設計問題 ===" >> "$CLOUDKIT_ISSUES"

schema_issues=0
for file in $SWIFT_FILES; do
    if grep -q '@Model' "$file" 2>/dev/null; then
        # @Model でのプライマリキー設計チェック
        if grep -q '@Model' "$file" && ! grep -q '@Attribute.*unique\|@Attribute.*primaryKey\|\.id' "$file" 2>/dev/null; then
            local model_line=$(grep -n '@Model' "$file" | head -1 | cut -d: -f1)
            echo "$file:${model_line}: @ModelでユニークID不足 - CloudKit同期の信頼性向上のためUUID等を追加" >> "$CLOUDKIT_ISSUES"
            ((schema_issues++))
        fi
        
        # リレーションシップ設計チェック
        if grep -q '@Relationship' "$file" 2>/dev/null; then
            if ! grep -q 'deleteRule:\|inverse:' "$file" 2>/dev/null; then
                local relationship_line=$(grep -n '@Relationship' "$file" | head -1 | cut -d: -f1)
                echo "$file:${relationship_line}: @Relationshipで削除ルール未指定 - CloudKitでのデータ整合性のため設定を推奨" >> "$CLOUDKIT_ISSUES"
                ((schema_issues++))
            fi
        fi
        
        # CloudKit制限事項チェック（配列、辞書の使用）
        if grep -q '@Model' "$file" && grep -q '\[.*\]\|\[.*:.*\]' "$file" 2>/dev/null; then
            # 配列や辞書がCloudKit同期対応かチェック
            if ! grep -q 'Codable\|@Attribute.*CloudKit' "$file" 2>/dev/null; then
                echo "$file: @Modelで複合データ型使用 - CloudKit同期のためCodable準拠またはTransformable属性を検討" >> "$CLOUDKIT_ISSUES"
                ((schema_issues++))
            fi
        fi
    fi
done

# 4. CloudKit認証・権限管理チェック
echo "🔐 CloudKit認証・権限管理をチェック中..."
echo "=== CloudKit認証・権限管理問題 ===" >> "$CLOUDKIT_ISSUES"

auth_issues=0
for file in $SWIFT_FILES; do
    if grep -q 'CloudKit\|CKContainer' "$file" 2>/dev/null; then
        # アカウント状態チェックの実装確認
        if grep -q 'CKContainer\|CloudKitService' "$file" && ! grep -q 'accountStatus\|checkAccountStatus' "$file" 2>/dev/null; then
            echo "$file: CloudKitでアカウント状態チェック未実装 - ユーザー体験向上のため追加を推奨" >> "$CLOUDKIT_ISSUES"
            ((auth_issues++))
        fi
        
        # プライベートデータベース使用時の権限チェック
        if grep -q 'privateCloudDatabase\|private.*database' "$file" && ! grep -q 'requestApplicationPermission\|permission' "$file" 2>/dev/null; then
            echo "$file: プライベートDB使用で権限チェック不足 - アクセス許可の確認処理を追加" >> "$CLOUDKIT_ISSUES"
            ((auth_issues++))
        fi
        
        # CloudKit利用不可時のフォールバック確認
        if grep -q 'CloudKit\|CK' "$file" && ! grep -q 'offline\|fallback\|unavailable' "$file" 2>/dev/null; then
            echo "$file: CloudKit利用不可時の処理不足 - オフライン対応またはフォールバック実装を推奨" >> "$CLOUDKIT_ISSUES"
            ((auth_issues++))
        fi
    fi
done

# 5. CloudKit パフォーマンス最適化チェック
echo "⚡ CloudKitパフォーマンス最適化をチェック中..."
echo "=== CloudKitパフォーマンス最適化問題 ===" >> "$CLOUDKIT_ISSUES"

performance_issues=0
for file in $SWIFT_FILES; do
    if grep -q 'CloudKit\|CK.*Query\|fetch' "$file" 2>/dev/null; then
        # 大量データフェッチの最適化チェック
        if grep -q 'fetch\|query' "$file" && ! grep -q 'limit\|resultsLimit\|batch' "$file" 2>/dev/null; then
            local fetch_line=$(grep -n 'fetch\|query' "$file" | head -1 | cut -d: -f1)
            echo "$file:${fetch_line}: データフェッチで制限未設定 - CloudKitクォータ制限回避のため件数制限を追加" >> "$CLOUDKIT_ISSUES"
            ((performance_issues++))
        fi
        
        # 不要な同期頻度チェック
        local cloudkit_calls=$(grep -c 'CloudKit\|\.sync\|\.fetch' "$file" 2>/dev/null || echo 0)
        if (( cloudkit_calls > 10 )); then
            echo "$file: CloudKit操作頻度が高い ($cloudkit_calls箇所) - キャッシュ戦略またはバッチ処理の検討" >> "$CLOUDKIT_ISSUES"
            ((performance_issues++))
        fi
        
        # Background context使用の確認
        if grep -q '\.save()\|\.insert' "$file" && ! grep -q 'background\|perform.*async\|Task' "$file" 2>/dev/null; then
            echo "$file: メインスレッドでCloudKit操作の可能性 - バックグラウンド処理への移行を推奨" >> "$CLOUDKIT_ISSUES"
            ((performance_issues++))
        fi
    fi
done

# 6. CloudKit デバッグ・監視品質チェック
echo "🐛 CloudKitデバッグ・監視をチェック中..."
echo "=== CloudKitデバッグ・監視問題 ===" >> "$CLOUDKIT_ISSUES"

debug_issues=0
for file in $SWIFT_FILES; do
    if grep -q 'CloudKit\|CK' "$file" 2>/dev/null; then
        # ログ出力の適切性チェック
        if grep -q 'CloudKit\|sync' "$file" && ! grep -q 'print\|os_log\|Logger' "$file" 2>/dev/null; then
            echo "$file: CloudKit操作でログ出力不足 - デバッグ効率向上のためログ追加を推奨" >> "$CLOUDKIT_ISSUES"
            ((debug_issues++))
        fi
        
        # エラー詳細情報の取得チェック
        if grep -q 'catch.*Error\|catch.*CK' "$file" && ! grep -q 'localizedDescription\|userInfo\|underlyingError' "$file" 2>/dev/null; then
            local catch_line=$(grep -n 'catch.*Error\|catch.*CK' "$file" | head -1 | cut -d: -f1)
            echo "$file:${catch_line}: エラー詳細情報不足 - CloudKitエラーの詳細取得で問題解決を効率化" >> "$CLOUDKIT_ISSUES"
            ((debug_issues++))
        fi
        
        # 同期状態の可視化チェック
        if grep -q 'sync\|CloudKit' "$file" && grep -q '@State\|@Published' "$file" && ! grep -q 'isSyncing\|syncStatus\|isLoading' "$file" 2>/dev/null; then
            echo "$file: 同期状態の可視化不足 - ユーザー体験向上のため同期インジケーター追加を推奨" >> "$CLOUDKIT_ISSUES"
            ((debug_issues++))
        fi
    fi
done

# 結果サマリー
echo ""
echo "📊 CloudKit品質チェック結果"
echo "=========================="

total_issues=$((swiftdata_issues + sync_pattern_issues + schema_issues + auth_issues + performance_issues + debug_issues))

echo "🗄️ SwiftData統合の問題: $swiftdata_issues 件"
echo "🔄 同期パターンの問題: $sync_pattern_issues 件"
echo "🏗️ Schema設計の問題: $schema_issues 件"
echo "🔐 認証・権限管理の問題: $auth_issues 件"
echo "⚡ パフォーマンスの問題: $performance_issues 件"
echo "🐛 デバッグ・監視の問題: $debug_issues 件"
echo "━━━━━━━━━━━━━━━━━━━━━━"
echo "☁️ 合計: $total_issues 件"

echo ""
echo "詳細な結果: $CLOUDKIT_ISSUES"

if (( total_issues == 0 )); then
    echo "🎉 CloudKit統合品質に大きな問題は見つかりませんでした！"
else
    echo "💡 改善により、CloudKit同期の信頼性とパフォーマンスが向上します"
fi

echo "CloudKit特化品質チェック完了 ✅"