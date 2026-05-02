# CLAUDE.md - Project Memory

## Phase: released

> 規律強度・released の規律は agent-harness の `project-phase.md` 参照。
> v1.7.0+11 App Store 審査提出済。v1.8 系で App Intents PoC 検討中（ADR-0002）。

## WHAT
This is the `tonton` repository, a mobile application built with **Flutter**.
It focuses on video/media handling (implied by `assets` and `handover-player` context in user history, though tonton might be different, strict usage of Flutter structure is observed).

## WHY
Design Philosophy: **Simple & Testable**.
We prioritize clean architecture, maintainability, and automated verification to ensure long-term stability.

## HOW
Refer to the detailed rules and guides in `.claude/rules/`:
- **General Rules**: [.claude/rules/basic-rules.md](file://.claude/rules/basic-rules.md)
- **Skills**: [.claude/skills/](file://.claude/skills/)
