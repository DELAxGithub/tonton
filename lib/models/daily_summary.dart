import 'package:hive/hive.dart';

part 'daily_summary.g.dart';

@HiveType(typeId: 3)
class DailySummary {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final double caloriesConsumed;

  @HiveField(2)
  final double caloriesBurned;

  @HiveField(3)
  final double? weight;

  @HiveField(4)
  final double? bodyFatPercentage;

  const DailySummary({
    required this.date,
    required this.caloriesConsumed,
    required this.caloriesBurned,
    this.weight,
    this.bodyFatPercentage,
  });

  double get netCalories => caloriesBurned - caloriesConsumed;
  double get totalCaloriesBurned => caloriesBurned;

  @override
  String toString() {
    final dateStr = date.toIso8601String().split('T')[0];
    return 'DailySummary(date: $dateStr, consumed: $caloriesConsumed, burned: $caloriesBurned, weight: $weight, bodyFat: $bodyFatPercentage)';
  }
}
