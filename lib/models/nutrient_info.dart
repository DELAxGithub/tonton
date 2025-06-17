class NutrientInfo {
  final double protein;
  final double fat;
  final double carbs;

  NutrientInfo({required this.protein, required this.fat, required this.carbs});

  factory NutrientInfo.fromJson(Map<String, dynamic> json) {
    return NutrientInfo(
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'protein': protein,
    'fat': fat,
    'carbs': carbs,
  };
}
