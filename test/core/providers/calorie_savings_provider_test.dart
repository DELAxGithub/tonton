import 'package:flutter_test/flutter_test.dart';
import 'package:tonton/core/providers/calorie_savings_provider.dart';
import 'package:tonton/models/daily_summary.dart';

DailySummary _summary(
  DateTime date, {
  required double consumed,
  required double burned,
}) {
  return DailySummary(
    date: date,
    caloriesConsumed: consumed,
    caloriesBurned: burned,
  );
}

void main() {
  group('buildMonthlyCalorieSavingsRecords', () {
    test('resets cumulative savings at the first day of a new month', () {
      final records = buildMonthlyCalorieSavingsRecords([
        _summary(DateTime(2026, 5, 30), consumed: 1800, burned: 2200),
        _summary(DateTime(2026, 5, 31), consumed: 2100, burned: 2300),
        _summary(DateTime(2026, 6, 1), consumed: 2000, burned: 2500),
        _summary(DateTime(2026, 6, 2), consumed: 2600, burned: 2200),
      ]);

      expect(records.map((r) => r.dailyBalance), [400, 200, 500, -400]);
      expect(records.map((r) => r.cumulativeSavings), [400, 600, 500, 100]);
    });

    test('keeps accumulating within the same month with mixed balances', () {
      final records = buildMonthlyCalorieSavingsRecords([
        _summary(DateTime(2026, 6, 1), consumed: 1800, burned: 2300),
        _summary(DateTime(2026, 6, 2), consumed: 2400, burned: 2100),
        _summary(DateTime(2026, 6, 3), consumed: 1900, burned: 2400),
      ]);

      expect(records.map((r) => r.cumulativeSavings), [500, 200, 700]);
    });
  });
}
