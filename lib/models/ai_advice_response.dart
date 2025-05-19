import 'pfc_breakdown.dart';

class EstimatedNutrition {
  final double calories;
  final double protein;
  final double fat;
  final double carbohydrates;

  EstimatedNutrition({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbohydrates,
  });

  factory EstimatedNutrition.fromJson(Map<String, dynamic> json) {
    return EstimatedNutrition(
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      carbohydrates: (json['carbohydrates'] as num).toDouble(),
    );
  }
}

class MenuSuggestion {
  final String menuName;
  final String description;
  final EstimatedNutrition estimatedNutrition;
  final String recommendationReason;

  MenuSuggestion({
    required this.menuName,
    required this.description,
    required this.estimatedNutrition,
    required this.recommendationReason,
  });

  factory MenuSuggestion.fromJson(Map<String, dynamic> json) {
    return MenuSuggestion(
      menuName: json['menuName'] as String,
      description: json['description'] as String,
      estimatedNutrition:
          EstimatedNutrition.fromJson(json['estimatedNutrition'] as Map<String, dynamic>),
      recommendationReason: json['recommendationReason'] as String,
    );
  }
}

class AiAdviceResponse {
  final String adviceMessage;
  final double? remainingCaloriesForLastMeal; // Nullable if not applicable
  final PfcBreakdown? calculatedTargetPfcForLastMeal; // Nullable
  final MenuSuggestion? menuSuggestion; // A single suggestion
  final bool calorieGoalMetOrExceeded;

  AiAdviceResponse({
    required this.adviceMessage,
    this.remainingCaloriesForLastMeal,
    this.calculatedTargetPfcForLastMeal,
    this.menuSuggestion,
    this.calorieGoalMetOrExceeded = false,
  });

  factory AiAdviceResponse.fromJson(Map<String, dynamic> json) {
    // Handle the case where calorie goal is met
    if (json['menuSuggestions'] != null && (json['menuSuggestions'] as List).isEmpty) {
      return AiAdviceResponse(
        adviceMessage: json['advice'] as String,
        remainingCaloriesForLastMeal: (json['remainingCalories'] as num?)?.toDouble(),
        calorieGoalMetOrExceeded: true,
      );
    }
    
    // Handle the regular advice case
    return AiAdviceResponse(
      adviceMessage: json['advice'] as String,
      remainingCaloriesForLastMeal: double.tryParse(json['remainingCaloriesForLastMeal']?.toString() ?? ''),
      calculatedTargetPfcForLastMeal: json['calculatedTargetPfcForLastMeal'] != null
          ? PfcBreakdown.fromJson(
              // The edge function sends PFC as strings, convert them
              Map<String, dynamic>.from(json['calculatedTargetPfcForLastMeal'] as Map).map(
                (key, value) => MapEntry(key, double.tryParse(value.toString()) ?? 0.0),
              ),
            )
          : null,
      menuSuggestion: json['menuSuggestion'] != null
          ? MenuSuggestion.fromJson(json['menuSuggestion'] as Map<String, dynamic>)
          : null,
    );
  }
}
