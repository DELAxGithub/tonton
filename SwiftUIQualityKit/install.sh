#!/bin/bash

# SwiftUIQualityKit インストールスクリプト
# delax-shared-packagesからの導入用

set -e

PACKAGE_NAME="SwiftUIQualityKit"
VERSION="1.0.0"

echo "🚀 $PACKAGE_NAME v$VERSION インストール開始"
echo "============================================"

# 現在のディレクトリを取得
CURRENT_DIR="$(pwd)"
INSTALL_DIR="$CURRENT_DIR/scripts/$PACKAGE_NAME"

# プロジェクトルートの検出
PROJECT_ROOT="$CURRENT_DIR"
if [[ ! -f "$PROJECT_ROOT"/*.xcodeproj ]] && [[ ! -d "$PROJECT_ROOT"/*.xcodeproj ]]; then
    echo "❌ Xcodeプロジェクトが見つかりません"
    echo "   iOSプロジェクトのルートディレクトリで実行してください"
    exit 1
fi

echo "📁 プロジェクトルート: $PROJECT_ROOT"
echo "📁 インストール先: $INSTALL_DIR"

# インストール前チェック
echo ""
echo "🔍 インストール前チェック"
echo "========================"

# SwiftUIプロジェクトかチェック
SWIFT_FILES=$(find "$PROJECT_ROOT" -name "*.swift" -type f | head -5)
if [[ -z "$SWIFT_FILES" ]]; then
    echo "❌ Swiftファイルが見つかりません"
    exit 1
fi

# SwiftUI使用確認
HAS_SWIFTUI=false
for file in $SWIFT_FILES; do
    if grep -q 'import SwiftUI\|SwiftUI' "$file" 2>/dev/null; then
        HAS_SWIFTUI=true
        break
    fi
done

if [[ "$HAS_SWIFTUI" = false ]]; then
    echo "⚠️  SwiftUIの使用が確認できません"
    echo "   このツールキットはSwiftUIプロジェクト用に最適化されています"
    read -p "   続行しますか? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ インストールをキャンセルしました"
        exit 1
    fi
else
    echo "✅ SwiftUIプロジェクトを確認"
fi

# CloudKit使用確認（オプション）
HAS_CLOUDKIT=false
for file in $SWIFT_FILES; do
    if grep -q 'import CloudKit\|CloudKit\|@Model' "$file" 2>/dev/null; then
        HAS_CLOUDKIT=true
        break
    fi
done

if [[ "$HAS_CLOUDKIT" = true ]]; then
    echo "✅ CloudKit使用を確認"
else
    echo "ℹ️  CloudKit未使用（一部機能は無効）"
fi

# 依存関係チェック
echo ""
echo "📦 依存関係チェック"
echo "=================="

# fswatch チェック
if command -v fswatch &> /dev/null; then
    echo "✅ fswatch インストール済み ($(fswatch --version | head -1))"
else
    echo "❌ fswatch が見つかりません"
    
    if command -v brew &> /dev/null; then
        echo "🍺 Homebrew で fswatch をインストール中..."
        brew install fswatch
        
        if command -v fswatch &> /dev/null; then
            echo "✅ fswatch インストール完了"
        else
            echo "❌ fswatch インストール失敗"
            exit 1
        fi
    else
        echo "❌ Homebrew が見つかりません"
        echo "手動でインストールしてください:"
        echo "  1. Homebrew: https://brew.sh/"
        echo "  2. fswatch: brew install fswatch"
        exit 1
    fi
fi

# Git確認
if [[ -d "$PROJECT_ROOT/.git" ]]; then
    echo "✅ Git リポジトリを確認"
else
    echo "⚠️  Git リポジトリではありません（Pre-commit hook無効）"
fi

# インストール実行
echo ""
echo "📋 ファイルのコピー"
echo "=================="

# scriptsディレクトリ作成
mkdir -p "$INSTALL_DIR"

# 現在のSwiftUIQualityKitディレクトリから必要ファイルをコピー
SOURCE_DIR="$(dirname "${BASH_SOURCE[0]}")"

if [[ -f "$SOURCE_DIR/ui_audit.sh" ]]; then
    echo "📄 コアスクリプトをコピー中..."
    
    cp "$SOURCE_DIR/ui_audit.sh" "$INSTALL_DIR/"
    cp "$SOURCE_DIR/language_fixer.sh" "$INSTALL_DIR/"
    cp "$SOURCE_DIR/watch_mode.sh" "$INSTALL_DIR/"
    cp "$SOURCE_DIR/swiftui_quality_checker.sh" "$INSTALL_DIR/"
    cp "$SOURCE_DIR/cloudkit_quality_checker.sh" "$INSTALL_DIR/"
    cp "$SOURCE_DIR/xcode_integration.sh" "$INSTALL_DIR/"
    
    # StandardComponents.swift は Tonton/Views/Components/ にコピー
    if [[ -f "$SOURCE_DIR/StandardComponents.swift" ]]; then
        TARGET_COMPONENTS_DIR=""
        
        # Views/Components ディレクトリを探す
        POSSIBLE_DIRS=(
            "$PROJECT_ROOT/*/Views/Components"
            "$PROJECT_ROOT/*/*/Views/Components"
            "$PROJECT_ROOT/Views/Components"
        )
        
        for dir_pattern in "${POSSIBLE_DIRS[@]}"; do
            for dir in $dir_pattern; do
                if [[ -d "$dir" ]]; then
                    TARGET_COMPONENTS_DIR="$dir"
                    break 2
                fi
            done
        done
        
        if [[ -n "$TARGET_COMPONENTS_DIR" ]]; then
            echo "🧩 StandardComponents.swift をコピー: $TARGET_COMPONENTS_DIR"
            cp "$SOURCE_DIR/StandardComponents.swift" "$TARGET_COMPONENTS_DIR/"
        else
            echo "⚠️  Views/Componentsディレクトリが見つかりません"
            echo "   StandardComponents.swiftを手動で適切な場所に配置してください"
        fi
    fi
    
    echo "✅ ファイルコピー完了"
else
    echo "❌ ソースファイルが見つかりません"
    echo "   SwiftUIQualityKit パッケージが正しく配置されているか確認してください"
    exit 1
fi

# 権限設定
echo ""
echo "🔒 権限設定"
echo "=========="

chmod +x "$INSTALL_DIR"/*.sh
echo "✅ 実行権限を設定"

# 設定オプション
echo ""
echo "⚙️  自動化設定（オプション）"
echo "========================="

echo "利用可能な自動化オプション:"
echo "1. Build Phase統合 - Xcodeビルド時の品質チェック"
echo "2. Pre-commit Hook - Gitコミット前の品質チェック"
echo "3. 後で手動設定"
echo ""

read -p "選択してください (1-3): " -n 1 -r
echo

case $REPLY in
    1)
        echo "🏗️ Build Phase統合を設定中..."
        "$INSTALL_DIR/xcode_integration.sh" setup-build-phase
        ;;
    2)
        echo "🔒 Pre-commit Hook を設定中..."
        "$INSTALL_DIR/xcode_integration.sh" setup-pre-commit
        ;;
    3)
        echo "ℹ️  後で以下のコマンドで設定できます:"
        echo "  Build Phase: $INSTALL_DIR/xcode_integration.sh setup-build-phase"
        echo "  Pre-commit: $INSTALL_DIR/xcode_integration.sh setup-pre-commit"
        ;;
esac

# 初回テスト実行
echo ""
echo "🧪 初回テスト実行"
echo "================"

echo "基本的な品質チェックを実行します..."
if [[ -f "$INSTALL_DIR/ui_audit.sh" ]]; then
    cd "$PROJECT_ROOT"
    "$INSTALL_DIR/ui_audit.sh" | head -20
    echo ""
    echo "✅ テスト実行完了"
else
    echo "❌ テストスクリプトが見つかりません"
fi

# インストール完了
echo ""
echo "🎉 $PACKAGE_NAME インストール完了！"
echo "=================================="
echo ""
echo "📋 次のステップ:"
echo "1. 基本的な品質チェック: $INSTALL_DIR/ui_audit.sh"
echo "2. リアルタイム監視開始: $INSTALL_DIR/watch_mode.sh"
echo "3. 言語統一自動修正: $INSTALL_DIR/language_fixer.sh"
echo ""
echo "📖 詳細な使用方法:"
echo "   $INSTALL_DIR/../README.md を参照"
echo ""
echo "🆘 サポート:"
echo "   delax-shared-packages リポジトリで課題報告・改善提案"
echo ""

exit 0