---
name: agent-callable
description: 自作ツールが別 AI エージェントから自律操作可能であることを保証する規約
---

# Agent-Callable ルール（Agent Harness）

このリポジトリが **CLI ツール** または **Web サービス** を提供する場合、
別の AI エージェント（Claude Code の subagent、GitHub Actions 上の cron 起動 Claude 等）が
ドキュメントを読むだけで自律操作できる状態を維持する。

人間が手で叩くことよりも、**AI が叩く**ことを第一想定とする設計（CLI First / API First）。

## 1. CLI ツールの要件

CLI を提供する場合、以下を**必ず**満たす:

- `--help` / `-h` で以下を出力する:
  - 1 行のツール概要
  - サブコマンド一覧（ある場合）
  - 主要オプションと型（`--flag=<value>` 形式で明示）
  - 代表的な使用例を 1〜3 個
- サブコマンドがある場合、`<subcommand> --help` も同様に動作する
- 終了コードは成功 `0` / 失敗 `非0` を厳守（AI が成否を判定できるように）
- 標準出力は機械可読を優先（JSON / JSONL を選べるなら `--json` フラグを用意）
- 破壊的操作には `--dry-run` を用意する

**悪い例**: `tool.py` を叩くと対話プロンプトが出る、`--help` が未実装
**良い例**: `tool --json --dry-run search "query"` で JSON 結果が返る

## 2. Web サービスの要件

HTTP サーバを提供する場合、以下を**必ず**満たす:

- `GET /api/openapi.json`（または `/openapi.json`）で OpenAPI 3.x 仕様を返す
- すべての公開エンドポイントに `summary` と `description` を記載
- 認証方式（API key / OAuth）を OpenAPI の `securitySchemes` で明示
- エラーレスポンスも OpenAPI に含める（AI が失敗時の挙動を予測できるように）

FastAPI / Hono / NestJS など OpenAPI 自動生成できるフレームワークを優先する。
手書きの場合でも、コードとドキュメントが乖離しないよう CI で差分検知する。

## 3. README 先頭の Agent Usage セクション

`README.md` の先頭（インストール手順の直後）に、
**AI エージェント向けの呼び出し方**を記載する:

```markdown
## Agent Usage

- CLI help: `<tool> --help`
- OpenAPI: `curl http://localhost:PORT/api/openapi.json`
- 代表コマンド: `<tool> --json <subcommand> <args>`
```

これにより `/find` や subagent がリポジトリを発見した直後に使い方を把握できる。

## 4. 検証

変更コミット前に以下を確認:

```bash
# CLI ツールの場合
<tool> --help >/dev/null && echo OK

# Web サービスの場合（ローカル起動後）
curl -sf http://localhost:PORT/api/openapi.json | jq .openapi
```

`scripts/auto-fix/agent-callable-check.sh`（agent-harness 同梱）で
リポジトリ全体の遵守状況を監査できる。

## なぜこれを守るのか

- AI エージェントは `--help` / OpenAPI を**唯一の契約**として読む
- ドキュメントが GUI スクリーンショットや README 本文だけだと、
  subagent はツールを呼び出せない（人間依存に戻る）
- 「人間が GUI を操作する」のではなく「AI が CLI / API で操作する」
  インターフェース転換が、自動化の射程を一気に広げる

## 例外

- 純粋なライブラリ（CLI/HTTP を提供しない npm パッケージ等）は対象外
- 実験用の一時スクリプト（`_scratch/`, `experiments/` 配下）は対象外
- プロトタイプ段階で明示的にスキップする場合は、README にその旨 1 行記載
