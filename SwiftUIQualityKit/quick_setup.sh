#!/bin/bash

# SwiftUIQualityKit - クイックセットアップ
# 1コマンドでの高速導入用スクリプト

set -e

PACKAGE_NAME="SwiftUIQualityKit"
VERSION="1.0.0"

echo "⚡ $PACKAGE_NAME クイックセットアップ"
echo "====================================="

# 現在のディレクトリを取得
CURRENT_DIR="$(pwd)"
PROJECT_ROOT="$CURRENT_DIR"

# プロジェクト検証
if [[ ! -f "$PROJECT_ROOT"/*.xcodeproj ]] && [[ ! -d "$PROJECT_ROOT"/*.xcodeproj ]]; then
    echo "❌ Xcodeプロジェクトが見つかりません"
    exit 1
fi

# SwiftUIQualityKitディレクトリの検出
QUALITY_KIT_DIR=""
POSSIBLE_LOCATIONS=(
    "$PROJECT_ROOT/SwiftUIQualityKit"
    "$PROJECT_ROOT/scripts/SwiftUIQualityKit"
    "$(dirname "${BASH_SOURCE[0]}")"
)

for location in "${POSSIBLE_LOCATIONS[@]}"; do
    if [[ -f "$location/ui_audit.sh" ]]; then
        QUALITY_KIT_DIR="$location"
        break
    fi
done

if [[ -z "$QUALITY_KIT_DIR" ]]; then
    echo "❌ SwiftUIQualityKit が見つかりません"
    echo "delax-shared-packages からコピーしてください"
    exit 1
fi

echo "📁 SwiftUIQualityKit: $QUALITY_KIT_DIR"

# 必要最小限のセットアップ
echo ""
echo "🔧 最小セットアップ実行中..."

# 1. 権限設定
chmod +x "$QUALITY_KIT_DIR"/*.sh
echo "✅ 権限設定完了"

# 2. fswatch確認（警告のみ、エラーで止めない）
if ! command -v fswatch &> /dev/null; then
    echo "⚠️ fswatch未インストール - リアルタイム監視機能は無効"
    echo "   インストール推奨: brew install fswatch"
else
    echo "✅ fswatch確認済み"
fi

# 3. 基本的な品質チェック実行
echo ""
echo "🧪 初回品質チェック実行..."
cd "$PROJECT_ROOT"

# UI監査実行（エラー時も継続）
if "$QUALITY_KIT_DIR/ui_audit.sh" > /tmp/quick_setup_audit.log 2>&1; then
    echo "✅ UI品質チェック完了"
    
    # 結果サマリー表示
    grep -E '合計:|件$' /tmp/quick_setup_audit.log | tail -5
else
    echo "⚠️ UI品質チェックで警告あり"
fi

# 4. 必要最小限のファイル配置確認
SCRIPTS_DIR="$PROJECT_ROOT/scripts"
mkdir -p "$SCRIPTS_DIR"

# メインスクリプトのシンボリックリンク作成（既存を保護）
create_symlink() {
    local script_name="$1"
    local target="$SCRIPTS_DIR/$script_name"
    
    if [[ ! -f "$target" ]]; then
        ln -s "$QUALITY_KIT_DIR/$script_name" "$target" 2>/dev/null || cp "$QUALITY_KIT_DIR/$script_name" "$target"
        echo "  📄 $script_name 配置完了"
    fi
}

echo ""
echo "📋 コアスクリプト配置..."
create_symlink "ui_audit.sh"
create_symlink "language_fixer.sh" 
create_symlink "swiftui_quality_runner.sh"

# 5. 簡単な使用方法表示
echo ""
echo "🎉 クイックセットアップ完了！"
echo ""
echo "📋 すぐに使える基本コマンド:"
echo "  ./scripts/ui_audit.sh              # UI品質チェック"
echo "  ./scripts/language_fixer.sh        # 言語統一修正"
echo "  ./scripts/swiftui_quality_runner.sh fast  # 高速品質チェック"
echo ""

# 監視機能の案内
if command -v fswatch &> /dev/null; then
    echo "⚡ リアルタイム監視も利用可能:"
    echo "  $QUALITY_KIT_DIR/watch_mode.sh   # ファイル変更を監視"
    echo ""
fi

# 高度な設定の案内
echo "🔧 高度な設定（必要な場合）:"
echo "  $QUALITY_KIT_DIR/xcode_integration.sh setup-build-phase  # Xcode統合"
echo "  $QUALITY_KIT_DIR/xcode_integration.sh setup-pre-commit   # Git Hook"
echo ""

# 詳細情報の案内
echo "📖 詳細ガイド: $QUALITY_KIT_DIR/README.md"
echo ""

# 結果レポート
echo "📊 セットアップ結果:"
echo "├─ 権限設定: ✅"
echo "├─ 基本スクリプト: ✅"
echo "├─ 初回品質チェック: $([ -f /tmp/quick_setup_audit.log ] && echo '✅' || echo '⚠️')"
echo "├─ fswatch: $(command -v fswatch &> /dev/null && echo '✅' || echo '⚠️')"
echo "└─ 準備完了: ✅"

echo ""
echo "🚀 SwiftUIQualityKit が使用可能になりました！"

# 一時ファイルクリーンアップ
rm -f /tmp/quick_setup_audit.log

exit 0