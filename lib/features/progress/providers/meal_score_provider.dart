import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/meal_record.dart';
import '../../../utils/pfc_calculator.dart';
import '../../../utils/meal_score_calculator.dart';
import 'pfc_balance_provider.dart';
import 'auto_pfc_provider.dart';

/// Fallback PFC target when user weight is not set (assumes 60kg)
final _fallbackTarget = PFCCalculator.calculateAutomatic(weight: 60.0);

/// Provider that calculates today's overall PFC balance score
final dailyMealScoreProvider = Provider<MealScoreResult?>((ref) {
  final todaysPfc = ref.watch(todaysPfcProvider);
  final target = ref.watch(autoPfcTargetProvider) ?? _fallbackTarget;

  // No meals recorded yet
  if (todaysPfc.protein == 0 &&
      todaysPfc.fat == 0 &&
      todaysPfc.carbohydrate == 0) {
    return null;
  }

  return MealScoreCalculator.calculateDailyScore(todaysPfc, target);
});

/// Provider that calculates a score for a single meal record
final mealScoreProvider =
    Provider.family<MealScoreResult?, MealRecord>((ref, meal) {
  final target = ref.watch(autoPfcTargetProvider) ?? _fallbackTarget;

  if (meal.protein == 0 && meal.fat == 0 && meal.carbs == 0) {
    return null;
  }

  return MealScoreCalculator.calculateMealScore(meal, target);
});
