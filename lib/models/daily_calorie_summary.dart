class DailyCalorieSummary {
  /// The date this summary represents
  final DateTime date;

  /// Total calories consumed (from meals)
  final double totalCaloriesConsumed;

  /// Total calories burned (from HealthKit)
  final double totalCaloriesBurned;

  /// Calories burned from workouts only
  final double workoutCalories;

  /// Net calorie balance (burned - consumed)
  double get netCalories => totalCaloriesBurned - totalCaloriesConsumed;

  /// Whether this day had a calorie surplus (negative net is deficit/savings)
  bool get isCalorieSurplus => netCalories < 0;

  const DailyCalorieSummary({
    required this.date,
    required this.totalCaloriesConsumed,
    required this.totalCaloriesBurned,
    required this.workoutCalories,
  });

  @override
  String toString() {
    return 'DailyCalorieSummary(date: ${date.toIso8601String().split('T')[0]}, '
        'consumed: $totalCaloriesConsumed, burned: $totalCaloriesBurned, '
        'workout: $workoutCalories, net: $netCalories)';
  }
}
