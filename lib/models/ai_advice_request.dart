import 'pfc_breakdown.dart';

class AiAdviceRequest {
  final double targetCalories;
  final PfcRatio targetPfcRatio;
  final PfcBreakdown consumedMealsPfc;
  final double activeCalories;
  final String lang;

  AiAdviceRequest({
    required this.targetCalories,
    required this.targetPfcRatio,
    required this.consumedMealsPfc,
    required this.activeCalories,
    this.lang = 'en',
  });

  Map<String, dynamic> toJson() => {
    'targetCalories': targetCalories,
    'targetPfcRatio': targetPfcRatio.toJson(),
    'consumedMealsPfc': consumedMealsPfc.toJson(),
    'activeCalories': activeCalories,
    'lang': lang,
  };
}
