# ADR 0001: Record architecture decisions

- **Status**: Accepted
- **Date**: 2026-04-20
- **Deciders**: project owner

## Context

このリポジトリでは、load-bearing な意思決定（後から「なぜこうしたか」を
人間 / AI エージェントが知る必要があるもの）を **Architecture Decision Record (ADR)**
として `docs/adr/` に永続化する。

Git の commit log は「何が起きたか」を記録するが、「なぜそうしたか」と
「他の選択肢はなぜ却下されたか」は失われる。ADR はその欠損を埋める。

## Decision

- すべての load-bearing な意思決定は ADR としてこのディレクトリに記録する
- ファイル名は `NNNN-<kebab-case-title>.md`（連番）
- 1 ADR 1 ファイル、上書きせず追記もしない（変更は新しい ADR で supersede）
- `/adr <title>` スラッシュコマンドで雛形生成

### ADR 化すべき意思決定の例

- アーキテクチャ選定（フレームワーク、DB、デプロイ先）
- データモデルの主要構造
- セキュリティポリシー
- 外部 API の選定理由
- 「やらないことを決めた」記録（採用しなかった選択肢）
- `Conflict Report` を経て下した判断

### ADR 化しなくて良いもの

- コードスタイル（lint で済む）
- 一時的な workaround（コメントで十分）
- 個別バグの修正方針（commit message で十分）

## Consequences

**Pros**:
- 半年後の自分・他のエージェントが文脈を復元できる
- 「なぜ X を採用しなかったか」を毎回再議論しなくて済む
- `/moderate` や `/review` が ADR を読んで判断できる

**Cons**:
- 書く手間がかかる（→ FinOps Tier 1 のみ強制、それ以外は任意）
- 古くなった ADR を放置すると逆に混乱する（→ supersede する新 ADR で明示）

## ADR テンプレート

新規 ADR は以下の構造で書く:

```markdown
# ADR NNNN: <タイトル>

- Status: Proposed | Accepted | Deprecated | Superseded by ADR-XXXX
- Date: YYYY-MM-DD
- Deciders: <名前 / "AI と協議">

## Context
<なぜこの決定が必要になったか、3-5 行>

## Decision
<決定内容、箇条書き or 短い文>

## Alternatives Considered
1. <選択肢 A> — 却下理由
2. <選択肢 B> — 却下理由

## Consequences
**Pros**: ...
**Cons**: ...

## Related
- ADR-XXXX (関連 / 上書き元)
- Conflict Report (該当があれば)
- Issue / PR #NNN
```

## Related
- [ADR pattern (Michael Nygard)](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
- `.claude/rules/conflict-report.md` — Conflict Report 解決後の永続化先
- `.claude/rules/finops-tiering.md` — Tier 1 では ADR 必須
