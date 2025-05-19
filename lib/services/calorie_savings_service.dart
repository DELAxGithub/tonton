import '../models/calorie_savings_record.dart';
import '../models/dummy_data_scenario.dart';

/// Service responsible for generating calorie savings data for different
/// scenarios used in the demo screens.
class CalorieSavingsService {
  /// Generate a list of [CalorieSavingsRecord] for the given [scenario].
  List<CalorieSavingsRecord> generateData(DummyDataScenario scenario) {
    switch (scenario) {
      case DummyDataScenario.steadyGrowth:
        return _generateSteadyGrowthData();
      case DummyDataScenario.fluctuating:
        return _generateFluctuatingData();
      case DummyDataScenario.declining:
        return _generateDecliningData();
    }
  }

  /// Generate steady growth data (positive trend)
  List<CalorieSavingsRecord> _generateSteadyGrowthData() {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;
    final daysInMonth = DateTime(currentYear, currentMonth + 1, 0).day;

    final records = <CalorieSavingsRecord>[];
    double cumulativeSavings = 0;

    for (int day = 1; day <= _min(now.day, daysInMonth); day++) {
      final date = DateTime(currentYear, currentMonth, day);
      final caloriesBurned = (2000 + (day * 10)).toDouble();
      final caloriesConsumed = (1500 + (day % 3) * 100).toDouble();

      final record = CalorieSavingsRecord.fromRaw(
        date: date,
        caloriesConsumed: caloriesConsumed,
        caloriesBurned: caloriesBurned,
        previousCumulativeSavings: cumulativeSavings,
      );

      records.add(record);
      cumulativeSavings = record.cumulativeSavings;
    }

    return records;
  }

  /// Generate fluctuating data (mixed positive and negative)
  List<CalorieSavingsRecord> _generateFluctuatingData() {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;
    final daysInMonth = DateTime(currentYear, currentMonth + 1, 0).day;

    final records = <CalorieSavingsRecord>[];
    double cumulativeSavings = 0;

    for (int day = 1; day <= _min(now.day, daysInMonth); day++) {
      final date = DateTime(currentYear, currentMonth, day);
      final modifier = day % 3 == 0 ? -300.0 : 200.0;
      final caloriesBurned = (1800 + (day % 5) * 100).toDouble();
      final caloriesConsumed = (1700 + (day % 7) * 100).toDouble() + modifier;

      final record = CalorieSavingsRecord.fromRaw(
        date: date,
        caloriesConsumed: caloriesConsumed,
        caloriesBurned: caloriesBurned,
        previousCumulativeSavings: cumulativeSavings,
      );

      records.add(record);
      cumulativeSavings = record.cumulativeSavings;
    }

    return records;
  }

  /// Generate declining data (negative trend)
  List<CalorieSavingsRecord> _generateDecliningData() {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;
    final daysInMonth = DateTime(currentYear, currentMonth + 1, 0).day;

    final records = <CalorieSavingsRecord>[];
    double cumulativeSavings = 5000;

    for (int day = 1; day <= _min(now.day, daysInMonth); day++) {
      final date = DateTime(currentYear, currentMonth, day);
      final caloriesBurned = (2200 - (day * 15)).toDouble();
      final caloriesConsumed = (1500 + (day * 20)).toDouble();

      final record = CalorieSavingsRecord.fromRaw(
        date: date,
        caloriesConsumed: caloriesConsumed,
        caloriesBurned: caloriesBurned,
        previousCumulativeSavings: cumulativeSavings,
      );

      records.add(record);
      cumulativeSavings = record.cumulativeSavings;
    }

    return records;
  }

  int _min(int a, int b) => a < b ? a : b;
}
