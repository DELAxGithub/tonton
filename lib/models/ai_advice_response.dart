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
  
  Map<String, dynamic> toJson() {
    return {
      'menuName': menuName,
      'description': description,
      'estimatedNutrition': {
        'calories': estimatedNutrition.calories,
        'protein': estimatedNutrition.protein,
        'fat': estimatedNutrition.fat,
        'carbohydrates': estimatedNutrition.carbohydrates,
      },
      'recommendationReason': recommendationReason,
    };
  }
}

class TodaysSummary {
  final double consumedCalories;
  final double targetCalories;
  final Map<String, String> balanceStatus;

  TodaysSummary({
    required this.consumedCalories,
    required this.targetCalories,
    required this.balanceStatus,
  });

  factory TodaysSummary.fromJson(Map<String, dynamic> json) {
    return TodaysSummary(
      consumedCalories: (json['consumedCalories'] as num).toDouble(),
      targetCalories: (json['targetCalories'] as num).toDouble(),
      balanceStatus: Map<String, String>.from(json['balanceStatus'] as Map),
    );
  }
}

class AiAdviceResponse {
  final String adviceMessage;
  final double? remainingCaloriesForLastMeal; // Nullable if not applicable
  final PfcBreakdown? calculatedTargetPfcForLastMeal; // Nullable
  final MenuSuggestion? menuSuggestion; // A single suggestion
  final bool calorieGoalMetOrExceeded;
  
  // 拡張プロパティ（新しいAI機能用）
  final List<String>? suggestions;
  final String? warning;
  final TodaysSummary? todaysSummary;
  final String? rationaleExplanation;
  final String? tontonAdvice;
  final String? specialDayTheme;
  final bool? isHaruMode;
  final String? currentSavings;
  final String? savingsStatus;
  
  // adviceMessageのエイリアス
  String get advice => adviceMessage;

  AiAdviceResponse({
    required this.adviceMessage,
    this.remainingCaloriesForLastMeal,
    this.calculatedTargetPfcForLastMeal,
    this.menuSuggestion,
    this.calorieGoalMetOrExceeded = false,
    this.suggestions,
    this.warning,
    this.todaysSummary,
    this.rationaleExplanation,
    this.tontonAdvice,
    this.specialDayTheme,
    this.isHaruMode,
    this.currentSavings,
    this.savingsStatus,
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
      suggestions: json['suggestions'] != null 
          ? List<String>.from(json['suggestions'])
          : null,
      warning: json['warning'] as String?,
      todaysSummary: json['todaysSummary'] != null
          ? TodaysSummary.fromJson(json['todaysSummary'] as Map<String, dynamic>)
          : null,
      rationaleExplanation: json['rationaleExplanation'] as String?,
      tontonAdvice: json['tontonAdvice'] as String?,
      specialDayTheme: json['specialDayTheme'] as String?,
      isHaruMode: json['isHaruMode'] as bool?,
      currentSavings: json['currentSavings'] as String?,
      savingsStatus: json['savingsStatus'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'advice': adviceMessage,
      'adviceMessage': adviceMessage, // for compatibility
      'remainingCaloriesForLastMeal': remainingCaloriesForLastMeal,
      'calculatedTargetPfcForLastMeal': calculatedTargetPfcForLastMeal?.toJson(),
      'menuSuggestion': menuSuggestion?.toJson(),
      'calorieGoalMetOrExceeded': calorieGoalMetOrExceeded,
      // 新しいプロパティ（拡張版）
      'suggestions': menuSuggestion != null ? [menuSuggestion!.menuName] : [],
      'warning': null,
    };
  }
}
