# トントン Ver.2.0 - 設計ドキュメント（シンプル版）

## 1. システム設計概要

### 1.1 設計方針
「カロリー貯金」を中心とした100日完走型ダイエットアプリとして設計。複雑な機能を排除し、直感的な貯金体験に集約する。

### 1.2 アーキテクチャ原則
- **シンプルファースト**: 機能は最小限に絞り込み
- **100日完結**: 長期利用ではなく短期集中型
- **貯金メタファー**: 全ての機能を貯金概念で統一
- **体重連動**: 貯金実績と体重変化の明確な関連付け

## 2. データ設計

### 2.1 コアデータモデル

#### CalorieBankAccount（カロリー貯金口座）
```dart
class CalorieBankAccount {
  final String userId;
  final DateTime startDate;        // 開始日
  final int targetDays;           // 目標日数（デフォルト100日）
  final double targetWeightLoss;  // 目標減量（kg）
  final double currentBalance;    // 現在の貯金残高（kcal）
  final double totalDeposits;     // 累積入金額（kcal）
  final double totalWithdrawals;  // 累積出金額（kcal）
  final DateTime lastUpdated;
}
```

#### DailyCalorieTransaction（日次カロリー取引）
```dart
class DailyCalorieTransaction {
  final String id;
  final String userId;
  final DateTime date;
  final double caloriesEarned;    // 活動で獲得したカロリー
  final double caloriesSpent;     // 食事で消費したカロリー
  final double dailyBalance;      // 日次収支
  final double weightRecord;      // その日の体重記録
  final TransactionStatus status; // 取引状態
}
```

#### WeeklyGoal（週間目標）
```dart
class WeeklyGoal {
  final String id;
  final String userId;
  final int weekNumber;           // 開始からの週数（1-15週）
  final double targetBalance;     // 週間目標貯金額
  final double actualBalance;     // 実際の達成額
  final bool isAchieved;         // 達成フラグ
  final DateTime weekStartDate;
  final DateTime weekEndDate;
}
```

### 2.2 データフロー設計

```
HealthKit活動データ ──→ カロリー獲得計算
                           ↓
食事記録（AI認識） ──→ カロリー消費計算
                           ↓
                    日次収支計算
                           ↓
                    貯金口座残高更新
                           ↓
                    体重予測計算
```

## 3. UI/UX設計

### 3.1 画面構成（シンプル化）

#### 3.1.1 メイン画面（貯金口座画面）
```
┌─────────────────────────────┐
│     🐷 カロリー貯金箱        │
│                             │
│    現在の貯金: 2,350 kcal    │
│   ████████░░ 78%            │
│                             │
│  今日の収支                  │
│  ┌─────┬─────┬─────┐      │
│  │獲得  │消費  │収支  │      │
│  │580  │420  │+160 │      │
│  └─────┴─────┴─────┘      │
│                             │
│  📸 食事を記録              │
│  📊 進捗を見る              │
└─────────────────────────────┘
```

#### 3.1.2 週間進捗画面
```
┌─────────────────────────────┐
│      週間貯金目標           │
│                             │
│  第12週 (残り2週間)          │
│  目標: 1,400 kcal           │
│  実績: 1,150 kcal           │
│  ████████░░ 82%            │
│                             │
│  📈 体重変化予測            │
│  現在: 65.2kg               │
│  予測: 63.8kg (-1.4kg)      │
│                             │
│  📅 週間カレンダー          │
│  月火水木金土日              │
│  ✅✅✅✅❌⭕⭕           │
└─────────────────────────────┘
```

### 3.2 貯金箱UI詳細設計

#### 3.2.1 貯金箱の状態表現
- **空（0-25%）**: 透明な貯金箱、豚がお腹を空かせた表情
- **貯まってきた（25-50%）**: 薄い金色、豚が普通の表情
- **結構貯まった（50-75%）**: 濃い金色、豚が嬉しそうな表情
- **満タン（75-100%）**: キラキラエフェクト、豚が満足そうな表情

#### 3.2.2 インタラクション
- **タップ**: 貯金箱がゆらゆら揺れる、中身の音がする
- **目標達成時**: 貯金箱が光って、コイン落下アニメーション
- **週間達成時**: 豚がジャンプ、キラキラエフェクト

## 4. 機能設計

### 4.1 貯金システム設計

#### 4.1.1 カロリー貯金計算ロジック
```dart
class CalorieBankCalculator {
  static double calculateDailyBalance(
    double caloriesEarned,
    double caloriesConsumed,
  ) {
    return caloriesEarned - caloriesConsumed;
  }

  static double calculateWeeklyTarget(
    double targetWeightLoss,
    int targetDays,
    int currentWeek,
  ) {
    final weeklyWeightLossTarget = targetWeightLoss / (targetDays / 7);
    return weeklyWeightLossTarget * 7700; // 1kg = 7700kcal
  }

  static double predictWeightChange(
    double currentBalance,
    double startWeight,
  ) {
    return startWeight - (currentBalance / 7700);
  }
}
```

#### 4.1.2 週間目標設定ロジック
- 100日を14週間に分割
- 各週の目標を段階的に調整（最初は低め、慣れてきたら高め）
- ユーザーの達成度に応じて次週の目標を微調整

### 4.2 体重連動システム設計

#### 4.2.1 体重予測アルゴリズム
```dart
class WeightPredictionEngine {
  static WeightPrediction calculatePrediction(
    double currentWeight,
    double calorieBalance,
    int daysElapsed,
  ) {
    final expectedWeightLoss = calorieBalance / 7700;
    final predictedWeight = currentWeight - expectedWeightLoss;
    final confidenceLevel = _calculateConfidence(daysElapsed, calorieBalance);
    
    return WeightPrediction(
      predictedWeight: predictedWeight,
      confidence: confidenceLevel,
      timeframe: daysElapsed,
    );
  }
}
```

