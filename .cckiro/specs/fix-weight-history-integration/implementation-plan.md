# Weight History統合 - 実装計画

## 1. 実装戦略

### 1.1 実装方針
既存のHealthServiceとWeightRecordモデルを最大限活用し、段階的に実装する。最初にコア機能を実装し、その後エラーハンドリングと最適化を追加する。

### 1.2 実装優先順位
1. **WeightHistoryService実装**: データ取得・変換ロジック
2. **WeightHistoryProvider実装**: 状態管理とキャッシュ
3. **画面統合**: progress_achievements_screen.dartの修正
4. **エラーハンドリング**: 権限・データなし等の処理
5. **動作確認**: 実際のHealthKitデータでのテスト

## 2. Phase別実装計画

### Phase 1: コアサービス実装 (30分)

#### 2.1.1 実装範囲
WeightHistoryServiceの基本的な体重データ取得機能

#### 2.1.2 実装タスク
```
├── WeightHistoryService クラス作成
│   ├── getWeightRecords メソッド実装
│   ├── findWeightForDate メソッド実装
│   └── _convertHealthDataToWeightRecord 変換ロジック
└──基本的なエラーハンドリング
```

#### 2.1.3 実装手順
1. `lib/features/health/services/weight_history_service.dart` 作成
2. HealthServiceからの体重データ取得実装
3. HealthDataPointからWeightRecordへの変換実装
4. 日付マッチングロジック実装

#### 2.1.4 成果物
- [ ] WeightHistoryService クラス完成
- [ ] 体重データ取得機能動作確認

### Phase 2: Provider実装 (45分)

#### 2.2.1 実装範囲
WeightHistoryProviderの状態管理とキャッシュ機能

#### 2.2.2 実装タスク
```
├── WeightHistoryProvider クラス作成
│   ├── fetchWeightRecords メソッド実装
│   ├── _alignWeightRecordsWithSavings ロジック実装
│   └── キャッシュ機能実装
├── Provider登録
│   ├── weightHistoryServiceProvider
│   └── weightHistoryProvider (family)
└── 依存関係設定
```

#### 2.2.3 実装手順
1. `lib/features/health/providers/weight_history_provider.dart` 作成
2. StateNotifierを使った状態管理実装
3. CalorieSavingsRecordとの日付整合ロジック実装
4. providers.dartへの登録

#### 2.2.4 成果物
- [ ] WeightHistoryProvider完成
- [ ] Provider登録・依存関係設定完了

### Phase 3: 画面統合 (30分)

#### 2.3.1 実装範囲
progress_achievements_screen.dartでの実データ表示

#### 2.3.2 実装タスク
```
├── progress_achievements_screen.dart修正
│   ├── null生成コード削除
│   ├── weightHistoryProvider使用
│   └── AsyncValue対応（loading/error状態）
└── UI調整
    ├── ローディング表示
    └── エラー表示
```

#### 2.3.3 実装手順
1. 既存のnull生成コード特定・削除
2. ref.watch(weightHistoryProvider(records))に変更
3. AsyncValue.whenによる状態別表示実装
4. ローディング・エラー時のUI調整

#### 2.3.4 成果物
- [ ] progress_achievements_screen.dart修正完了
- [ ] 実際の体重データ表示確認

### Phase 4: エラーハンドリング強化 (45分)

#### 2.4.1 実装範囲
包括的なエラーハンドリングとユーザーフレンドリーな表示

#### 2.4.2 実装タスク
```
├── WeightDataException クラス作成
│   ├── permissionDenied
│   ├── dataUnavailable
│   └── unknown
├── エラーハンドリング実装
│   ├── HealthKit権限エラー
│   ├── データ取得失敗
│   └── ネットワークエラー
└── UI表示改善
    ├── エラー専用Widget
    └── 再試行機能
```

#### 2.4.3 実装手順
1. `lib/features/health/exceptions/weight_data_exception.dart` 作成
2. WeightHistoryServiceでの例外処理強化
3. WeightHistoryProviderでのエラー状態管理
4. progress_achievements_screenでのエラー表示実装

