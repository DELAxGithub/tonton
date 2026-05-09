import 'package:flutter_test/flutter_test.dart';

import 'package:tonton/features/savings/models/dietary_pattern.dart';
import 'package:tonton/features/savings/services/pattern_matching_service.dart';
import 'package:tonton/models/calorie_savings_record.dart';
import 'package:tonton/models/weight_record.dart';

WeightRecord _w(DateTime d, double kg) => WeightRecord(date: d, weight: kg);

List<CalorieSavingsRecord> _genRecords({
  required DateTime start,
  required int days,
  required double dailyKcalDeficit, // positive = saving (burned > consumed)
}) {
  final out = <CalorieSavingsRecord>[];
  double cumulative = 0;
  for (int i = 0; i < days; i++) {
    cumulative += dailyKcalDeficit;
    out.add(
      CalorieSavingsRecord(
        date: start.add(Duration(days: i)),
        caloriesConsumed: 1800,
        caloriesBurned: 1800 + dailyKcalDeficit,
        dailyBalance: dailyKcalDeficit,
        cumulativeSavings: cumulative,
      ),
    );
  }
  return out;
}

void main() {
  group('PatternMatchingService.classify', () {
    final start = DateTime(2026, 4, 9);
    const startWeight = 68.5;

    test('returns low confidence when records < 7 days', () {
      final records = _genRecords(
        start: start,
        days: 5,
        dailyKcalDeficit: 500,
      );
      final result = PatternMatchingService.classify(
        records: records,
        weightRecords: List.filled(records.length, null),
        idealKgList: List.filled(records.length, null),
        startingBodyWeightKg: startWeight,
      );
      expect(result.similarity, 0.0);
    });

    test('returns smooth pattern when 3 lines align', () {
      // 30 days, daily deficit 500 kcal → cumulative -15000 → -1.95kg theory
      final records = _genRecords(
        start: start,
        days: 30,
        dailyKcalDeficit: 500,
      );
      // Actual closely tracks theory.
      final weights = <WeightRecord?>[];
      for (int i = 0; i < 30; i++) {
        weights.add(_w(records[i].date, startWeight - (i / 30 * 1.95)));
      }
      // Plan also tracks similarly.
      final plan = <double?>[
        for (int i = 0; i < 30; i++) startWeight - (i / 30 * 1.95),
      ];
      final result = PatternMatchingService.classify(
        records: records,
        weightRecords: weights,
        idealKgList: plan,
        startingBodyWeightKg: startWeight,
      );
      expect(result.patternId, DietaryPatternId.smooth);
      expect(result.similarity, greaterThan(0.5));
    });

    test('returns body stall when theory drops but actual flatlines', () {
      final records = _genRecords(
        start: start,
        days: 30,
        dailyKcalDeficit: 500,
      );
      // Actual essentially flat (small noise).
      final weights = <WeightRecord?>[
        for (int i = 0; i < 30; i++)
          _w(records[i].date, startWeight - 0.1 + (i % 3) * 0.05),
      ];
      final plan = <double?>[
        for (int i = 0; i < 30; i++) startWeight - (i / 30 * 1.95),
      ];
      final result = PatternMatchingService.classify(
        records: records,
        weightRecords: weights,
        idealKgList: plan,
        startingBodyWeightKg: startWeight,
      );
      expect(result.patternId, DietaryPatternId.bodyStall);
    });

    test('returns rebound when theory and actual both go up', () {
      // 30 days, daily SURPLUS (deficit = -300, ie consumed > burned by 300)
      final records = _genRecords(
        start: start,
        days: 30,
        dailyKcalDeficit: -300,
      );
      final weights = <WeightRecord?>[
        for (int i = 0; i < 30; i++) _w(records[i].date, startWeight + i * 0.04),
      ];
      final plan = <double?>[
        for (int i = 0; i < 30; i++) startWeight - (i / 30 * 1.5),
      ];
      final result = PatternMatchingService.classify(
        records: records,
        weightRecords: weights,
        idealKgList: plan,
        startingBodyWeightKg: startWeight,
      );
      expect(result.patternId, DietaryPatternId.rebound);
    });

    test(
        'regression: 7-day window, theory -0.58kg + actual +0.4kg should NOT '
        'classify as smooth (real user 1.7.1+31)', () {
      // Reproduce the screenshot: 5/3 → 5/9, daily deficit ~640 kcal,
      // weight goes 67.8 → 67.5 → 67.5 → 67.5 → 67.9 → 68.3 → 68.3.
      // Pre-fix this fell through to smooth because:
      //   - bodyStall required actualDelta.abs() < 0.3 (failed on +0.4)
      //   - saltSpike required 10+ days
      //   - zigzag detrended std was ~0.22, below 0.4 threshold
      final records = _genRecords(
        start: start,
        days: 7,
        dailyKcalDeficit: 640, // ≈ -0.58 kg theory over 7 days
      );
      final actualWeights = [67.8, 67.5, 67.5, 67.5, 67.9, 68.3, 68.3];
      final weights = <WeightRecord?>[
        for (int i = 0; i < 7; i++) _w(records[i].date, actualWeights[i]),
      ];
      final result = PatternMatchingService.classify(
        records: records,
        weightRecords: weights,
        idealKgList: List.filled(7, null), // user had no plan line
        startingBodyWeightKg: 67.8,
      );
      // Must NOT be smooth — either bodyStall or saltSpike is acceptable
      // (both indicate "actual diverging upward from theory").
      expect(result.patternId, isNot(DietaryPatternId.smooth));
      expect(
        [DietaryPatternId.bodyStall, DietaryPatternId.saltSpike],
        contains(result.patternId),
      );
    });

    test('returns initial water shed when first week drops fast then plateau',
        () {
      final records = _genRecords(
        start: start,
        days: 30,
        dailyKcalDeficit: 500,
      );
      // First 7 days drop ~1.5kg, then flat.
      final weights = <WeightRecord?>[];
      for (int i = 0; i < 30; i++) {
        if (i < 7) {
          weights.add(_w(records[i].date, startWeight - (i / 7) * 1.5));
        } else {
          weights.add(_w(records[i].date, startWeight - 1.5 - (i - 7) * 0.005));
        }
      }
      final plan = <double?>[
        for (int i = 0; i < 30; i++) startWeight - (i / 30 * 1.95),
      ];
      final result = PatternMatchingService.classify(
        records: records,
        weightRecords: weights,
        idealKgList: plan,
        startingBodyWeightKg: startWeight,
      );
      expect(result.patternId, DietaryPatternId.initialWaterShed);
    });
  });
}
