# トントン Ver.2.0 - 実装計画

## 1. 実装戦略

### 1.1 実装方針
- **既存コードの活用**: 現在の実装を最大限活用
- **段階的リファクタリング**: 複雑機能を段階的にシンプル化
- **100日完走重視**: ユーザー継続性を最優先
- **技術的負債解消**: 既存の問題を並行して解決

### 1.2 実装優先順位
1. **P0**: 既存バグ修正・技術的負債解消
2. **P1**: 貯金システム強化・UI改善
3. **P2**: 体重連動システム構築
4. **P3**: 100日完走支援機能

## 2. Phase別実装計画

### Phase 1: 基盤整備・既存問題解決 (2025年7月-8月)

#### 2.1.1 緊急対応事項の完了
**対象**: 現在のTODO.mdのP0項目

```
├── Weight History統合 (progress_achievements_screen.dart:51)
├── プロフィール画面UI完成 (profile_screen.dart)
│   ├── 年齢層選択UI実装
│   ├── 性別選択UI実装
│   └── ログアウトボタン実装
├── 食事編集機能 (daily_meals_detail_screen.dart)
└── Import修正 (basic_info_screen.dart)
```

**実装手順**:
1. Weight History空データ問題解決
2. プロフィール画面の未実装UI完成
3. 食事編集機能の基本実装
4. deprecated画面の削除

#### 2.1.2 データ構造のシンプル化
**目標**: 複雑なPFC管理の自動化

```dart
// 現在の複雑なデータ構造
class DetailedNutritionData {
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  // ... 多数の栄養素
}

// シンプル化後の構造
class SimpleNutritionData {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final NutritionBalance balance; // 自動計算
}
```

**実装タスク**:
- [ ] 栄養素計算ロジックの自動化
- [ ] ユーザー入力項目の削減
- [ ] デフォルト値の最適化

### Phase 2: 貯金システム強化 (2025年8月-9月)

#### 2.2.1 CalorieBankAccountモデルの実装

```dart
// 新規実装
class CalorieBankAccount {
  final String userId;
  final DateTime startDate;
  final int targetDays;
  final double targetWeightLoss;
  final double currentBalance;
  final double totalDeposits;
  final double totalWithdrawals;
  
  // 計算メソッド
  double get weeklyTargetBalance => _calculateWeeklyTarget();
  int get daysRemaining => targetDays - daysSinceStart;
  double get progressPercentage => daysSinceStart / targetDays;
}
```

**実装手順**:
1. 新データモデルの作成
2. Supabaseテーブル設計・作成
3. 既存のCalorieSavingsRecordからのマイグレーション
4. Provider層での状態管理実装

#### 2.2.2 豚の貯金箱UI改善

**現在のUI構造解析**:
```
lib/features/home/screens/home_screen.dart
├── CalorieSavingsCard (既存)
├── TodaysCalorieIntakeCard (既存)
└── TodaysActivitiesCard (既存)
```

**新しいUI構造**:
```
lib/widgets/calorie_bank/
├── pig_savings_bank_widget.dart (新規)
├── daily_transaction_widget.dart (リファクタ)
├── weekly_progress_widget.dart (新規)
└── calorie_bank_animations.dart (新規)
```

**実装タスク**:
- [ ] 豚の貯金箱SVGアニメーション作成
- [ ] 貯金状態に応じた表情変化実装
- [ ] タップインタラクション追加
- [ ] 満タン時のエフェクト実装

#### 2.2.3 週間目標システム実装

```dart
class WeeklyGoalManager {
  static const int TOTAL_WEEKS = 14; // 100日 ÷ 7日
  
  static double calculateWeeklyTarget(
    int weekNumber,
    double totalTargetCalories,
    double userProgress,
  ) {
    // 適応的目標設定ロジック
    final baseTarget = totalTargetCalories / TOTAL_WEEKS;
    final adjustmentFactor = _getAdjustmentFactor(weekNumber, userProgress);
    return baseTarget * adjustmentFactor;
  }
}
```

**実装手順**:
1. 週間目標計算エンジン実装
2. 週間進捗トラッキング機能
3. 目標達成判定ロジック
4. 週間サマリー画面作成

### Phase 3: 体重連動システム構築 (2025年9月-10月)

#### 2.3.1 体重予測エンジン実装

