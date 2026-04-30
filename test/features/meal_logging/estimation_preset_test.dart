import 'package:flutter_test/flutter_test.dart';
import 'package:tonton/features/meal_logging/estimation_preset.dart';
import 'package:tonton/models/pfc_breakdown.dart';

void main() {
  const ratio = PfcRatio(protein: 0.3, fat: 0.2, carbohydrate: 0.5);

  test('usual preset returns baselineKcal as-is', () {
    final p = buildEstimationPreset(
      level: EstimationLevel.usual,
      baselineKcal: 2000,
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

  test('lessThanUsual preset scales by 0.8', () {
    final p = buildEstimationPreset(
      level: EstimationLevel.lessThanUsual,
      baselineKcal: 2000,
      pfcRatio: ratio,
    );
    expect(p.calories, closeTo(1600, 0.01));
  });

  test('moreThanUsual preset scales by 1.2', () {
    final p = buildEstimationPreset(
      level: EstimationLevel.moreThanUsual,
      baselineKcal: 2000,
      pfcRatio: ratio,
    );
    expect(p.calories, closeTo(2400, 0.01));
  });

  test('labels are 食べてない方 / いつも通り / 食べすぎた', () {
    expect(EstimationLevel.lessThanUsual.label, '食べてない方');
    expect(EstimationLevel.usual.label, 'いつも通り');
    expect(EstimationLevel.moreThanUsual.label, '食べすぎた');
  });

  test('multipliers are 0.8 / 1.0 / 1.2 (±20%)', () {
    expect(EstimationLevel.lessThanUsual.multiplier, 0.8);
    expect(EstimationLevel.usual.multiplier, 1.0);
    expect(EstimationLevel.moreThanUsual.multiplier, 1.2);
  });
}
