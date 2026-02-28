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
        return '朝食';
      case MealTimeType.lunch:
        return '昼食';
      case MealTimeType.dinner:
        return '夕食';
      case MealTimeType.snack:
        return '間食';
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
