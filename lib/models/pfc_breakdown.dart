class PfcBreakdown {
  final double protein;
  final double fat;
  final double carbohydrate;
  final double? calories; // Optional, as sometimes we only care about PFC grams

  PfcBreakdown({
    required this.protein,
    required this.fat,
    required this.carbohydrate,
    this.calories,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'protein': protein,
      'fat': fat,
      'carbohydrate': carbohydrate,
    };
    if (calories != null) {
      data['calories'] = calories;
    }
    return data;
  }

  factory PfcBreakdown.fromJson(Map<String, dynamic> json) {
    return PfcBreakdown(
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      carbohydrate: (json['carbohydrate'] as num).toDouble(),
      calories: (json['calories'] as num?)?.toDouble(),
    );
  }

  // Helper to calculate calories from PFC grams if not provided
  double get calculatedCalories {
    if (calories != null) return calories!;
    return (protein * 4) + (fat * 9) + (carbohydrate * 4);
  }
}

class PfcRatio {
  final double protein;
  final double fat;
  final double carbohydrate;

  const PfcRatio({
    required this.protein,
    required this.fat,
    required this.carbohydrate,
  })
      : assert(
            (protein + fat + carbohydrate) >= 0.99 &&
                (protein + fat + carbohydrate) <= 1.01,
            'PFC ratios must sum to 1.0');

  Map<String, dynamic> toJson() => {
        'protein': protein,
        'fat': fat,
        'carbohydrate': carbohydrate,
      };
  
  factory PfcRatio.fromJson(Map<String, dynamic> json) {
    return PfcRatio(
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      carbohydrate: (json['carbohydrate'] as num).toDouble(),
    );
  }
}