#### 2.4.4 成果物
- [ ] 包括的なエラーハンドリング完成
- [ ] ユーザーフレンドリーなエラー表示

### Phase 5: 動作確認・最適化 (30分)

#### 2.5.1 実装範囲
実際のHealthKitデータでの動作確認と最適化

#### 2.5.2 実装タスク
```
├── 動作確認
│   ├── 実データでの表示確認
│   ├── エラーケーステスト
│   └── パフォーマンス確認
├── 最適化
│   ├── キャッシュ効率化
│   ├── API呼び出し最適化
│   └── メモリ使用量確認
└── ドキュメント更新
```

#### 2.5.3 実装手順
1. 実際のHealthKitデータでの表示テスト
2. 権限なし・データなしケースの確認
3. パフォーマンス測定と最適化
4. コメント・ドキュメント整備

#### 2.5.4 成果物
- [ ] 全機能動作確認完了
- [ ] パフォーマンス最適化完了

## 3. 技術実装詳細

### 3.1 ファイル構成
```
lib/
├── features/health/
│   ├── services/
│   │   └── weight_history_service.dart (新規)
│   ├── providers/
│   │   └── weight_history_provider.dart (新規)
│   └── exceptions/
│       └── weight_data_exception.dart (新規)
├── features/progress/screens/
│   └── progress_achievements_screen.dart (修正)
└── providers/
    └── providers.dart (修正)
```

### 3.2 実装順序
1. **WeightHistoryService**: データ取得・変換の基盤実装
2. **WeightHistoryProvider**: 状態管理とキャッシュ機能
3. **progress_achievements_screen修正**: UI統合とユーザー体験
4. **エラーハンドリング**: 堅牢性とユーザビリティ向上
5. **最適化・テスト**: パフォーマンスと品質確保

### 3.3 重要な実装ポイント

#### 3.3.1 日付整合ロジック
```dart
WeightRecord? findWeightForDate(List<WeightRecord> records, DateTime targetDate) {
  // 1. 完全一致検索
  // 2. 前後3日以内の最近データ検索
  // 3. 見つからない場合はnull
}
```

#### 3.3.2 非同期処理
```dart
Future<void> fetchWeightRecords(List<CalorieSavingsRecord> records) async {
  state = const AsyncValue.loading();
  try {
    final result = await _service.getWeightRecords(startDate, endDate);
    state = AsyncValue.data(_alignRecords(result, records));
  } catch (e) {
    state = AsyncValue.error(e, StackTrace.current);
  }
}
```

## 4. リスク対策

### 4.1 技術的リスク
- **HealthKit権限問題**: 適切な権限チェックと再リクエスト機能
- **データ形式変更**: HealthKitデータ形式の堅牢な解析
- **パフォーマンス劣化**: 効率的なキャッシュとバッチ処理

### 4.2 実装リスク
- **既存機能破壊**: 段階的な実装と十分なテスト
- **UI表示崩れ**: 既存レイアウトの慎重な保持
- **メモリリーク**: 適切なリソース管理とDispose

## 5. 成功指標・検証方法

### 5.1 完了基準
- [ ] progress_achievements_screenで実際の体重データが表示される
- [ ] HealthKit権限エラー時の適切な表示
- [ ] データなし時の graceful handling
- [ ] 既存機能への影響なし

### 5.2 品質基準
- [ ] パフォーマンス劣化なし（3秒以内のデータ表示）
- [ ] メモリ使用量増加が10%以下
- [ ] エラー発生時のアプリクラッシュなし

### 5.3 検証手法
- **手動テスト**: 実際のHealthKitデータでの動作確認
- **エラーテスト**: 権限なし・データなしケースの確認
- **パフォーマンステスト**: メモリ使用量とレスポンス時間測定

## 6. 想定工数・スケジュール

### 6.1 総工数: 3時間
- Phase 1: 30分
- Phase 2: 45分  
- Phase 3: 30分
- Phase 4: 45分
- Phase 5: 30分

### 6.2 クリティカルパス
WeightHistoryService → WeightHistoryProvider → 画面統合

このため、Phase 1-3は順次実行し、Phase 4-5は並行して進めることが可能。