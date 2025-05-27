import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/calorie_savings_record.dart';
import '../models/daily_summary.dart';
import '../providers/onboarding_start_date_provider.dart';
import 'realtime_calories_provider.dart';
import 'meal_records_provider.dart';

// Provider for monthly target
final monthlySavingsTargetProvider = Provider<double>((ref) {
  return 14400.0; // Monthly target in kcal
});

/// Notifier for editing the monthly calorie goal in the demo screen.
class MonthlyCalorieGoalNotifier extends StateNotifier<double> {
  MonthlyCalorieGoalNotifier() : super(14400.0);

  void setGoal(double goal) => state = goal;
}

final monthlyCalorieGoalProvider =
    StateNotifierProvider<MonthlyCalorieGoalNotifier, double>(
        (ref) => MonthlyCalorieGoalNotifier());

// Provider for calorie savings data
final calorieSavingsDataProvider =
    FutureProvider<List<CalorieSavingsRecord>>((ref) async {
  // Watch meal records so savings data updates when meals change.
  ref.watch(mealRecordsProvider);
  final startDate = ref.watch(onboardingStartDateProvider);
  if (startDate == null) return [];

  final service = ref.watch(dailySummaryServiceProvider);
  final endDate = DateTime.now().subtract(const Duration(days: 1));
  final summaries = <DailySummary>[];
  var current = DateTime(startDate.year, startDate.month, startDate.day);

  while (!current.isAfter(endDate)) {
    summaries.add(await service.getDailySummary(current));
    current = current.add(const Duration(days: 1));
  }

  double runningTotal = 0;
  return summaries.map((summary) {
    final daily = summary.caloriesBurned - summary.caloriesConsumed;
    runningTotal += daily;
    return CalorieSavingsRecord(
      date: summary.date,
      caloriesConsumed: summary.caloriesConsumed,
      caloriesBurned: summary.caloriesBurned,
      dailyBalance: daily,
      cumulativeSavings: runningTotal,
    );
  }).toList();
});

import 'selected_period_provider.dart';

/// Filtered calorie savings records based on the selected period.
final filteredCalorieSavingsProvider = Provider<List<CalorieSavingsRecord>>((ref) {
  final period = ref.watch(selectedPeriodProvider);
  final recordsAsync = ref.watch(calorieSavingsDataProvider);

  return recordsAsync.maybeWhen(
    data: (records) {
      if (period == SelectedPeriod.all) return records;
      final days = switch (period) {
        SelectedPeriod.week => 7,
        SelectedPeriod.month => 30,
        SelectedPeriod.quarter => 90,
        SelectedPeriod.all => records.length,
      };
      final cutoff = DateTime.now().subtract(Duration(days: days));
      return records.where((r) => !r.date.isBefore(cutoff)).toList();
    },
    orElse: () => [],
  );
});

