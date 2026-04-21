import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/calorie_savings_record.dart';
import '../../models/daily_summary.dart';
import '../../providers/providers.dart';
import 'onboarding_start_date_provider.dart';
import 'realtime_calories_provider.dart';
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

/// Ordered list of [DailySummary] from onboarding start through today.
/// Shared by [calorieSavingsDataProvider] and the diagnosis layer.
final dailySummariesProvider = FutureProvider<List<DailySummary>>((ref) async {
  final mealRecordsAsync = ref.watch(mealRecordsProvider);
  final startDate = ref.watch(onboardingStartDateProvider);
  if (startDate == null) return [];
  if (!mealRecordsAsync.hasValue) return [];

  final service = ref.watch(dailySummaryServiceProvider);
  final dataService = ref.read(dailySummaryDataServiceProvider);
  final endDate = DateTime.now();
  final today = DateTime(endDate.year, endDate.month, endDate.day);
  final summaries = <DailySummary>[];
  var current = DateTime(startDate.year, startDate.month, startDate.day);

  final staleDays = <DateTime>[];

  while (!current.isAfter(endDate)) {
    final cached = dataService.getSummary(current);
    final isToday = current.year == today.year &&
        current.month == today.month &&
        current.day == today.day;
    if (cached != null && !isToday) {
      final meals = service.mealRecords.getMealRecordsForDate(current);
      final currentConsumed =
          meals.fold<double>(0.0, (sum, m) => sum + m.calories);
      if ((cached.caloriesConsumed - currentConsumed).abs() < 1.0) {
        summaries.add(cached);
      } else {
        staleDays.add(DateTime(current.year, current.month, current.day));
      }
    } else {
      staleDays.add(DateTime(current.year, current.month, current.day));
    }
    current = current.add(const Duration(days: 1));
  }

  for (final day in staleDays) {
    final summary = await service.getDailySummary(day, forceRefresh: true);
    summaries.add(summary);
  }

  summaries.sort((a, b) => a.date.compareTo(b.date));
  return summaries;
});

// Provider for calorie savings data
final calorieSavingsDataProvider = FutureProvider<List<CalorieSavingsRecord>>((
  ref,
) async {
  final summariesAsync = await ref.watch(dailySummariesProvider.future);
  final summaries = summariesAsync;

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
