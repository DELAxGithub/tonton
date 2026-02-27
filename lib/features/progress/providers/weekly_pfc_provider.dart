import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/daily_pfc_summary.dart';
import '../../../models/pfc_breakdown.dart';
import '../../../models/meal_record.dart';
import '../../../utils/meal_score_calculator.dart';
import '../../../utils/pfc_calculator.dart';
import '../../meal_logging/providers/meal_records_provider.dart';
import 'auto_pfc_provider.dart';

final _fallbackTarget = PFCCalculator.calculateAutomatic(weight: 60.0);

/// Provides PFC summary for the last 7 days (today + 6 previous days).
/// Returns a list sorted oldest-first (index 0 = 6 days ago, index 6 = today).
final weeklyPfcSummaryProvider = Provider<List<DailyPfcSummary>>((ref) {
  final mealRecordsAsync = ref.watch(mealRecordsProvider);
  final target = ref.watch(autoPfcTargetProvider) ?? _fallbackTarget;

  return mealRecordsAsync.when(
    data: (state) => buildWeeklySummary(state.records, target),
    loading: () => buildEmptyWeek(),
    error: (_, __) => buildEmptyWeek(),
  );
});

/// Build weekly PFC summary from meal records.
/// Exposed for testing.
@visibleForTesting
List<DailyPfcSummary> buildWeeklySummary(
  List<MealRecord> allRecords,
  PfcBreakdown target,
) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final result = <DailyPfcSummary>[];

  for (int i = 6; i >= 0; i--) {
    final date = today.subtract(Duration(days: i));
    final dayRecords = allRecords.where((r) {
      final d = r.consumedAt;
      return d.year == date.year && d.month == date.month && d.day == date.day;
    }).toList();

    double protein = 0, fat = 0, carbs = 0;
    for (final meal in dayRecords) {
      protein += meal.protein;
      fat += meal.fat;
      carbs += meal.carbs;
    }

    final pfc = PfcBreakdown(protein: protein, fat: fat, carbohydrate: carbs);

    MealScoreResult? scoreResult;
    if (dayRecords.isNotEmpty) {
      scoreResult = MealScoreCalculator.calculateDailyScore(pfc, target);
    }

    result.add(DailyPfcSummary(
      date: date,
      pfc: pfc,
      mealCount: dayRecords.length,
      score: scoreResult?.score,
      grade: scoreResult?.grade,
    ));
  }

  return result;
}

/// Build an empty week (7 days of zero data).
@visibleForTesting
List<DailyPfcSummary> buildEmptyWeek() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return List.generate(7, (i) {
    final date = today.subtract(Duration(days: 6 - i));
    return DailyPfcSummary(
      date: date,
      pfc: PfcBreakdown(protein: 0, fat: 0, carbohydrate: 0),
      mealCount: 0,
    );
  });
}
