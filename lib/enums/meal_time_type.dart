import 'package:hive/hive.dart'; // Added

part 'meal_time_type.g.dart'; // Added

/// Enum representing different meal times of the day
@HiveType(typeId: 1) // Added
enum MealTimeType {
  @HiveField(0) // Added
  breakfast,
  @HiveField(1) // Added
  lunch,
  @HiveField(2) // Added
  dinner,
  @HiveField(3) // Added
  snack;

  /// Returns a human-readable name for the meal type
  String get displayName {
    switch (this) {
      case MealTimeType.breakfast:
        return 'Breakfast';
      case MealTimeType.lunch:
        return 'Lunch';
      case MealTimeType.dinner:
        return 'Dinner';
      case MealTimeType.snack:
        return 'Snack';
    }
  }

  /// Converts a string value to the corresponding MealTimeType
  static MealTimeType fromString(String value) {
    return MealTimeType.values.firstWhere(
      (type) => type.name.toLowerCase() == value.toLowerCase(),
      orElse: () => MealTimeType.snack,
    );
  }
}
