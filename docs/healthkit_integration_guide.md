# Flutter HealthKit PoC成果・TonTonアプリ統合ガイド

**宛先:** TonTonアプリ開発担当エンジニア

---

## 背景

- 健康管理アプリ「TonTon」開発において、iOS HealthKit連携が必須。
- React NativeでのHealthKit実装に課題があり、Flutterへの移行を決定。
- FlutterでのHealthKit連携PoC（`health_poc_app`）を実施し、成功裏に完了。

## 目的

- PoC成果（コード・知見）を理解し、TonTonアプリ本体に再利用・統合する。
- 必要な健康データ（消費カロリー、体重、体脂肪率、ワークアウト情報等）を取得するサービスレイヤーを構築する。

## PoCの主要知見

- **技術:** Flutter, `health`パッケージ（^12.2.0）
- **対象:** iOS（HealthKit）
- **取得データ:**
    - 今日のワークアウト種類・消費カロリー
    - 昨日の総消費カロリー
    - 昨日の体重・体脂肪率
- **実装ポイント:**
    - `Health()`クラス利用、`requestAuthorization()`で権限取得
    - `getHealthDataFromTypes()`でデータ取得
    - ワークアウト詳細は`HealthDataPoint.value`（`WorkoutHealthValue`型）から取得
- **制約:**
    - ワークアウト種類は`HealthWorkoutActivityType.BIKING`等に集約される場合あり
    - ローカライズ済み表示名は取得不可。`activityType.name`を整形（例: "Biking"）して英語表示
    - `Info.plist`編集・HealthKit Capability有効化必須
    - テストはiOS実機でのみ可能

## PoC成果物

- `health_poc_app`（PoCプロジェクト一式）
    - 参考用。**本体リポジトリには含めず、zip化して共有ストレージや一時GitHubリポジトリ等で管理**
    - 参照先: [PoCアーカイブの場所をここに記載]
- 雛形コード（下記参照）
- 本指示書（このファイル）

## TonTonアプリ統合手順

1. **Healthサービスレイヤーの構築**
    - `lib/services/health_service.dart` 参照
    - `health`パッケージ依存はこのクラスに集約
    - 権限リクエスト・データ取得メソッドを実装
2. **データモデルの定義**
    - `lib/models/activity_summary.dart`, `lib/models/weight_record.dart` 参照
    - アプリ独自のモデルクラスを用意
3. **PoCロジックのリファクタリング**
    - PoCのデータ取得・加工ロジックをサービスクラスに移植
4. **UIとの連携**
    - サービス経由でデータ取得、状態管理（Provider/Riverpod/Bloc等）を活用
5. **ワークアウト名の表示**
    - `activityType.name`を`formatActivityTypeName`関数で整形し英語表示
    - `lib/utils/format_activity_type_name.dart` 参照
6. **iOSプロジェクト設定**
    - `Info.plist`編集、HealthKit Capability有効化

## 雛形コードファイル一覧

- `lib/services/health_service.dart`
- `lib/models/activity_summary.dart`
- `lib/models/weight_record.dart`
- `lib/utils/format_activity_type_name.dart`

## 参考資料

- [`health`パッケージ (pub.dev)](https://pub.dev/packages/health)
- [Apple HealthKitドキュメント](https://developer.apple.com/documentation/healthkit/hkworkoutactivitytype)
- PoCプロジェクト: `health_poc_app` フォルダ
- TonTonアプリ仕様書: `SPEC.md`

---

**不明点や実装上の課題は、必ず相談してください。**

---

（このファイルはPoC成果のクロージング資料です） 