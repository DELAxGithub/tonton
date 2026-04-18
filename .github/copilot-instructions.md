# GitHub Copilot / Antigravity Instructions

このリポジトリは [agent-harness](https://github.com/DELAxGithub/delax-shared-packages/tree/main/templates/agent-harness)
のガードレール下にある。どのエージェント（Claude Code, Copilot, Antigravity）も
以下のルールに従うこと。

## 必須ルール

1. **Test-First**: 非自明な実装前に `.claude/rules/test-first.md` を参照し、
   テスト観点を 3〜5 点書いてから実装に入る
2. **Conventional Commits**: `feat:` / `fix:` / `docs:` / `refactor:` / `test:` / `chore:`
3. **Secrets 禁止**: `.env`, credentials, API key を commit しない
4. **No force push**: `main` への force push はしない
5. **Co-Authored-By**: commit メッセージに自分のエージェント名を明記

## エージェント協調

複数エージェントが同じリポで作業する可能性があるため:

- 作業開始前に `git status` で未コミット変更を確認
- 別エージェントの作業痕跡があれば触らずユーザに報告
- 大きな変更はブランチを切る

## 自動化

- CI で `.github/workflows/auto-fix.yml` が走り、build 失敗時に Claude が自動修正する
- Issue / PR コメントで `.github/workflows/claude.yml` が Claude を呼ぶ
- ローカルでは `scripts/auto-fix/watch-and-fix.sh` で watch モードに入れる

## プロジェクト固有ルール

`CLAUDE.md` / `AGENTS.md` がある場合はそちらも併せて守る。
