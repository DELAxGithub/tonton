import '../utils/weight_loss_calculator.dart';
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

  /// Height in centimeters (used for TDEE estimation).
  final double? heightCm;

  /// Age in years (used for TDEE estimation).
  final int? age;

  /// True if male; false if female. Null if unset.
  final bool? isMale;

  /// Activity factor for TDEE. 1.2=座りがち / 1.375=軽い運動 / 1.55=中 / 1.725=激しい
  final double activityFactor;

  /// Target weekly weight-loss pace as fraction of body weight.
  /// 0.005 = 0.5%/週 (ゆるめ), 0.007 = 0.7%/週 (標準), 0.010 = 1.0%/週 (攻め)
  final double targetWeeklyPercentLoss;

  /// User's currently configured daily calorie deficit goal (kcal/day).
  /// Legacy default 240 matches the pre-pace app behavior.
  /// Tapping a pace preset in Profile updates this to match the required deficit.
  final double dailyDeficitGoalKcal;

  /// Body weight (kg) at the moment the user (re)started the diet
  /// (= when onboardingStartDate was set). Used as the anchor for ideal-pace
  /// trajectories. Null when no snapshot has been taken yet.
  final double? startingBodyWeightKg;

  /// Date that [startingBodyWeightKg] was captured. Drives the elapsed-week
  /// term in the ideal-weight calculation.
  final DateTime? startingBodyWeightDate;

  /// Legacy default goal that matches the pre-pace experience.
  static const double legacyDailyDeficitGoalKcal = 240;

  const UserGoals({
    this.pfcRatio = defaultPfcRatio,
    this.bodyWeightKg,
    this.heightCm,
    this.age,
    this.isMale,
    this.activityFactor = 1.4,
    this.targetWeeklyPercentLoss =
        WeightLossCalculator.defaultWeeklyPercent,
    this.dailyDeficitGoalKcal = legacyDailyDeficitGoalKcal,
    this.startingBodyWeightKg,
    this.startingBodyWeightDate,
  });

  UserGoals copyWith({
    PfcRatio? pfcRatio,
    double? bodyWeightKg,
    double? heightCm,
    int? age,
    bool? isMale,
    double? activityFactor,
    double? targetWeeklyPercentLoss,
    double? dailyDeficitGoalKcal,
    double? startingBodyWeightKg,
    DateTime? startingBodyWeightDate,
  }) {
    return UserGoals(
      pfcRatio: pfcRatio ?? this.pfcRatio,
      bodyWeightKg: bodyWeightKg ?? this.bodyWeightKg,
      heightCm: heightCm ?? this.heightCm,
      age: age ?? this.age,
      isMale: isMale ?? this.isMale,
      activityFactor: activityFactor ?? this.activityFactor,
      targetWeeklyPercentLoss:
          targetWeeklyPercentLoss ?? this.targetWeeklyPercentLoss,
      dailyDeficitGoalKcal:
          dailyDeficitGoalKcal ?? this.dailyDeficitGoalKcal,
      startingBodyWeightKg:
          startingBodyWeightKg ?? this.startingBodyWeightKg,
      startingBodyWeightDate:
          startingBodyWeightDate ?? this.startingBodyWeightDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'pfcRatio': pfcRatio.toJson(),
    'bodyWeightKg': bodyWeightKg,
    'heightCm': heightCm,
    'age': age,
    'isMale': isMale,
    'activityFactor': activityFactor,
    'targetWeeklyPercentLoss': targetWeeklyPercentLoss,
    'dailyDeficitGoalKcal': dailyDeficitGoalKcal,
    'startingBodyWeightKg': startingBodyWeightKg,
    'startingBodyWeightDate': startingBodyWeightDate?.toIso8601String(),
  };

  factory UserGoals.fromJson(Map<String, dynamic> json) {
    return UserGoals(
      pfcRatio:
          json['pfcRatio'] != null
              ? PfcRatio.fromJson(json['pfcRatio'] as Map<String, dynamic>)
              : defaultPfcRatio,
      bodyWeightKg: (json['bodyWeightKg'] as num?)?.toDouble(),
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      age: (json['age'] as num?)?.toInt(),
      isMale: json['isMale'] as bool?,
      activityFactor: (json['activityFactor'] as num?)?.toDouble() ?? 1.4,
      targetWeeklyPercentLoss:
          (json['targetWeeklyPercentLoss'] as num?)?.toDouble() ??
              WeightLossCalculator.defaultWeeklyPercent,
      dailyDeficitGoalKcal:
          (json['dailyDeficitGoalKcal'] as num?)?.toDouble() ??
              legacyDailyDeficitGoalKcal,
      startingBodyWeightKg:
          (json['startingBodyWeightKg'] as num?)?.toDouble(),
      startingBodyWeightDate:
          json['startingBodyWeightDate'] is String
              ? DateTime.parse(json['startingBodyWeightDate'] as String)
              : null,
    );
  }

  /// Daily protein goal in grams based on [bodyWeightKg].
  double? get proteinGoalGrams =>
      bodyWeightKg != null ? bodyWeightKg! * 2.0 : null;

  /// Required daily kcal deficit to hit [targetWeeklyPercentLoss].
  /// Returns null if body weight is unset.
  double? get requiredDailyDeficitKcal {
    if (bodyWeightKg == null) return null;
    return WeightLossCalculator.requiredDailyDeficit(
      weightKg: bodyWeightKg!,
      weeklyPercentLoss: targetWeeklyPercentLoss,
    );
  }

  /// Estimated TDEE (kcal/day). Returns null if height/age/sex are unset.
  double? get estimatedTdee {
    if (bodyWeightKg == null ||
        heightCm == null ||
        age == null ||
        isMale == null) {
      return null;
    }
    return WeightLossCalculator.estimateTdee(
      weightKg: bodyWeightKg!,
      heightCm: heightCm!,
      age: age!,
      isMale: isMale!,
      activityFactor: activityFactor,
    );
  }
}
