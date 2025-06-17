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
  /// @param gender 性別 ('male' or 'female')
  /// @param ageGroup 年齢層 ('young', 'middle', 'senior')
  static PfcBreakdown calculateAutomatic({
    required double weight,
    String? gender,
    String? ageGroup,
  }) {
    // 1. タンパク質計算: 体重 × 2g
    final proteinGrams = weight * 2;
    final proteinCalories = proteinGrams * 4; // タンパク質は1gあたり4kcal

    // 2. 推奨カロリーの取得
    int recommendedCalories = defaultRecommendedCalories;
    if (gender != null && ageGroup != null) {
      recommendedCalories =
          calorieMatrix[ageGroup]?[gender] ?? defaultRecommendedCalories;
    }

    // 3. 目標カロリー = 推奨カロリー - 貯金目標
    final targetCalories = recommendedCalories - dailySavingsTarget;

    // 4. 残りカロリー = 目標カロリー - タンパク質カロリー
    final remainingCalories = targetCalories - proteinCalories;

    // 5. 脂質 = 残りカロリーの30%
    final fatCalories = remainingCalories * 0.3;
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
