import 'nutrient_info.dart';

class EstimatedMealNutrition {
  final String mealName; // Changed from dishName
  final String description; // Added
  final double calories;
  final NutrientInfo nutrients;
  final List<String>? notes;

  EstimatedMealNutrition({
    required this.mealName,
    required this.description,
    required this.calories,
    required this.nutrients,
    this.notes,
  });

  factory EstimatedMealNutrition.fromJson(Map<String, dynamic> json) {
    // Assuming Gemini API response keys based on FINDINGS.md:
    // food_name, description, calories, protein_g, fat_g, carbs_g
    return EstimatedMealNutrition(
      mealName: json['food_name'] as String,
      description: json['description'] as String,
      calories: (json['calories'] as num).toDouble(),
      nutrients: NutrientInfo( // Directly create NutrientInfo from top-level keys
        protein: (json['protein_g'] as num).toDouble(),
        fat: (json['fat_g'] as num).toDouble(),
        carbs: (json['carbs_g'] as num).toDouble(),
      ),
      // 'notes' is not part of the current Gemini API prompt in FINDINGS.md.
      // Handle its absence gracefully.
      notes: json.containsKey('notes') && json['notes'] != null
          ? List<String>.from(json['notes'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'mealName': mealName,
        'description': description,
        'calories': calories,
        'nutrients': nutrients.toJson(), // NutrientInfo.toJson() remains the same
        if (notes != null) 'notes': notes,
      };
}
