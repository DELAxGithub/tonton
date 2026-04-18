# .claude/commands/ — Skill 移植ガイド

グローバル (`~/.claude/commands/`) に置かれた Skill のうち、
**プロジェクト固有のロジックを含むもの**はここにコピーすることで、
リポをクローンした別マシン・別エージェント（Copilot / Antigravity）からも
同じ Skill が呼べるようになる。

## 判定基準

### グローバル維持（ここに **コピーしない**）

汎用でプロジェクト間の差分が出ないもの:

- `push` — Conventional Commits + secrets 検出（言語非依存）
- `review` — 汎用コードレビュー観点
- `devlog` — 固定パス `~/src/devlog/` にのみ書く
- `memory-*` — ユーザ個人の長期記憶
- `session-start` / `handover` — セッション境界の管理
- `security-check` — 汎用 secrets スキャン
- `find` / `project-radar` / `sync` / `task` — `~/src/` 横断ツール

### 持ち込み候補（ここに **コピー可**）

プロジェクトごとに挙動が変わるもの:

- `deploy` — Vercel / Flutter / Capacitor で分岐がある
- `design-check` / `design-style` — プロジェクトのデザインシステムに依存
- `bgm-place` / `platto-edit` / `csvtoxml` / `review-to-markers`
  — 特定パイプライン専用（プラッと / DaVinci 等）
- `kindle-ocr` / `research-report` / `stock-search` / `youtube-summary`
  — 外部 API 接続の形式が異なる
- `journal` / `sd-import` — ローカルパス依存

## 移植手順

```bash
# 1. グローバルから該当 Skill をコピー
cp ~/.claude/commands/deploy.md .claude/commands/deploy.md

# 2. プロジェクト固有の値をハードコード or 引数化
#    （例: Vercel プロジェクト名、Flutter flavor）

# 3. git add して commit（secrets を含めないこと）
```

コピー元の Skill が更新された場合、`diff ~/.claude/commands/deploy.md .claude/commands/deploy.md`
で差分を確認しながら merge する。
