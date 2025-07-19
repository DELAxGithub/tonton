# Weight History統合 - 設計ドキュメント

## 1. 設計概要

### 1.1 設計方針
既存のHealthServiceとWeightRecordモデルを活用し、progress_achievements_screen.dartで実際の体重データを表示する。最小限の変更で最大の効果を得るため、既存のアーキテクチャを尊重した設計とする。

### 1.2 アーキテクチャ原則
- **既存コードの最大活用**: HealthServiceの体重データ取得機能を利用
- **非破壊的変更**: 既存UIレイアウトへの影響を最小限に
- **パフォーマンス重視**: 効率的なデータ取得とキャッシュ機能
- **エラーハンドリング**: HealthKit権限やデータなしの場合の適切な処理

## 2. システム設計

### 2.1 全体アーキテクチャ
```
ProgressAchievementsScreen
    ↓
WeightHistoryProvider (新規)
    ↓
HealthService (既存)
    ↓
HealthKit
```

### 2.2 コンポーネント設計

#### 2.2.1 新規コンポーネント
- **WeightHistoryProvider**: 指定期間の体重データ管理
- **WeightHistoryService**: 体重データ取得・整形ロジック

#### 2.2.2 既存コンポーネントの拡張
- **ProgressAchievementsScreen**: nullデータ生成部分を実データ取得に変更

### 2.3 データフロー
```
1. ProgressAchievementsScreen初期化
2. CalorieSavingsRecord取得（既存）
3. 対象期間の特定
4. WeightHistoryProvider.fetchWeightRecords(期間)
5. HealthService.getHealthDataFromTypes(WEIGHT)
6. WeightRecordリスト生成
7. UI更新・表示
```

## 3. データ設計

### 3.1 WeightHistoryProvider
```dart
class WeightHistoryProvider extends StateNotifier<AsyncValue<List<WeightRecord?>>> {
  final HealthService _healthService;
  
  WeightHistoryProvider(this._healthService) : super(const AsyncValue.loading());
  
  Future<void> fetchWeightRecords(
    DateTime startDate,
    DateTime endDate,
    List<CalorieSavingsRecord> calorieSavingsRecords,
  ) async {
    // 実装詳細
  }
  
  List<WeightRecord?> _alignWeightRecordsWithSavings(
    List<WeightRecord> weightData,
    List<CalorieSavingsRecord> savingsRecords,
  ) {
    // カロリー記録と体重記録の日付整合性を保つ
  }
}
```

### 3.2 WeightHistoryService
```dart
class WeightHistoryService {
  final HealthService _healthService;
  
  WeightHistoryService(this._healthService);
  
  Future<List<WeightRecord>> getWeightRecords(
    DateTime startDate,
    DateTime endDate,
  ) async {
    // HealthServiceから体重データを取得し、WeightRecordに変換
  }
  
  WeightRecord? findWeightForDate(
    List<WeightRecord> records,
    DateTime targetDate,
  ) {
    // 指定日に最も近い体重データを取得
  }
}
```

### 3.3 データ整合性戦略
- **日付マッチング**: カロリー記録の日付に対応する体重データを検索
- **近似マッチング**: 完全一致しない場合は前後3日以内の最近データを使用
- **欠損データ処理**: 体重データがない日はnullを維持（既存動作を尊重）

## 4. UI/UX設計

### 4.1 画面表示の変更
現在のnull生成部分を実データ取得に変更：

```dart
// 変更前
final weightRecords = List.generate(
  records.length,
  (index) => null as WeightRecord?,
);

// 変更後  
final weightRecords = ref.watch(weightHistoryProvider(records));
```

### 4.2 ローディング状態
```dart
weightRecords.when(
  data: (records) => _buildContent(records),
  loading: () => _buildLoadingIndicator(),
  error: (error, stack) => _buildErrorDisplay(error),
)
```

### 4.3 エラー表示
- **権限エラー**: 「HealthKitの権限を確認してください」
- **データなし**: 「体重データがありません」（既存表示を維持）
- **取得エラー**: 「データ取得に失敗しました」

## 5. 技術設計

### 5.1 Provider構成
```dart
// 新規Provider
final weightHistoryServiceProvider = Provider<WeightHistoryService>((ref) {
  final healthService = ref.watch(healthServiceProvider);
  return WeightHistoryService(healthService);
});

final weightHistoryProvider = StateNotifierProvider.family<
  WeightHistoryProvider,
  AsyncValue<List<WeightRecord?>>,
  List<CalorieSavingsRecord>
>((ref, records) {
  final service = ref.watch(weightHistoryServiceProvider);
  return WeightHistoryProvider(service)..loadWeightRecords(records);
});
```

### 5.2 キャッシュ戦略
- **メモリキャッシュ**: 同一期間の重複リクエスト防止
- **期間制限**: 過去90日分のみキャッシュ
- **自動更新**: 新しいカロリー記録追加時の部分更新

### 5.3 エラーハンドリング設計
```dart
try {
  final weightData = await _healthService.getHealthDataFromTypes(...);
  return _processWeightData(weightData);
} on HealthKitPermissionException {
  throw WeightDataException.permissionDenied();
} on HealthKitDataException {
  throw WeightDataException.dataUnavailable();
} catch (e) {
  throw WeightDataException.unknown(e);
}
```

## 6. パフォーマンス設計

### 6.1 最適化戦略
- **必要期間のみ取得**: カロリー記録の期間に限定
- **バッチ処理**: 複数日分を一度に取得
- **遅延読み込み**: 画面表示後に非同期で体重データ取得

### 6.2 リソース管理
- **メモリ使用量**: 90日分の体重データのみ保持
- **API呼び出し回数**: 期間変更時のみHealthKit再取得
- **UI更新頻度**: データ取得完了時の一度のみ更新

## 7. セキュリティ・プライバシー設計

### 7.1 データ保護
- **HealthKitデータ**: 一時的なメモリ保持のみ、永続化なし
- **権限管理**: 既存のHealthKit権限システムを活用
- **最小権限**: 体重データのみアクセス（既存権限内）

### 7.2 エラー情報
- **権限エラー時**: 個人データを含まないメッセージ
- **ログ出力**: 体重の具体的な値は記録しない

## 8. 設計検証

### 8.1 設計レビューポイント
- [ ] 既存のCalorieSavingsRecordとの整合性
- [ ] HealthServiceの使用方法が適切か
- [ ] nullデータの代替が正しく動作するか
- [ ] エラーハンドリングが十分か

### 8.2 要件との整合性
- ✅ 実際の体重データ表示: WeightHistoryProviderで実現
- ✅ パフォーマンス要件: キャッシュとバッチ処理で対応
- ✅ エラーハンドリング: 包括的な例外処理を設計
- ✅ 既存システム保護: 最小限の変更で影響を局所化