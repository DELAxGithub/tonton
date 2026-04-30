import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/pfc_breakdown.dart';
import '../../../models/user_goals.dart';
import '../../meal_logging/providers/meal_records_provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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

class UserGoalsNotifier extends StateNotifier<UserGoals> {
  UserGoalsNotifier() : super(const UserGoals()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('user_goals');
    if (jsonStr != null) {
      state = UserGoals.fromJson(jsonDecode(jsonStr));
    }
  }

  Future<void> setPfcRatio(PfcRatio ratio) async {
    state = state.copyWith(pfcRatio: ratio);
    await _persist();
  }

  Future<void> setBodyWeight(double weight) async {
    state = state.copyWith(bodyWeightKg: weight);
    await _persist();
  }

  Future<void> setTargetWeeklyPercentLoss(double percent) async {
    state = state.copyWith(targetWeeklyPercentLoss: percent);
    await _persist();
  }

  /// Convenience: pick a pace and auto-align the current daily deficit goal to it.
  Future<void> applyPacePreset(double percent) async {
    final newState = state.copyWith(targetWeeklyPercentLoss: percent);
    final required = newState.requiredDailyDeficitKcal;
    state = required != null
        ? newState.copyWith(dailyDeficitGoalKcal: required.roundToDouble())
        : newState;
    await _persist();
  }

  Future<void> setDailyDeficitGoalKcal(double kcal) async {
    state = state.copyWith(dailyDeficitGoalKcal: kcal);
    await _persist();
  }

  /// Snapshot the starting body weight + date that anchor the ideal-pace
  /// trajectory. Called when the user (re)sets the diet start date and we
  /// have a current weight to capture.
  Future<void> setStartingBodyWeight({
    required double weight,
    required DateTime date,
  }) async {
    state = state.copyWith(
      startingBodyWeightKg: weight,
      startingBodyWeightDate: date,
    );
    await _persist();
  }

  Future<void> setBodyProfile({
    double? heightCm,
    int? age,
    bool? isMale,
    double? activityFactor,
  }) async {
    state = state.copyWith(
      heightCm: heightCm,
      age: age,
      isMale: isMale,
      activityFactor: activityFactor,
    );
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_goals', jsonEncode(state.toJson()));
  }
}

final userGoalsProvider = StateNotifierProvider<UserGoalsNotifier, UserGoals>(
  (ref) => UserGoalsNotifier(),
);
