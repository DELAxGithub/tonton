import 'pfc_breakdown.dart';

/// Aggregated PFC data for a single day, used in the weekly dashboard.
class DailyPfcSummary {
  final DateTime date;
  final PfcBreakdown pfc;
  final int mealCount;
  final int? score; // 0-100, null if no meals
  final String? grade; // A/B/C/D, null if no meals

  const DailyPfcSummary({
    required this.date,
    required this.pfc,
    required this.mealCount,
    this.score,
    this.grade,
  });

  bool get hasMeals => mealCount > 0;

  /// Day of week label in Japanese (月, 火, 水...)
  String get dayLabel {
    const labels = ['月', '火', '水', '木', '金', '土', '日'];
    return labels[date.weekday - 1];
  }

  /// Total grams (P + F + C)
  double get totalGrams => pfc.protein + pfc.fat + pfc.carbohydrate;
}
