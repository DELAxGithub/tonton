import '../../models/pfc_breakdown.dart';

enum EstimationLevel {
  light, // 少なめ
  normal, // 普通
  heavy, // 多め
}

extension EstimationLevelX on EstimationLevel {
  String get label {
    switch (this) {
      case EstimationLevel.light:
        return '少なめ';
      case EstimationLevel.normal:
        return '普通';
      case EstimationLevel.heavy:
        return '多め';
    }
  }

  double get multiplier {
    switch (this) {
      case EstimationLevel.light:
        return 0.8;
      case EstimationLevel.normal:
        return 1.0;
      case EstimationLevel.heavy:
        return 1.3;
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

/// 指定したベースカロリー + PFC比率からプリセットを生成する。
EstimationPreset buildEstimationPreset({
  required EstimationLevel level,
  required double baseDailyCalories,
  required PfcRatio pfcRatio,
}) {
  final kcal = baseDailyCalories * level.multiplier;
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
