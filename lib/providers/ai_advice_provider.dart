import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider_pkg;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/meal_record.dart';
import '../models/pfc_breakdown.dart';
import '../models/ai_advice_request.dart';
import '../models/ai_advice_response.dart';
import '../providers/health_provider.dart';
import '../services/ai_advice_service.dart';

final aiAdviceServiceProvider = Provider<AiAdviceService>((ref) {
  final client = Supabase.instance.client;
  return AiAdviceService(client);
});

class AiAdviceNotifier extends StateNotifier<AsyncValue<AiAdviceResponse?>> {
  final AiAdviceService _service;

  AiAdviceNotifier(this._service) : super(const AsyncValue.data(null));

  Future<void> fetchAdvice(List<MealRecord> meals, BuildContext context) async {
    state = const AsyncValue.loading();
    try {
      const targetCalories = 2000.0;
      final targetPfcRatio = PfcRatio(
        protein: 0.3,
        fat: 0.2,
        carbohydrate: 0.5,
      );

      double consumedProtein = 0;
      double consumedFat = 0;
      double consumedCarbs = 0;
      double consumedCalories = 0;

      for (final meal in meals) {
        consumedProtein += meal.protein;
        consumedFat += meal.fat;
        consumedCarbs += meal.carbs;
        consumedCalories += meal.calories;
      }

      final consumedMealsPfc = PfcBreakdown(
        protein: consumedProtein,
        fat: consumedFat,
        carbohydrate: consumedCarbs,
        calories: consumedCalories,
      );

      double activeCalories = 0;
      final hp = provider_pkg.Provider.of<HealthProvider>(
        context,
        listen: false,
      );
      if (hp.todayActivity != null) {
        activeCalories = hp.todayActivity!.workoutCalories;
      }

      final locale = Localizations.localeOf(context).languageCode;

      final request = AiAdviceRequest(
        targetCalories: targetCalories,
        targetPfcRatio: targetPfcRatio,
        consumedMealsPfc: consumedMealsPfc,
        activeCalories: activeCalories,
        lang: locale,
      );

      final response = await _service.getMealAdvice(request);
      state = AsyncValue.data(response);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final aiAdviceProvider =
    StateNotifierProvider<AiAdviceNotifier, AsyncValue<AiAdviceResponse?>>((
      ref,
    ) {
      final service = ref.watch(aiAdviceServiceProvider);
      return AiAdviceNotifier(service);
    });
