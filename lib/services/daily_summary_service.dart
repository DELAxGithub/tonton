import '../models/daily_summary.dart';
import '../providers/meal_records_provider.dart';
import 'health_service.dart';

class DailySummaryService {
  final HealthService healthService;
  final MealRecords mealRecords;

  DailySummaryService({
    required this.healthService,
    required this.mealRecords,
  });

  Future<DailySummary> getDailySummary(DateTime date) async {
    final normalized = DateTime(date.year, date.month, date.day);

    final meals = mealRecords.getMealRecordsForDate(normalized);
    final consumed = meals.fold(0.0, (sum, m) => sum + m.calories);

    final activity = await healthService.getActivitySummary(normalized);
    final weight = await healthService.getLatestWeight(normalized);

    return DailySummary(
      date: normalized,
      caloriesConsumed: consumed,
      caloriesBurned: activity.totalCalories,
      weight: weight?.weight,
      bodyFatPercentage:
          weight?.bodyFatPercentage ?? activity.bodyFatPercentage,
    );
  }
}
