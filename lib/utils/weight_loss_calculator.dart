/// 体重減量の健康的なペース・必要カロリー赤字・期待減量を算出するヘルパー。
///
/// 係数の根拠:
/// - Mifflin-St Jeor 式 (1990): 基礎代謝(BMR)推定
/// - 1kg の体脂肪 ≈ 7700kcal (日本語圏の一般係数。米国 3500 は pound 基準)
/// - 健康的な減量ペース: 体重の 0.5〜1.0% / 週 (各種ガイドライン)
class WeightLossCalculator {
  static const double kcalPerKg = 7700;

  static const double minHealthyWeeklyPercent = 0.005;
  static const double maxHealthyWeeklyPercent = 0.010;
  static const double defaultWeeklyPercent = 0.007;

  /// Mifflin-St Jeor 式で TDEE を推定する。
  /// 活動係数: 1.2 座りがち / 1.375 軽い運動 / 1.55 中程度 / 1.725 激しい
  static double estimateTdee({
    required double weightKg,
    required double heightCm,
    required int age,
    required bool isMale,
    double activityFactor = 1.4,
  }) {
    final bmr =
        10 * weightKg + 6.25 * heightCm - 5 * age + (isMale ? 5 : -161);
    return bmr * activityFactor;
  }

  /// 希望ペース（体重%/週）を達成するために必要な日次カロリー赤字。
  static double requiredDailyDeficit({
    required double weightKg,
    required double weeklyPercentLoss,
  }) {
    final weeklyKg = weightKg * weeklyPercentLoss;
    final weeklyKcal = weeklyKg * kcalPerKg;
    return weeklyKcal / 7;
  }

  /// 累積赤字から期待される体重減少量（kg）。
  static double expectedWeightLossKg({
    required double cumulativeDeficitKcal,
  }) {
    return cumulativeDeficitKcal / kcalPerKg;
  }
}
