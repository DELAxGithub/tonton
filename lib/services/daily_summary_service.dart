import '../models/daily_summary.dart';
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

  Future<DailySummary> getDailySummary(DateTime date) async {
    final normalized = DateTime(date.year, date.month, date.day);

    // Return cached summary if available
    final cached = dataService.getSummary(normalized);
    if (cached != null) return cached;

    final meals = mealRecords.getMealRecordsForDate(normalized);
    final consumed = meals.fold(0.0, (sum, m) => sum + m.calories);

    final activity = await healthService.getActivitySummary(normalized);
    final weight = await healthService.getLatestWeight(normalized);
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
