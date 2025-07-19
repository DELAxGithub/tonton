import '../models/pfc_breakdown.dart';

class PFCCalculator {
  // カロリーマトリクス定義（ハードコーディング）
  // 年齢層: young(若年層 18-29), middle(中年層 30-49), senior(高年層 50-69)
  static const Map<String, Map<String, int>> calorieMatrix = {
    'young': {'male': 2300, 'female': 1750},
    'middle': {'male': 2200, 'female': 1750},
    'senior': {'male': 2100, 'female': 1700},
  };

  // デフォルト値（性別・年齢層が未設定の場合）
  static const int defaultRecommendedCalories = 2000;
  static const int dailySavingsTarget = 240; // 毎日の貯金目標

  /// ユーザー情報から自動的にPFCバランスを計算
  /// @param weight 体重(kg)
  /// @param gender 性別 ('male' or 'female') - DEPRECATED
  /// @param ageGroup 年齢層 ('young', 'middle', 'senior') - DEPRECATED
  /// @param dietGoal ダイエット目的 ('weight_loss', 'muscle_gain', 'maintain')
  static PfcBreakdown calculateAutomatic({
    required double weight,
    String? gender,
    String? ageGroup,
    String? dietGoal,
  }) {
    // 1. ダイエット目的に応じたタンパク質計算
    double proteinMultiplier;
    double fatRatio;
    
    switch (dietGoal) {
      case 'muscle_gain':
        // 筋肉増強: 高タンパク（体重×2.5g）、中脂質（25%）
        proteinMultiplier = 2.5;
        fatRatio = 0.25;
        break;
      case 'weight_loss':
        // 体重減少: 中タンパク（体重×2g）、低脂質（20%）
        proteinMultiplier = 2.0;
        fatRatio = 0.20;
        break;
      case 'maintain':
      default:
        // 体型維持: 標準タンパク（体重×1.5g）、標準脂質（30%）
        proteinMultiplier = 1.5;
        fatRatio = 0.30;
        break;
    }
    
    final proteinGrams = weight * proteinMultiplier;
    final proteinCalories = proteinGrams * 4; // タンパク質は1gあたり4kcal

    // 2. 推奨カロリーの取得（旧ロジック互換性のため残す）
    int recommendedCalories = defaultRecommendedCalories;
    if (gender != null && ageGroup != null) {
      recommendedCalories =
          calorieMatrix[ageGroup]?[gender] ?? defaultRecommendedCalories;
    }

    // 3. 目標カロリー = 推奨カロリー - 貯金目標
    final targetCalories = recommendedCalories - dailySavingsTarget;

    // 4. 残りカロリー = 目標カロリー - タンパク質カロリー
    final remainingCalories = targetCalories - proteinCalories;

    // 5. 脂質 = 残りカロリーの指定割合
    final fatCalories = remainingCalories * fatRatio;
    final fatGrams = fatCalories / 9; // 脂質は1gあたり9kcal

    // 6. 炭水化物 = 残りすべて
    final carbCalories = remainingCalories - fatCalories;
    final carbGrams = carbCalories / 4; // 炭水化物は1gあたり4kcal

    return PfcBreakdown(
      protein: proteinGrams.roundToDouble(),
      fat: fatGrams.roundToDouble(),
      carbohydrate: carbGrams.roundToDouble(),
    );
  }

  /// 固定比率でPFCバランスを計算（レガシー）
  /// @param targetCalories 目標カロリー
  /// @param ratio PFC比率 (デフォルト 3:2:5)
  static PfcBreakdown calculateFromRatio({
    required int targetCalories,
    List<int> ratio = const [3, 2, 5],
  }) {
    final total = ratio.reduce((a, b) => a + b);
    final proteinRatio = ratio[0] / total;
    final fatRatio = ratio[1] / total;
    final carbRatio = ratio[2] / total;

    final proteinCalories = targetCalories * proteinRatio;
    final fatCalories = targetCalories * fatRatio;
    final carbCalories = targetCalories * carbRatio;

    return PfcBreakdown(
      protein: (proteinCalories / 4).roundToDouble(), // 4kcal/g
      fat: (fatCalories / 9).roundToDouble(), // 9kcal/g
      carbohydrate: (carbCalories / 4).roundToDouble(), // 4kcal/g
    );
  }
}
