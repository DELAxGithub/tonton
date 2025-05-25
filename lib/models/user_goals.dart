import 'pfc_breakdown.dart';

/// Stores user nutrition goals such as PFC balance and protein target.
class UserGoals {
  /// Desired PFC ratio (should sum to 1.0). Defaults to 30:20:50.
  final PfcRatio pfcRatio;

  /// Current body weight in kilograms for calculating protein goal.
  final double? bodyWeightKg;

  const UserGoals({
    this.pfcRatio = const PfcRatio(protein: 0.3, fat: 0.2, carbohydrate: 0.5),
    this.bodyWeightKg,
  });

  /// Daily protein goal in grams based on [bodyWeightKg].
  double? get proteinGoalGrams =>
      bodyWeightKg != null ? bodyWeightKg! * 2.0 : null;
}

