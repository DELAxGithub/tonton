# Icon Font Generation

This project uses custom SVG icons located in `assets/icons/svg`.
To compile these icons into a font file run one of the provided scripts:

```bash
# Bash script (Unix-like systems)
./tools/generate_icon_font.sh

# Dart wrapper (cross‑platform)
dart run tools/generate_icon_font.dart
```

Both scripts require [FontForge](https://fontforge.org/) to be installed and
will produce `assets/fonts/TontonIcons.ttf`, which is included in
`pubspec.yaml`. Commit the updated font when icons change so other developers
can use the new glyphs.
