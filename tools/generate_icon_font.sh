#!/bin/bash

# Script to generate a TTF icon font from SVGs using FontForge
# Requires FontForge to be installed and accessible via the `fontforge` command.

set -e

SVG_DIR="$(dirname "$0")/../assets/icons/svg"
OUTPUT_DIR="$(dirname "$0")/../assets/fonts"
FONT_NAME="TontonIcons"

if ! command -v fontforge >/dev/null 2>&1; then
  echo "FontForge is required but was not found. Please install FontForge." >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

fontforge -lang=py -c "import fontforge, os, sys
font = fontforge.font()
for file in sorted(os.listdir(sys.argv[1])):
    if file.endswith('.svg'):
        glyph = font.createChar(-1, os.path.splitext(file)[0])
        glyph.importOutlines(os.path.join(sys.argv[1], file))
font.generate(os.path.join(sys.argv[2], sys.argv[3] + '.ttf'))" "$SVG_DIR" "$OUTPUT_DIR" "$FONT_NAME"

echo "Generated $OUTPUT_DIR/$FONT_NAME.ttf"
