import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/calorie_savings_record.dart';
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
  final records = <CalorieSavingsRecord>[];
  var current = DateTime(startDate.year, startDate.month, startDate.day);

  while (!current.isAfter(endDate)) {
    final summary = await service.getDailySummary(current);
    final previous =
        records.isNotEmpty ? records.last.cumulativeSavings : 0.0;
    records.add(CalorieSavingsRecord.fromRaw(
      date: summary.date,
      caloriesConsumed: summary.caloriesConsumed,
      caloriesBurned: summary.caloriesBurned,
      previousCumulativeSavings: previous,
    ));
    current = current.add(const Duration(days: 1));
  }

  return records;
});
