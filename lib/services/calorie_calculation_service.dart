import 'dart:developer' as developer;
import '../models/daily_calorie_summary.dart';
import '../models/monthly_progress_summary.dart';
import '../services/health_service.dart';
import '../providers/meal_records_provider.dart';

class CalorieCalculationService {
  final HealthService healthService;
  final MealRecords mealRecordsProvider;
  
  CalorieCalculationService({
    required this.healthService,
    required this.mealRecordsProvider,
  });

  /// Calculate daily calorie summary for a specific date
  Future<DailyCalorieSummary> calculateDailyCalorieSummary(DateTime date) async {
    developer.log('Calculating daily calorie summary for date: $date', name: 'TonTon.CalorieCalculationService');
    
    // Normalize date to remove time component
    final normalizedDate = DateTime(date.year, date.month, date.day);
    
    // Get total calories consumed from meals
    final meals = mealRecordsProvider.getMealRecordsForDate(normalizedDate);
    final totalCaloriesConsumed = meals.fold(0.0, (sum, meal) => sum + meal.calories);
    
    // Get total calories burned and workout calories from HealthKit
    final activitySummary = await healthService.getActivitySummary(normalizedDate);
    final totalCaloriesBurned = activitySummary.totalCalories;
    final workoutCalories = activitySummary.workoutCalories;
    
    developer.log(
      'Daily summary: consumed=$totalCaloriesConsumed, totalBurned=$totalCaloriesBurned, workout=$workoutCalories',
      name: 'TonTon.CalorieCalculationService'
    );
    
    return DailyCalorieSummary(
      date: normalizedDate,
      totalCaloriesConsumed: totalCaloriesConsumed,
      totalCaloriesBurned: totalCaloriesBurned,
      workoutCalories: workoutCalories,
    );
  }
  
  /// Calculate monthly progress summary for the current month
  Future<MonthlyProgressSummary> calculateMonthlyProgressSummary({
    required double targetMonthlyNetBurn,
  }) async {
    developer.log(
      'Calculating monthly progress with target: $targetMonthlyNetBurn', 
      name: 'TonTon.CalorieCalculationService'
    );
    
    // Get current date and determine month boundaries
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0); // Last day of current month
    
    // Calculate days elapsed and remaining
    final daysElapsedInMonth = now.day;
    final remainingDaysInMonth = lastDayOfMonth.day - now.day;
    
    // Calculate current monthly net burn
    double currentMonthlyNetBurn = 0;
    
    // Process each day from the first of the month to today
    for (int day = 1; day <= daysElapsedInMonth; day++) {
      final date = DateTime(now.year, now.month, day);
      final dailySummary = await calculateDailyCalorieSummary(date);
      currentMonthlyNetBurn += dailySummary.netCalories;
      
      developer.log(
        'Day $day: net=${dailySummary.netCalories}, monthly total so far=$currentMonthlyNetBurn',
        name: 'TonTon.CalorieCalculationService'
      );
    }
    
    final summary = MonthlyProgressSummary(
      targetMonthlyNetBurn: targetMonthlyNetBurn,
      currentMonthlyNetBurn: currentMonthlyNetBurn,
      daysElapsedInMonth: daysElapsedInMonth,
      remainingDaysInMonth: remainingDaysInMonth,
    );
    
    developer.log(
      'Monthly summary: ${summary.toString()}',
      name: 'TonTon.CalorieCalculationService'
    );
    
    return summary;
  }
}