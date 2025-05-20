# Icon Font Generation

This project uses custom SVG icons located in `assets/icons/svg`.
To compile these icons into a font file run:

```bash
./tools/generate_icon_font.sh
```

The script requires [FontForge](https://fontforge.org/) to be installed.
It will produce `assets/fonts/TontonIcons.ttf` which is included in `pubspec.yaml`.
Commit the updated font when icons change so other developers can use the new glyphs.
