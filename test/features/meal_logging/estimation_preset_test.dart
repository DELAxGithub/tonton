import 'package:flutter_test/flutter_test.dart';
import 'package:tonton/features/meal_logging/estimation_preset.dart';
import 'package:tonton/models/pfc_breakdown.dart';

void main() {
  const ratio = PfcRatio(protein: 0.3, fat: 0.2, carbohydrate: 0.5);

  test('normal preset returns baseDailyCalories', () {
    final p = buildEstimationPreset(
      level: EstimationLevel.normal,
      baseDailyCalories: 2000,
      pfcRatio: ratio,
    );
    expect(p.calories, 2000);
    // 2000 * 0.3 = 600 kcal protein → 150 g
    expect(p.protein, closeTo(150, 0.1));
    // 2000 * 0.2 = 400 kcal fat → 44.4 g
    expect(p.fat, closeTo(44.44, 0.1));
    // 2000 * 0.5 = 1000 kcal carbs → 250 g
    expect(p.carbs, closeTo(250, 0.1));
  });

  test('light preset scales by 0.8', () {
    final p = buildEstimationPreset(
      level: EstimationLevel.light,
      baseDailyCalories: 2000,
      pfcRatio: ratio,
    );
    expect(p.calories, closeTo(1600, 0.01));
  });

  test('heavy preset scales by 1.3', () {
    final p = buildEstimationPreset(
      level: EstimationLevel.heavy,
      baseDailyCalories: 2000,
      pfcRatio: ratio,
    );
    expect(p.calories, closeTo(2600, 0.01));
  });

  test('labels are 少なめ / 普通 / 多め', () {
    expect(EstimationLevel.light.label, '少なめ');
    expect(EstimationLevel.normal.label, '普通');
    expect(EstimationLevel.heavy.label, '多め');
  });
}