#### 4.2.2 HealthKit連携
- 毎日の体重データ自動取得
- 活動カロリーの自動計算
- 歩数・運動時間の貯金への反映

### 4.3 食事記録システム設計

#### 4.3.1 AI食事認識（シンプル化）
```dart
class SimpleMealRecognition {
  static Future<MealRecord> recognizeMeal(File imageFile) async {
    final prompt = """
    この食事の写真から以下の情報を推定してください：
    1. 食事名（シンプルに）
    2. 総カロリー数
    3. 主要な栄養素（タンパク質、炭水化物、脂質）
    
    貯金アプリ用なので、細かい分析は不要です。
    """;
    
    // GPT-4 API呼び出し（コスト最適化）
    final response = await openAI.sendPrompt(prompt, imageFile);
    return MealRecord.fromAIResponse(response);
  }
}
```

### 4.4 通知システム設計

#### 4.4.1 最小限通知設計
- **食事記録リマインダー**: 1日2回まで（朝・夜）
- **週間達成お祝い**: 週1回のみ
- **100日完走カウントダウン**: 最後の1週間のみ
- **貯金目標達成**: 即座に通知

## 5. 技術設計

### 5.1 状態管理設計

#### 5.1.1 Provider構成（シンプル化）
```dart
// メイン状態管理
class CalorieBankProvider extends ChangeNotifier {
  CalorieBankAccount? _account;
  List<DailyCalorieTransaction> _transactions = [];
  WeeklyGoal? _currentWeekGoal;
  
  // 必要最小限のメソッドのみ
  Future<void> addMealRecord(MealRecord meal) async { }
  Future<void> updateDailyBalance() async { }
  Future<void> checkWeeklyGoal() async { }
}

// 食事記録プロバイダー
class MealRecordProvider extends ChangeNotifier {
  List<MealRecord> _todayMeals = [];
  bool _isRecording = false;
  
  Future<void> recordMeal(File imageFile) async { }
  void editMeal(String mealId, MealRecord updatedMeal) { }
}
```

### 5.2 データベース設計

#### 5.2.1 Supabaseテーブル構成
```sql
-- カロリー貯金口座
CREATE TABLE calorie_bank_accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  start_date DATE NOT NULL,
  target_days INTEGER DEFAULT 100,
  target_weight_loss DECIMAL DEFAULT 5.0,
  current_balance DECIMAL DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 日次取引記録
CREATE TABLE daily_calorie_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  date DATE NOT NULL,
  calories_earned DECIMAL DEFAULT 0,
  calories_spent DECIMAL DEFAULT 0,
  daily_balance DECIMAL DEFAULT 0,
  weight_record DECIMAL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 週間目標
CREATE TABLE weekly_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  week_number INTEGER NOT NULL,
  target_balance DECIMAL NOT NULL,
  actual_balance DECIMAL DEFAULT 0,
  is_achieved BOOLEAN DEFAULT FALSE,
  week_start_date DATE NOT NULL,
  week_end_date DATE NOT NULL
);
```

### 5.3 API設計

#### 5.3.1 Supabase Functions（必要最小限）
```typescript
// 日次残高更新
export const updateDailyBalance = async (req: Request) => {
  const { userId, date, caloriesEarned, caloriesSpent } = await req.json();
  
  const dailyBalance = caloriesEarned - caloriesSpent;
  
  // 日次記録更新
  await supabase
    .from('daily_calorie_transactions')
    .upsert({
      user_id: userId,
      date: date,
      calories_earned: caloriesEarned,
      calories_spent: caloriesSpent,
      daily_balance: dailyBalance
    });
  
  // 口座残高更新
  await updateAccountBalance(userId, dailyBalance);
  
  return new Response(JSON.stringify({ success: true }));
};
```

## 6. パフォーマンス設計

### 6.1 最適化戦略
- **データ読み込み**: 過去7日分のみローカルキャッシュ
- **画像処理**: クライアントサイド圧縮→API送信
- **AI API**: バッチ処理でコスト削減
- **UI更新**: 必要最小限の再描画

### 6.2 100日完走支援設計
- **プログレスバー**: 全体進捗の視覚化
- **マイルストーン**: 25日、50日、75日での特別演出
- **最終週カウントダウン**: ラスト7日の特別UI
- **卒業機能**: 100日達成時の完了画面とデータエクスポート

## 7. セキュリティ・プライバシー設計

### 7.1 データ保護
- **最小データ収集**: 必要最小限のデータのみ
- **画像の一時保存**: AI処理後即座に削除
- **ローカル暗号化**: 機密データのデバイス内暗号化

### 7.2 100日後のデータ処理
- **データエクスポート**: CSV形式での全データ提供
- **アカウント継続**: 希望者のみデータ保持
- **自動削除**: 120日後の自動データ削除オプション

## 8. 設計検証

### 8.1 シンプルさの検証
- [ ] 機能説明が1分以内で完了するか
- [ ] メイン画面のタップ数が3回以内で全機能アクセス可能か
- [ ] 設定項目が10個以下に収まっているか

### 8.2 100日完走可能性の検証
- [ ] 週間目標が現実的に達成可能か
- [ ] モチベーション維持の仕組みが十分か
- [ ] 途中離脱防止の機能が適切か

この設計で要件を満たしつつ、シンプルで直感的な「カロリー貯金」体験を提供できます。