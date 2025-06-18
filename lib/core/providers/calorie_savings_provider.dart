import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/calorie_savings_record.dart';
import 'onboarding_start_date_provider.dart';
import 'monthly_progress_provider.dart';
import '../../features/meal_logging/providers/meal_records_provider.dart';
import '../../features/progress/providers/selected_period_provider.dart';

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
      (ref) => MonthlyCalorieGoalNotifier(),
    );

// Provider for calorie savings data
final calorieSavingsDataProvider = FutureProvider<List<CalorieSavingsRecord>>((
  ref,
) async {
  // Watch meal records so savings data updates when meals change.
  final mealRecordsAsync = ref.watch(mealRecordsProvider);
  final startDate = ref.watch(onboardingStartDateProvider);
  if (startDate == null) return [];

  // Only proceed if meal records are loaded
  if (!mealRecordsAsync.hasValue) return [];

  final mealRecords = mealRecordsAsync.value!.records;
  final healthService = ref.watch(healthServiceProvider);
  final endDate = DateTime.now();
  final records = <CalorieSavingsRecord>[];
  var current = DateTime(startDate.year, startDate.month, startDate.day);

  double runningTotal = 0;
  while (!current.isAfter(endDate)) {
    // Calculate consumed calories directly from meal records
    final consumed = mealRecords.where((record) {
      final recordDate = record.consumedAt.toLocal();
      return recordDate.year == current.year &&
          recordDate.month == current.month &&
          recordDate.day == current.day;
    }).fold<double>(0.0, (sum, record) => sum + record.calories);

    // Get activity data
    final activity = await healthService.getActivitySummary(current);
    
    final daily = activity.totalCalories - consumed;
    runningTotal += daily;
    
    records.add(CalorieSavingsRecord(
      date: current,
      caloriesConsumed: consumed,
      caloriesBurned: activity.totalCalories,
      dailyBalance: daily,
      cumulativeSavings: runningTotal,
    ));
    
    current = current.add(const Duration(days: 1));
  }

  return records;
});

/// Filtered calorie savings records based on the selected period.
final filteredCalorieSavingsProvider = Provider<List<CalorieSavingsRecord>>((
  ref,
) {
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
