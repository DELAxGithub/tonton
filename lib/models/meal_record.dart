import 'package:hive/hive.dart'; // Added
import 'package:uuid/uuid.dart';
import '../enums/meal_time_type.dart';

part 'meal_record.g.dart'; // Added

/// Model class representing a meal record
@HiveType(typeId: 2) // Added
class MealRecord {
  /// Unique identifier for the meal record
  @HiveField(0) // Added
  final String id;

  /// Name of the meal
  @HiveField(1) // Added
  final String mealName;

  /// Description or notes about the meal
  @HiveField(2) // Added
  final String description;

  /// Total calories in the meal (kcal)
  @HiveField(3) // Added
  final double calories;

  /// Protein content in grams
  @HiveField(4) // Added
  final double protein;

  /// Fat content in grams
  @HiveField(5) // Added
  final double fat;

  /// Carbohydrate content in grams
  @HiveField(6) // Added
  final double carbs;

  /// Type of meal (breakfast, lunch, dinner, snack)
  @HiveField(7) // Added
  final MealTimeType mealTimeType;

  /// Date and time when the meal was consumed
  @HiveField(8) // Added
  final DateTime consumedAt;

  /// Date when the record was created
  @HiveField(9) // Added
  final DateTime createdAt;

  /// Date when the record was last updated
  @HiveField(10) // Added
  final DateTime updatedAt;

  /// Constructor for creating a new MealRecord
  MealRecord({
    String? id,
    required this.mealName,
    this.description = '',
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.mealTimeType,
    DateTime? consumedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       consumedAt = consumedAt ?? DateTime.now(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Creates a copy of this MealRecord with the given fields replaced with the new values
  MealRecord copyWith({
    String? id,
    String? mealName,
    String? description,
    double? calories,
    double? protein,
    double? fat,
    double? carbs,
    MealTimeType? mealTimeType,
    DateTime? consumedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MealRecord(
      id: id ?? this.id,
      mealName: mealName ?? this.mealName,
      description: description ?? this.description,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      carbs: carbs ?? this.carbs,
      mealTimeType: mealTimeType ?? this.mealTimeType,
      consumedAt: consumedAt ?? this.consumedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Converts this MealRecord to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mealName': mealName,
      'description': description,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
      'mealTimeType': mealTimeType.name,
      'consumedAt': consumedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Creates a MealRecord from a JSON map
  factory MealRecord.fromJson(Map<String, dynamic> json) {
    return MealRecord(
      id: json['id'] as String,
      mealName: json['mealName'] as String,
      description: json['description'] as String? ?? '',
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      mealTimeType: MealTimeType.fromString(json['mealTimeType'] as String),
      consumedAt: DateTime.parse(json['consumedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Returns a string representation of this MealRecord, useful for debugging
  @override
  String toString() {
    return 'MealRecord{id: $id, mealName: $mealName, calories: $calories, protein: $protein, fat: $fat, carbs: $carbs, mealTimeType: $mealTimeType, consumedAt: $consumedAt}';
  }
}
