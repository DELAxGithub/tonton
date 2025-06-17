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

    // Get meals using direct state access to avoid async state issues
    final meals = mealRecords.getMealRecordsForDate(normalized);

    // Also try to get all meals and filter manually as a backup
    List<dynamic> allMeals = [];
    try {
      final state = mealRecords.state;
      if (state.hasValue) {
        allMeals =
            state.value!.records.where((record) {
              final consumed = record.consumedAt.toLocal();
              return consumed.year == normalized.year &&
                  consumed.month == normalized.month &&
                  consumed.day == normalized.day;
            }).toList();
      }
    } catch (e) {
      // Silently handle state access errors
    }

    // Use the manual filtering if provider method returns no meals but manual does
    final effectiveMeals =
        meals.isEmpty && allMeals.isNotEmpty ? allMeals : meals;
    final consumed = effectiveMeals.fold<double>(
      0.0,
      (sum, m) => sum + m.calories,
    );

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