```dart
class WeightPredictionEngine {
  static WeightPrediction predict(
    double currentWeight,
    double calorieBalance,
    int daysSinceStart,
  ) {
    // 科学的根拠に基づく予測計算
    final expectedLoss = calorieBalance / 7700; // 1kg = 7700kcal
    final metabolicAdjustment = _calculateMetabolicFactor(daysSinceStart);
    final predictedWeight = currentWeight - (expectedLoss * metabolicAdjustment);
    
    return WeightPrediction(
      weight: predictedWeight,
      confidence: _calculateConfidence(daysSinceStart),
      accuracy: _getHistoricalAccuracy(),
    );
  }
}
```

**実装タスク**:
- [ ] HealthKit体重データ取得改善
- [ ] 予測アルゴリズム実装
- [ ] 予測精度の計測・改善機能
- [ ] 体重トレンドチャート作成

#### 2.3.2 貯金と体重の連動表示

**UI設計**:
```
┌─────────────────────────────┐
│  🐷 2,350 kcal 貯金中       │
│  ████████░░ 78% (第12週)    │
│                             │
│  📊 体重変化予測            │
│  開始: 67.2kg → 現在: 65.8kg │
│  予測: 63.5kg (-3.7kg)      │
│  ┌─────────────────────┐    │
│  │ ●●●○○○○ 週間進捗    │    │
│  └─────────────────────┘    │
└─────────────────────────────┘
```

**実装手順**:
1. 体重変化グラフWidget作成
2. 貯金残高との相関表示
3. 予測精度インジケーター
4. 体重目標との比較表示

### Phase 4: 100日完走支援機能 (2025年10月-11月)

#### 2.4.1 ゲーミフィケーション要素

```dart
class AchievementSystem {
  static const achievements = [
    Achievement(id: 'first_week', name: '初週達成', description: '1週間継続'),
    Achievement(id: 'month_warrior', name: '1ヶ月戦士', description: '30日継続'),
    Achievement(id: 'halfway_hero', name: '折り返し地点', description: '50日達成'),
    Achievement(id: 'final_stretch', name: 'ラストスパート', description: '75日達成'),
    Achievement(id: 'century_champion', name: '100日チャンピオン', description: '100日完走'),
  ];
}
```

**実装タスク**:
- [ ] マイルストーン達成アニメーション
- [ ] バッジシステム実装
- [ ] 達成時の特別演出
- [ ] 進捗共有機能（シンプル版）

#### 2.4.2 卒業機能実装

```dart
class GraduationManager {
  static Future<GraduationReport> generateReport(String userId) async {
    final account = await CalorieBankService.getAccount(userId);
    final transactions = await CalorieBankService.getAllTransactions(userId);
    
    return GraduationReport(
      totalDays: account.daysSinceStart,
      totalCaloriesSaved: account.currentBalance,
      weightLoss: _calculateActualWeightLoss(transactions),
      achievements: _getEarnedAchievements(account),
      exportData: _prepareExportData(transactions),
    );
  }
}
```

**実装手順**:
1. 100日達成検知機能
2. 卒業レポート生成
3. データエクスポート機能
4. 継続利用オプション提供

### Phase 5: 最終調整・最適化 (2025年11月-12月)

#### 2.5.1 パフォーマンス最適化

**対象領域**:
- 画像処理速度向上
- API呼び出し最適化
- データベースクエリ改善
- UI描画パフォーマンス

**実装タスク**:
- [ ] 画像圧縮アルゴリズム改善
- [ ] キャッシュ戦略最適化
- [ ] 不要な再描画削除
- [ ] メモリリーク対策

#### 2.5.2 アクセシビリティ対応

```dart
class AccessibilityUtils {
  static void configureBankWidget(Widget widget) {
    widget.semanticsLabel = 'カロリー貯金箱、現在の残高は${balance}キロカロリーです';
    widget.semanticsHint = 'タップして詳細を確認できます';
  }
}
```

**実装手順**:
1. スクリーンリーダー対応
2. 高コントラストモード対応
3. フォントサイズ調整対応
4. 色覚障害者向け配色調整

## 3. 技術実装詳細

### 3.1 データマイグレーション計画

#### 3.1.1 既存データの移行戦略

```dart
class DataMigrationService {
  static Future<void> migrateToV2() async {
    // Phase 1: 既存CalorieSavingsRecord → CalorieBankAccount
    await _migrateCalorieSavings();
    
    // Phase 2: DailyCalorieSummary → DailyCalorieTransaction
    await _migrateDailySummaries();
    
    // Phase 3: 週間目標データの初期生成
    await _generateWeeklyGoals();
  }
  
  static Future<void> _migrateCalorieSavings() async {
    final records = await supabase
        .from('calorie_savings_records')
        .select();
    
    for (final record in records) {
      await supabase.from('calorie_bank_accounts').insert({
        'user_id': record['user_id'],
        'start_date': record['start_date'],
        'current_balance': record['cumulative_savings'],
        // ... その他のマッピング
      });
    }
  }
}
```

