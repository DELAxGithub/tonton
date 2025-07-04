import 'pfc_breakdown.dart';

/// Stores user nutrition goals such as PFC balance and protein target.
class UserGoals {
  /// Default ratio used when no custom value is provided.
  static const PfcRatio defaultPfcRatio = PfcRatio(
    protein: 0.3,
    fat: 0.2,
    carbohydrate: 0.5,
  );

  /// Desired PFC ratio (should sum to 1.0). Defaults to [defaultPfcRatio].
  final PfcRatio pfcRatio;

  /// Current body weight in kilograms for calculating protein goal.
  final double? bodyWeightKg;

  const UserGoals({this.pfcRatio = defaultPfcRatio, this.bodyWeightKg});

  Map<String, dynamic> toJson() => {
    'pfcRatio': pfcRatio.toJson(),
    'bodyWeightKg': bodyWeightKg,
  };

  factory UserGoals.fromJson(Map<String, dynamic> json) {
    return UserGoals(
      pfcRatio:
          json['pfcRatio'] != null
              ? PfcRatio.fromJson(json['pfcRatio'] as Map<String, dynamic>)
              : defaultPfcRatio,
      bodyWeightKg: (json['bodyWeightKg'] as num?)?.toDouble(),
    );
  }

  /// Daily protein goal in grams based on [bodyWeightKg].
  double? get proteinGoalGrams =>
      bodyWeightKg != null ? bodyWeightKg! * 2.0 : null;
}
