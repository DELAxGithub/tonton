class DailySummary {
  final DateTime date;
  final double caloriesConsumed;
  final double caloriesBurned;
  final double? weight;
  final double? bodyFatPercentage;

  const DailySummary({
    required this.date,
    required this.caloriesConsumed,
    required this.caloriesBurned,
    this.weight,
    this.bodyFatPercentage,
  });

  double get netCalories => caloriesBurned - caloriesConsumed;

  @override
  String toString() {
    final dateStr = date.toIso8601String().split('T')[0];
    return 'DailySummary(date: $dateStr, consumed: $caloriesConsumed, burned: $caloriesBurned, weight: $weight, bodyFat: $bodyFatPercentage)';
  }
}