#### 3.1.2 後方互換性の確保

```dart
class CompatibilityLayer {
  // 既存のAPIを維持しつつ、内部的にV2システムを使用
  static Future<CalorieSavingsRecord> getCalorieSavings(String userId) async {
    final account = await CalorieBankService.getAccount(userId);
    return CalorieSavingsRecord.fromBankAccount(account);
  }
}
```

### 3.2 テスト戦略

#### 3.2.1 Unit Tests
```dart
// 貯金計算ロジックのテスト
test('週間目標計算が正しく動作する', () {
  final target = WeeklyGoalManager.calculateWeeklyTarget(
    weekNumber: 5,
    totalTargetCalories: 35000,
    userProgress: 0.8,
  );
  expect(target, closeTo(2500, 100));
});

// 体重予測エンジンのテスト
test('体重予測が合理的な範囲内である', () {
  final prediction = WeightPredictionEngine.predict(
    currentWeight: 70.0,
    calorieBalance: 7700,
    daysSinceStart: 30,
  );
  expect(prediction.weight, lessThan(70.0));
  expect(prediction.weight, greaterThan(68.0));
});
```

#### 3.2.2 Integration Tests
```dart
testWidgets('貯金箱UIが正しく状態を表示する', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
  
  // 貯金箱が表示されることを確認
  expect(find.byType(PigSavingsBankWidget), findsOneWidget);
  
  // 残高が正しく表示されることを確認
  expect(find.text('2,350 kcal'), findsOneWidget);
  
  // タップ時のアニメーションを確認
  await tester.tap(find.byType(PigSavingsBankWidget));
  await tester.pumpAndSettle();
  // アニメーション確認ロジック
});
```

### 3.3 デプロイメント計画

#### 3.3.1 段階的リリース戦略

**Beta版 (v1.1-beta)**:
- 内部テスト用
- 基本的な貯金システム実装
- 既存機能の後方互換性確認

**Preview版 (v1.5-preview)**:
- 限定ユーザー向けテスト
- 体重連動機能の実証実験
- フィードバック収集

**正式版 (v2.0)**:
- 全ユーザー向けリリース
- 100日完走支援機能完備
- パフォーマンス最適化完了

#### 3.3.2 ロールバック計画

```dart
class VersionManager {
  static const supportedVersions = ['v1.0', 'v1.1', 'v2.0'];
  
  static Future<void> rollbackToV1() async {
    // V2機能を無効化
    await FeatureFlags.disable('calorie_bank_v2');
    await FeatureFlags.disable('weight_prediction');
    
    // V1互換モードに切り替え
    await DatabaseManager.switchToV1Schema();
  }
}
```

## 4. リスク対策

### 4.1 技術的リスク対策

**リスク**: データマイグレーション失敗
**対策**: 
- 段階的マイグレーション実装
- ロールバック機能完備
- バックアップ自動作成

**リスク**: パフォーマンス劣化
**対策**:
- パフォーマンス監視ツール導入
- 負荷テスト実施
- 段階的機能リリース

### 4.2 ユーザビリティリスク対策

**リスク**: 既存ユーザーの混乱
**対策**:
- 段階的UI変更
- チュートリアル機能強化
- サポートドキュメント充実

**リスク**: 100日継続の困難
**対策**:
- 適応的目標設定
- モチベーション維持機能
- 中間マイルストーン設定

## 5. 成功指標・検証方法

### 5.1 技術指標
- [ ] アプリ起動時間: 3秒以下
- [ ] AI認識精度: 85%以上
- [ ] クラッシュ率: 0.1%以下
- [ ] データマイグレーション成功率: 100%

### 5.2 ユーザー体験指標
- [ ] 100日完走率: 50%以上
- [ ] 週間目標達成率: 60%以上
- [ ] アプリ評価: 4.5★以上維持
- [ ] 体重予測精度: ±0.5kg以内

### 5.3 検証手法
- A/Bテストによる機能比較
- ユーザーインタビューの実施
- アプリ内分析データの活用
- 定期的なパフォーマンス測定

この実装計画に従って、シンプルで効果的な「カロリー貯金」アプリを段階的に構築します。