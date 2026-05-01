# ADR 0002: App Intents PoC for Quick Meal Log

- Status: Proposed
- Date: 2026-05-01
- Deciders: project owner（AI と協議）

## Context

OpenAI Codex の公式ユースケースガイド（Native Development / Game Development の2記事）で
**App Intents** が iOS native 開発の代表的なエージェント連携ポイントとして
2 回連続で取り上げられた。弊社の iOS プロジェクト
(shadow_master / tonton / delax100daysworkout / Handover Player / DaVinci AI Commander)
で App Intents は **どのアプリでも未着手**、横断的な弱点になっている。

弊社の他 ADR / メモリと連動する流れ:

- kerokero ADR-0002: 「外から殴ってくる仕組み」を活性化エネルギー対策として導入予定
  → iPhone 録音 inbox + 通知 + cron
- shadow_master Ride Mode v1: 既に main マージ済、独自機能の追加は凍結中
  → App Intents は Ride Mode の機能追加ではないが、freeze 中のリポは触らない方針
- tonton: v1.7.0+11 が App Store 審査提出済（2026-02-28）、
  以降も開発継続中（最新 commit: weight + ideal-pace trajectory 追加）
  → 次バージョン（v1.8 系）の機能候補として App Intents を試す土壌がある

App Intents の PoC として **どのアプリで何を実装するか** を決める。

## Decision

**tonton で「Quick Meal Log」1 個だけ** を最小 PoC として実装する。

### スコープ

**1 つの Intent: `LogQuickMealIntent`**

- **トリガー**: Siri (「Hey Siri, tonton で唐揚げ定食をランチに」) / Shortcuts / Spotlight Action
- **入力**: 食事内容（自由テキスト、IntentParameter）+ 食事区分（朝/昼/夜/間食、optional）
- **処理**:
  1. App Intent が文字列を受け取り、既存の Gemini 推定パイプ
     (`b7958d2` で gemini-2.5-flash に切替済) を呼ぶ
  2. カロリー / 主要栄養素を推定
  3. 既存の meal 記録ストアに保存
  4. 当日の貯金残高を再計算
- **応答**: `IntentResult` で「ランチに唐揚げ定食を記録しました（約780 kcal、本日の貯金残高 +120 kcal）」を返す（Siri 読み上げ可能）
- **フォアグラウンド要否**: 確認ダイアログなしで完了（quick log の本旨が崩れる）

### 含めないもの（次の ADR で別検討）

- **Spotlight Today Balance**: 残高表示専用 Intent（読み取り系、別 PoC）
- **写真からのログ**: App Intents の `IntentFile` 連携、PoC 1 周目では除外
- **Apple Watch / Lock Screen Widget**: WidgetKit 統合、PoC 範囲外
- **Shortcuts Trigger（運動後/体重測定後の自動ログ起動）**: ユーザー側 Shortcut で自由に組ませる

### 採用判定の出口

PoC 後 1〜2 週の実走で以下を確認したら正式採用:

- [ ] Siri 経由で 5 回以上ログした実績
- [ ] 推定エラー率（Gemini が誤った量/食材を返す確率）が手動入力許容範囲内
- [ ] 既存 UI からのログとの **重複入力** がないこと（DB の dedupe を確認）

未達なら ADR を `Deprecated` に落として理由を残す。

## Alternatives Considered

1. **shadow_master で「Today's Speaking Prompt」Intent を作る** — 却下（今回は）。
   shadow_master Ride Mode v1 が freeze 中で、独自機能の追加は実走の不満を起点に
   再設計する方針。App Intents は freeze 対象の「機能」ではなく
   「システム統合」だが、未コミット resources が多い現状で触るのはリスクが高い。
   → freeze 解除後に別 ADR で検討。kerokero ADR-0002 の inbox 設計と接続する形が筋。

2. **delax100daysworkout で「Today's Workout」Intent を作る** — 却下。
   intervals.icu 連携の本筋が自転車到着待ちで止まっており、
   App Intents を先に入れると「機能だけあって本体が止まっている」状態になる。

3. **複数 Intent をまとめて実装** — 却下。
   Quick Log（書き込み）と Show Balance（読み取り）は異なる UX 判定が必要。
   PoC は **1 vertical を全層通す** 方が学びが深い。

4. **App Intents を見送り、Widget + Shortcuts URL Scheme で代替** — 却下。
   Codex 公式 use case が App Intents を推奨しており、Apple の中長期方向と一致。
   URL Scheme は legacy、Siri 連携が弱い。

## Consequences

**Pros**:

- iOS native 開発の弱点（複数記事で指摘）を 1 つの vertical PoC で検証できる
- tonton の入力摩擦を下げる（カロリー記録は **思いついたとき = 食後数秒** が勝負）
- 既存の Gemini 推定パイプを再利用、新規 API 統合なし
- PoC が成功すれば shadow_master / kerokero (ADR-0002 の inbox トリガー) への横展開テンプレになる
- v1.8 系の差別化機能として App Store 説明文に書ける

**Cons**:

- Flutter での App Intents 実装は **iOS native module（Swift）追加が必要**
  → `flutter_app_intents` パッケージ等の調査が前提（Conflict Report 候補）
- iOS 16+ 限定（既存最低サポート iOS と要整合確認）
- Siri が誤認識した食事名 → Gemini 推定誤差 → 記録誤り、の **誤差が複層化** する
  → confidence が低い場合は確認ダイアログを出す逃げ道を仕込む
- Siri 経由は **App 起動なし** で完了するため、ユーザーが「ログした実感」を得にくい
  → 通知 or Live Activity で残高更新を見せる工夫が必要

## Open Questions（実装前に解くべき）

1. **Flutter での App Intents 実装方針**
   - `flutter_app_intents` 等の OSS パッケージで賄えるか
   - それとも Swift native module + MethodChannel を自作するか
   - → 1 日のスパイクで判定

2. **iOS 最低サポートバージョン**
   - 現在の `ios/Podfile` / `Info.plist` の deployment target
   - App Intents は iOS 16.0+、tonton 既存ユーザー影響範囲

3. **Gemini 推定エラー時の挙動**
   - 信頼度低 → Siri 上で「確認のため app を開きますか?」と聞くか、暫定保存して後で通知するか
   - Conflict Report 候補（プライバシー vs UX）

4. **Tier 判定**
   - 食事ログは「個人の健康データ」だが、tonton は local-first、Gemini に渡るのは食事テキストのみ
   - finops-tiering.md 上は Tier 1（個人情報の取り扱い）か Tier 2（新機能の主要ロジック）か
   - → 実装着手前にユーザー判断を仰ぐ

## Related

- ADR-0001 — Record architecture decisions
- ADR `kerokero/docs/adr/0002-external-triggers-and-async-evaluation.md`
  — 外部トリガー横串の片割れ。App Intents 化が成功すれば kerokero inbox にも適用
- メモリ `tonton.md` — v1.7.0+11 審査提出済の現状
- メモリ `shadow-master-ride-mode-wip.md` — freeze 方針の参照
- Codex 公式 use cases:
  - <https://developers.openai.com/codex/use-cases/collections/native-development>
  - <https://developers.openai.com/codex/use-cases/ios-app-intents>
- `.claude/rules/finops-tiering.md` — Tier 判定（Open Questions 4 参照）
- `.claude/rules/conflict-report.md` — Open Questions 1, 3 が該当しうる
