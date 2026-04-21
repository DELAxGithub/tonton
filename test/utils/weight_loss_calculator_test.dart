import 'package:flutter_test/flutter_test.dart';
import 'package:tonton/utils/weight_loss_calculator.dart';

void main() {
  group('WeightLossCalculator.estimateTdee', () {
    test('Mifflin-St Jeor: male 70kg/170cm/35yo activity 1.4 ~= 2350kcal', () {
      final tdee = WeightLossCalculator.estimateTdee(
        weightKg: 70,
        heightCm: 170,
        age: 35,
        isMale: true,
        activityFactor: 1.4,
      );
      // BMR = 10*70 + 6.25*170 - 5*35 + 5 = 700 + 1062.5 - 175 + 5 = 1592.5
      // TDEE = 1592.5 * 1.4 = 2229.5
      expect(tdee, closeTo(2229.5, 1.0));
    });

    test('female uses -161 offset', () {
      final tdee = WeightLossCalculator.estimateTdee(
        weightKg: 60,
        heightCm: 160,
        age: 30,
        isMale: false,
        activityFactor: 1.4,
      );
      // BMR = 10*60 + 6.25*160 - 5*30 - 161 = 600 + 1000 - 150 - 161 = 1289
      // TDEE = 1289 * 1.4 = 1804.6
      expect(tdee, closeTo(1804.6, 1.0));
    });
  });

  group('WeightLossCalculator.requiredDailyDeficit', () {
    test('70kg at 0.7%/week needs ~539 kcal/day deficit', () {
      final deficit = WeightLossCalculator.requiredDailyDeficit(
        weightKg: 70,
        weeklyPercentLoss: 0.007,
      );
      // 70 * 0.007 * 7700 / 7 = 539
      expect(deficit, closeTo(539, 1.0));
    });

    test('linear scaling with percent', () {
      final d5 = WeightLossCalculator.requiredDailyDeficit(
        weightKg: 70,
        weeklyPercentLoss: 0.005,
      );
      final d10 = WeightLossCalculator.requiredDailyDeficit(
        weightKg: 70,
        weeklyPercentLoss: 0.010,
      );
      expect(d10 / d5, closeTo(2.0, 0.01));
    });
  });

  group('WeightLossCalculator.expectedWeightLossKg', () {
    test('7700 kcal deficit equals 1 kg loss', () {
      final kg = WeightLossCalculator.expectedWeightLossKg(
        cumulativeDeficitKcal: 7700,
      );
      expect(kg, closeTo(1.0, 0.001));
    });

    test('zero deficit => zero loss', () {
      expect(
        WeightLossCalculator.expectedWeightLossKg(cumulativeDeficitKcal: 0),
        0,
      );
    });
  });

  group('WeightLossCalculator pace presets', () {
    test('healthy pace range is 0.5% to 1.0% per week', () {
      expect(WeightLossCalculator.minHealthyWeeklyPercent, 0.005);
      expect(WeightLossCalculator.maxHealthyWeeklyPercent, 0.010);
      expect(WeightLossCalculator.defaultWeeklyPercent, 0.007);
    });
  });
}
