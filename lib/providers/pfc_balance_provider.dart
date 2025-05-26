import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pfc_breakdown.dart';
import '../models/user_goals.dart';
import 'meal_records_provider.dart';
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
    state = UserGoals(pfcRatio: ratio, bodyWeightKg: state.bodyWeightKg);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_goals', jsonEncode(state.toJson()));
  }

  Future<void> setBodyWeight(double weight) async {
    state = UserGoals(pfcRatio: state.pfcRatio, bodyWeightKg: weight);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_goals', jsonEncode(state.toJson()));
  }
}

final userGoalsProvider =
    StateNotifierProvider<UserGoalsNotifier, UserGoals>(
        (ref) => UserGoalsNotifier());


