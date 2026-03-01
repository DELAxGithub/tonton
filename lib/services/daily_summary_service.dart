import '../models/activity_summary.dart';
import '../models/daily_summary.dart';
import '../models/weight_record.dart';
import '../providers/providers.dart';
import 'health_service.dart';
import 'daily_summary_data_service.dart';

class DailySummaryService {
  final HealthService healthService;
  final MealRecords mealRecords;
  final DailySummaryDataService dataService;

  DailySummaryService({
    required this.healthService,
    required this.mealRecords,
    required this.dataService,
  });

  Future<DailySummary> getDailySummary(DateTime date, {bool forceRefresh = false}) async {
    final normalized = DateTime(date.year, date.month, date.day);

    // Return cached summary only when not forcing a refresh
    if (!forceRefresh) {
      final cached = dataService.getSummary(normalized);
      if (cached != null) return cached;
    }

    // Get meals for this date
    final meals = mealRecords.getMealRecordsForDate(normalized);
    final consumed = meals.fold<double>(0.0, (sum, m) => sum + m.calories);

    // Fetch HealthKit data in parallel
    final results = await Future.wait([
      healthService.getActivitySummary(normalized),
      healthService.getLatestWeight(normalized),
    ]);
    final activity = results[0] as ActivitySummary;
    final weight = results[1] as WeightRecord?;
    final summary = DailySummary(
      date: normalized,
      caloriesConsumed: consumed,
      caloriesBurned: activity.totalCalories,
      weight: weight?.weight,
      bodyFatPercentage:
          weight?.bodyFatPercentage ?? activity.bodyFatPercentage,
    );
    await dataService.saveSummary(summary);
    return summary;
  }
}
