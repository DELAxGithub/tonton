import '../../models/pfc_breakdown.dart';

/// 食事記録ゼロの日に「いつも通り食べた／食べてない／食べすぎた」のニュアンスで
/// 推定カロリーを埋めるための区分。
///
/// 倍率は基準値（過去 N 日の摂取平均など）に乗じる係数。
enum EstimationLevel {
  lessThanUsual, // 食べてない方
  usual,         // いつも通り
  moreThanUsual, // 食べすぎた
}

extension EstimationLevelX on EstimationLevel {
  String get label {
    switch (this) {
      case EstimationLevel.lessThanUsual:
        return '食べてない方';
      case EstimationLevel.usual:
        return 'いつも通り';
      case EstimationLevel.moreThanUsual:
        return '食べすぎた';
    }
  }

  double get multiplier {
    switch (this) {
      case EstimationLevel.lessThanUsual:
        return 0.8;
      case EstimationLevel.usual:
        return 1.0;
      case EstimationLevel.moreThanUsual:
        return 1.2;
    }
  }
}

/// カロリー / PFC を「推定で埋める」ための数値セット。
class EstimationPreset {
  final EstimationLevel level;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;

  const EstimationPreset({
    required this.level,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });
}

/// 指定した基準カロリー + PFC比率からプリセットを生成する。
///
/// [baselineKcal] は「ユーザーが普段（いつも通り）食べているとみなすカロリー」を指す。
/// 過去 N 日の摂取平均、または cold start 時はプロフィール由来の目標値などを渡す。
EstimationPreset buildEstimationPreset({
  required EstimationLevel level,
  required double baselineKcal,
  required PfcRatio pfcRatio,
}) {
  final kcal = baselineKcal * level.multiplier;
  final protein = (kcal * pfcRatio.protein) / 4; // 4 kcal/g
  final fat = (kcal * pfcRatio.fat) / 9; // 9 kcal/g
  final carbs = (kcal * pfcRatio.carbohydrate) / 4; // 4 kcal/g
  return EstimationPreset(
    level: level,
    calories: kcal,
    protein: protein,
    fat: fat,
    carbs: carbs,
  );
}
