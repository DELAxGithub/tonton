import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pfc_breakdown.dart';
import '../models/user_goals.dart';
import 'meal_records_provider.dart';

/// Provider that calculates today's total PFC intake.
final todaysPfcProvider = Provider<PfcBreakdown>((ref) {
  final meals = ref.watch(todaysMealRecordsProvider);
  double protein = 0;
  double fat = 0;
  double carbs = 0;
  for (final meal in meals) {
    protein += meal.protein;
    fat += meal.fat;
    carbs += meal.carbs;
  }
  return PfcBreakdown(protein: protein, fat: fat, carbohydrate: carbs);
});

/// Provider exposing user nutrition goals.
final userGoalsProvider = Provider<UserGoals>((ref) {
  // In a real implementation, this would load persisted settings.
  return const UserGoals();
});

