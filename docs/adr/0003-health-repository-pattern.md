# ADR 0003: HealthService Repository Pattern Abstraction

- Status: Accepted
- Date: 2026-05-27
- Deciders: project owner（AI と協議）

## Context

tonton (Flutter, v1.7.1, released) は iOS のみ出荷されており、Android 出荷は経営判断保留中。
構造監査 (2026-05-21 [[tonton-android-readiness]]) で Android 対応の **load-bearing な単一依存** は
`health` plugin (HealthKit) であり、これ以外の iOS-specific は ほぼゼロと判定された。

現在の構造:

- `lib/services/health_service.dart` — `Health()` (HealthKit) を直接保持する concrete class
- 6 つの call site が `HealthService()` を直接 `new` している
  - `lib/main.dart:163`
  - `lib/core/providers/health_provider.dart:8`
  - `lib/core/providers/monthly_progress_provider.dart:18`
  - `lib/features/onboarding/providers/onboarding_providers.dart:16`
  - `lib/features/profile/screens/profile_screen.dart:239`
  - `lib/services/onboarding_service.dart:9` (constructor default 引数)
- `monthly_progress_provider.dart:17` に `@riverpod HealthService healthService(Ref ref)` が
  存在するが、上記 5 箇所は通っていない（移行未完了）

問題:

1. **Android 対応への障害**: `Health()` を直接持っているため `Platform.isAndroid` の分岐を
   service 内に書くか、call site すべてで条件分岐する必要があり、いずれも責任が漏れる
2. **テスト困難**: 5 つの call site が `new HealthService()` を直接呼ぶため、
   テストで HealthKit モック化ができない（実機 / シミュレータでしか動かない）
3. **個人情報（PII）依存の散在**: HealthKit データは PII であり、依存箇所が分散すると
   privacy review の射程が広がる

## Decision

`HealthService` を **abstract `HealthDataRepository`** で抽象化する。

### Phase 1 (この ADR / 本 PR)

- `lib/services/health_data_repository.dart` を新設し、5 public methods の契約を宣言
  - `requestPermissions()`
  - `getTodayActivitySummary()`
  - `getActivitySummary(DateTime)`
  - `getLatestWeight(DateTime)`
  - `getWeightHistory(start, end)`
- `HealthService` に `implements HealthDataRepository` を付与（シグネチャ変更なし）
- `lib/core/providers/health_repository_provider.dart` を新設し、
  `@riverpod HealthDataRepository healthDataRepository(Ref ref)` で abstract 型を返す
- `test/services/fake_health_data_repository.dart` を新設し、決定的値を返す fake を提供
- `test/services/health_data_repository_test.dart` で契約 + DI override を検証

**Phase 1 では既存の 5 call site と `healthServiceProvider` は触らない**（reversibility 確保、
1 PR を小さく保つ）。

### Phase 2 (別 PR)

- 6 call site を `ref.watch(healthDataRepositoryProvider)` 経由に移行
- 既存 `healthServiceProvider` を `@Deprecated` 付与 → 後続 PR で削除
- `lib/services/onboarding_service.dart` の constructor default 引数を repository 経由に変更

### Phase 3 (Android 経営判断時)

- `lib/services/google_fit_repository.dart` (Android 実装) を追加
- `healthDataRepositoryProvider` で `Platform.isAndroid` 分岐
- fastlane Android lane / CI Android build / `health_provider` の追加対応

## Consequences

### Positive

- Android 出荷時の追加実装ポイントが「`GoogleFitRepository` を書いて provider 分岐を足す」だけに収束する
- HealthKit モック化が可能になり、Health 関連ロジックの unit test 化が解禁される
  （CalorieCalculationService 等が真の意味でテスト可能になる）
- PII 依存の射程が repository 1 箇所に局所化されるため、privacy review が追いやすい

### Negative

- Phase 1 では `healthServiceProvider` と `healthDataRepositoryProvider` の二重定義が
  一時的に発生する（移行期コスト）
- 移行期に新規 call site が `healthServiceProvider` を使うと負債が増える
  → `@Deprecated` 警告と CODEOWNERS / `.claude/rules/` で誘導する

### Risks

- 5 call site の migration を放置すると Phase 2 が宙に浮く
  → todo として `[[tonton-android-readiness]]` memory に追記、次回 Android 検討時の
    最優先タスクと明示する

## Alternatives Considered

### A. 移行を 1 PR で完了させる (HealthService → HealthDataRepository に rename + 全 call site 変更)

- メリット: 二重定義の移行期コストなし
- デメリット: released phase で 5 箇所のうち 1 つでも regression が出れば直ちにユーザー影響、
  `/moderate` の負荷も増える
- 採用しなかった理由: released phase の Tier 1 変更は「reversibility 最大化」が原則。
  abstract 追加だけなら behavior 変更ゼロで安全、call site 移行は incremental に実施できる

### B. Repository pattern を使わず、HealthService 内で `Platform.isAndroid` 分岐

- メリット: 1 ファイル変更で済む
- デメリット: HealthService が iOS / Android 両プラットフォーム実装の混在ファイルになり責任が漏れる、
  unit test 困難な構造は変わらない
- 採用しなかった理由: 構造負債は減らず、Android 出荷時に再度 refactor が必要

### C. 手をつけない（Android 出荷判断時に refactor）

- メリット: 現在のユーザー（iOS のみ）への影響ゼロ
- デメリット: Android 出荷判断時に「リファクタ着手 vs ゼロから移植」を読み違える根拠を残してしまう
- 採用しなかった理由: Tier 1 構造負債を意図的に放置するのは released phase 規律と整合しない

## Related

- [[tonton-android-readiness]] — Android 対応の構造監査 (2026-05-21)
- [[feedback_explore-agent-verification]] — typography 既対応の誤検出失敗 (関連 lesson)
- `.claude/rules/finops-tiering.md` — Tier 1 判定の根拠
- `.claude/rules/test-first.md` — テスト先行ルール
- ADR-0002 (App Intents PoC) — tonton で released phase の機能拡張をする際の前例
