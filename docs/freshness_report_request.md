# ドキュメント鮮度確認と差異レポート作成のお願い

## 背景

現在、プロジェクト全体の課題を正確に把握し、今後の開発計画を効率的に進めるため、既存ドキュメントの現状との整合性を確認する必要があります。一部のドキュメントが古い情報を含んでいる可能性があり、現状を正確に反映していない恐れがあります。

## 目的

各主要ドキュメントが現在のコードベースと機能の実装状況をどの程度正確に反映しているかを評価し、乖離がある場合はその内容を明確にすることで、手戻りの防止や意思決定の精度向上を目指します。

## 依頼事項

以下の主要ドキュメントについて、最終更新状況（可能であればGitの最終コミット日時など）と、現在のコードベースおよび機能実装状況との間に見られる主要な差異点を調査し、簡潔なレポートとしてまとめてください。

## 対象ドキュメント例

- README.md
- docs/ISSUE_*.md（全ファイル）
- docs/IMAGE_ANALYSIS_*.md（全ファイル）
- docs/HIVE_*.md（全ファイル）
- docs/ai-config.md
- docs/healthkit_integration_guide.md
- docs/env_setup_guide.md
- docs/*.yaml（各画面仕様書など）
- その他、主要と思われる設計・仕様関連ドキュメント

## レポートに含めてほしい項目

- ドキュメント名（ファイルパス）
- 最終更新日（または最終コミット日など、鮮度の目安となる情報）
- ドキュメントの目的・概要
- 現状との主要な差異点・古いと思われる箇所
  - 例: "XXX機能は『未実装』と記載されているが、現在は実装済み（関連コード: lib/feature/xxx.dart）"
  - 例: "APIのエンドポイントが古いものが記載されている（現状は yyy）"
  - 例: "YYYに関する記述が現在のUIと異なる"
  - 例: "ZZZの課題は解決済み（関連Issue #123）"
- 特記事項（あれば）

## 期限

- [例: YYYY年MM月DD日] まで

## その他

- analyze_results.txt は最新の静的解析結果ではないため、必要であれば再実行し、その結果も考慮に入れてください。
- 特に重要な差異や、開発に影響を与えそうな古い情報があれば、優先的に報告いただけると助かります。

ご協力のほど、よろしくお願いいたします。
