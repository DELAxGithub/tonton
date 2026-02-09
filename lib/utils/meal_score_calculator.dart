import 'dart:math';

import '../models/pfc_breakdown.dart';
import '../models/meal_record.dart';

/// Result of a meal or daily PFC balance score calculation
class MealScoreResult {
  final int score; // 0-100
  final String grade; // A, B, C, D
  final String label; // バランス◎, いい感じ, etc.
  final String feedback; // One-line advice

  const MealScoreResult({
    required this.score,
    required this.grade,
    required this.label,
    required this.feedback,
  });

  /// Returns true if the score represents good balance (A or B grade)
  bool get isGood => score >= 60;
}

/// Calculates meal scores based on PFC balance against targets
class MealScoreCalculator {
  // Nutrient weights for scoring
  static const _proteinWeight = 0.40;
  static const _fatWeight = 0.25;
  static const _carbsWeight = 0.35;

  /// Calculate daily score: actual PFC grams vs target PFC grams
  static MealScoreResult calculateDailyScore(
    PfcBreakdown actual,
    PfcBreakdown target,
  ) {
    final proteinScore = _nutrientScore(actual.protein, target.protein);
    final fatScore = _nutrientScore(actual.fat, target.fat);
    final carbsScore = _nutrientScore(actual.carbohydrate, target.carbohydrate);

    final totalScore = (proteinScore * _proteinWeight +
            fatScore * _fatWeight +
            carbsScore * _carbsWeight)
        .round()
        .clamp(0, 100);

    final feedback = _generateFeedback(
      actual.protein,
      target.protein,
      actual.fat,
      target.fat,
      actual.carbohydrate,
      target.carbohydrate,
      totalScore,
    );

    return MealScoreResult(
      score: totalScore,
      grade: _gradeFor(totalScore),
      label: _labelFor(totalScore),
      feedback: feedback,
    );
  }

  /// Calculate per-meal score: meal PFC ratio vs target PFC ratio
  static MealScoreResult calculateMealScore(
    MealRecord meal,
    PfcBreakdown target,
  ) {
    final mealTotal = meal.protein + meal.fat + meal.carbs;
    final targetTotal = target.protein + target.fat + target.carbohydrate;

    // Avoid division by zero
    if (mealTotal == 0 || targetTotal == 0) {
      return const MealScoreResult(
        score: 0,
        grade: 'D',
        label: '改善しよう',
        feedback: '栄養データがありません',
      );
    }

    final mealRatioP = meal.protein / mealTotal;
    final mealRatioF = meal.fat / mealTotal;
    final mealRatioC = meal.carbs / mealTotal;

    final targetRatioP = target.protein / targetTotal;
    final targetRatioF = target.fat / targetTotal;
    final targetRatioC = target.carbohydrate / targetTotal;

    final proteinScore = _ratioScore(mealRatioP, targetRatioP);
    final fatScore = _ratioScore(mealRatioF, targetRatioF);
    final carbsScore = _ratioScore(mealRatioC, targetRatioC);

    final totalScore = (proteinScore * _proteinWeight +
            fatScore * _fatWeight +
            carbsScore * _carbsWeight)
        .round()
        .clamp(0, 100);

    final feedback = _generateRatioFeedback(
      mealRatioP,
      targetRatioP,
      mealRatioF,
      targetRatioF,
      mealRatioC,
      targetRatioC,
      totalScore,
    );

    return MealScoreResult(
      score: totalScore,
      grade: _gradeFor(totalScore),
      label: _labelFor(totalScore),
      feedback: feedback,
    );
  }

  /// Score a single nutrient: how close actual grams are to target grams
  static double _nutrientScore(double actual, double target) {
    if (target == 0) return 100.0;
    final ratio = actual / target;
    final deviation = (ratio - 1.0).abs();
    return max(0.0, 100.0 - deviation * 100.0);
  }

  /// Score a single nutrient ratio: how close meal ratio is to target ratio
  static double _ratioScore(double mealRatio, double targetRatio) {
    if (targetRatio == 0) return 100.0;
    final deviation = (mealRatio - targetRatio).abs() / targetRatio;
    return max(0.0, 100.0 - deviation * 100.0);
  }

  static String _gradeFor(int score) {
    if (score >= 80) return 'A';
    if (score >= 60) return 'B';
    if (score >= 40) return 'C';
    return 'D';
  }

  static String _labelFor(int score) {
    if (score >= 80) return 'バランス◎';
    if (score >= 60) return 'いい感じ';
    if (score >= 40) return 'もう少し';
    return '改善しよう';
  }

  /// Generate feedback based on which nutrient deviates most (absolute grams)
  static String _generateFeedback(
    double actualP,
    double targetP,
    double actualF,
    double targetF,
    double actualC,
    double targetC,
    int score,
  ) {
    if (score >= 80) return 'バランスの取れた食事です！';

    // Find the nutrient with the worst deviation (weighted)
    final pDev = targetP > 0 ? (actualP / targetP - 1.0) : 0.0;
    final fDev = targetF > 0 ? (actualF / targetF - 1.0) : 0.0;
    final cDev = targetC > 0 ? (actualC / targetC - 1.0) : 0.0;

    // Weighted absolute deviations
    final pWeight = pDev.abs() * _proteinWeight;
    final fWeight = fDev.abs() * _fatWeight;
    final cWeight = cDev.abs() * _carbsWeight;

    final maxWeight = max(pWeight, max(fWeight, cWeight));

    if (maxWeight == pWeight) {
      return pDev < 0 ? 'たんぱく質をもう少し摂りましょう' : 'たんぱく質が多めです';
    } else if (maxWeight == fWeight) {
      return fDev < 0 ? '脂質が少なめです' : '脂質を控えめに';
    } else {
      return cDev < 0 ? '炭水化物が不足気味です' : '炭水化物を控えめに';
    }
  }

  /// Generate feedback based on ratio deviations (per-meal)
  static String _generateRatioFeedback(
    double mealP,
    double targetP,
    double mealF,
    double targetF,
    double mealC,
    double targetC,
    int score,
  ) {
    if (score >= 80) return 'バランスの取れた食事です！';

    final pDev = targetP > 0 ? (mealP - targetP) / targetP : 0.0;
    final fDev = targetF > 0 ? (mealF - targetF) / targetF : 0.0;
    final cDev = targetC > 0 ? (mealC - targetC) / targetC : 0.0;

    final pWeight = pDev.abs() * _proteinWeight;
    final fWeight = fDev.abs() * _fatWeight;
    final cWeight = cDev.abs() * _carbsWeight;

    final maxWeight = max(pWeight, max(fWeight, cWeight));

    if (maxWeight == pWeight) {
      return pDev < 0 ? 'たんぱく質をもう少し摂りましょう' : 'たんぱく質が多めです';
    } else if (maxWeight == fWeight) {
      return fDev < 0 ? '脂質が少なめです' : '脂質を控えめに';
    } else {
      return cDev < 0 ? '炭水化物が不足気味です' : '炭水化物を控えめに';
    }
  }
}
