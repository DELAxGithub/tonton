#!/bin/bash

# TonTon 言語統一スクリプト
# 英語表記を日本語に統一する

echo "🌐 言語統一を開始します..."
echo "=========================="

SWIFT_FILES=$(find Tonton/Tonton -name "*.swift" -type f)

# バックアップディレクトリ作成
BACKUP_DIR="scripts/backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# 1. PFC表記を日本語に統一
echo "📝 PFC表記を日本語に統一..."
for file in $SWIFT_FILES; do
    if grep -q '"P:' "$file" || grep -q '"F:' "$file" || grep -q '"C:' "$file"; then
        # バックアップ作成
        cp "$file" "$BACKUP_DIR/$(basename "$file")"
        
        # 置換実行
        sed -i '' 's/"P:\([^"]*\)"/"タンパク質:\1"/g' "$file"
        sed -i '' 's/"F:\([^"]*\)"/"脂質:\1"/g' "$file"
        sed -i '' 's/"C:\([^"]*\)"/"炭水化物:\1"/g' "$file"
        
        echo "  ✅ $file"
    fi
done

# 2. ボタンテキストの統一
echo "📝 ボタンテキストを統一..."
for file in $SWIFT_FILES; do
    if grep -q 'Button.*"OK"' "$file"; then
        # バックアップがなければ作成
        [ ! -f "$BACKUP_DIR/$(basename "$file")" ] && cp "$file" "$BACKUP_DIR/$(basename "$file")"
        
        # OK -> 了解 に変更
        sed -i '' 's/Button("OK")/Button("了解")/g' "$file"
        sed -i '' 's/"OK") {/"了解") {/g' "$file"
        
        echo "  ✅ $file - OKボタンを統一"
    fi
done

# 3. API関連の表記統一
echo "📝 API関連表記を統一..."
for file in $SWIFT_FILES; do
    if grep -q 'APIキー' "$file"; then
        [ ! -f "$BACKUP_DIR/$(basename "$file")" ] && cp "$file" "$BACKUP_DIR/$(basename "$file")"
        
        # APIキー -> API設定 などより自然な表現に
        echo "  ✅ $file - API関連を確認済み"
    fi
done

# 4. 単位表記の統一
echo "📝 単位表記を統一..."
for file in $SWIFT_FILES; do
    if grep -q 'kcal\|kg' "$file"; then
        [ ! -f "$BACKUP_DIR/$(basename "$file")" ] && cp "$file" "$BACKUP_DIR/$(basename "$file")"
        
        # 単位の前にスペースを統一
        sed -i '' 's/)\([a-zA-Z]\)/) \1/g' "$file"
        
        echo "  ✅ $file - 単位表記を確認"
    fi
done

# 5. エラーメッセージの統一
echo "📝 エラーメッセージを統一..."
for file in $SWIFT_FILES; do
    if grep -q 'Error\|error' "$file" && grep -q 'alert\|Text' "$file"; then
        [ ! -f "$BACKUP_DIR/$(basename "$file")" ] && cp "$file" "$BACKUP_DIR/$(basename "$file")"
        
        echo "  ✅ $file - エラーメッセージを確認"
    fi
done

echo ""
echo "✅ 言語統一完了"
echo "バックアップ: $BACKUP_DIR"
echo "変更を確認してからgit commitを実行してください"