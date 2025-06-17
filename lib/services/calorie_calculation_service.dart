import 'dart:developer' as developer;
import '../models/daily_calorie_summary.dart';
import '../models/monthly_progress_summary.dart';
import '../services/health_service.dart';
import '../providers/providers.dart';

class CalorieCalculationService {
  final HealthService healthService;
  final MealRecords mealRecordsProvider;

  CalorieCalculationService({
    required this.healthService,
    required this.mealRecordsProvider,
  });

  /// Calculate daily calorie summary for a specific date
  Future<DailyCalorieSummary> calculateDailyCalorieSummary(
    DateTime date,
  ) async {
    developer.log(
      'Calculating daily calorie summary for date: $date',
      name: 'TonTon.CalorieCalculationService',
    );

    // Normalize date to remove time component
    final normalizedDate = DateTime(date.year, date.month, date.day);

    // Get total calories consumed from meals
    final meals = mealRecordsProvider.getMealRecordsForDate(normalizedDate);
    final totalCaloriesConsumed = meals.fold(
      0.0,
      (sum, meal) => sum + meal.calories,
    );

    // Get total calories burned and workout calories from HealthKit
    final activitySummary = await healthService.getActivitySummary(
      normalizedDate,
    );
    final totalCaloriesBurned = activitySummary.totalCalories;
    final workoutCalories = activitySummary.workoutCalories;

    developer.log(
      'Daily summary: consumed=$totalCaloriesConsumed, totalBurned=$totalCaloriesBurned, workout=$workoutCalories',
      name: 'TonTon.CalorieCalculationService',
    );

    return DailyCalorieSummary(
      date: normalizedDate,
      totalCaloriesConsumed: totalCaloriesConsumed,
      totalCaloriesBurned: totalCaloriesBurned,
      workoutCalories: workoutCalories,
    );
  }

  /// Calculate monthly progress summary from onboarding start date
  Future<MonthlyProgressSummary> calculateMonthlyProgressSummary({
    required double targetMonthlyNetBurn,
    required DateTime startDate,
  }) async {
    developer.log(
      'Calculating monthly progress with target: $targetMonthlyNetBurn, startDate: $startDate',
      name: 'TonTon.CalorieCalculationService',
    );

    // Get current date
    final now = DateTime.now();
    final normalizedNow = DateTime(now.year, now.month, now.day);
    final normalizedStartDate = DateTime(startDate.year, startDate.month, startDate.day);
    
    // Calculate days elapsed since start date
    final totalDaysElapsed = normalizedNow.difference(normalizedStartDate).inDays + 1;
    
    // For display purposes, calculate remaining days in current month
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final remainingDaysInMonth = lastDayOfMonth.day - now.day;

    // Calculate current cumulative net burn from start date to today
    double currentCumulativeNetBurn = 0;

    // Process each day from start date to today
    for (int dayOffset = 0; dayOffset < totalDaysElapsed; dayOffset++) {
      final date = normalizedStartDate.add(Duration(days: dayOffset));
      if (date.isAfter(normalizedNow)) break;
      
      final dailySummary = await calculateDailyCalorieSummary(date);
      currentCumulativeNetBurn += dailySummary.netCalories;

      developer.log(
        'Day ${date.toIso8601String().split('T')[0]}: net=${dailySummary.netCalories}, cumulative total=$currentCumulativeNetBurn',
        name: 'TonTon.CalorieCalculationService',
      );
    }

    final summary = MonthlyProgressSummary(
      targetMonthlyNetBurn: targetMonthlyNetBurn,
      currentMonthlyNetBurn: currentCumulativeNetBurn,
      daysElapsedInMonth: totalDaysElapsed,
      remainingDaysInMonth: remainingDaysInMonth,
    );

    developer.log(
      'Monthly summary: ${summary.toString()}',
      name: 'TonTon.CalorieCalculationService',
    );

    return summary;
  }
}
