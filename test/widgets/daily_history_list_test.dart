import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tonton/enums/meal_time_type.dart';
import 'package:tonton/features/meal_logging/providers/meal_records_provider.dart';
import 'package:tonton/models/calorie_savings_record.dart';
import 'package:tonton/models/meal_record.dart';
import 'package:tonton/widgets/daily_history_list.dart';

class _TestMealRecords extends MealRecords {
  _TestMealRecords(this._records);
  final List<MealRecord> _records;

  @override
  Future<MealRecordsState> build() async => MealRecordsState(records: _records);
}

CalorieSavingsRecord _record({
  required DateTime date,
  required double consumed,
  double burned = 1800,
}) {
  return CalorieSavingsRecord.fromRaw(
    date: date,
    caloriesConsumed: consumed,
    caloriesBurned: burned,
  );
}

MealRecord _meal({
  required String name,
  required MealTimeType type,
  required DateTime consumedAt,
}) {
  return MealRecord(
    mealName: name,
    description: '',
    calories: 400,
    protein: 20,
    fat: 10,
    carbs: 50,
    mealTimeType: type,
    consumedAt: consumedAt,
  );
}

Future<void> _pumpList(
  WidgetTester tester, {
  required List<CalorieSavingsRecord> records,
  required List<MealRecord> meals,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        mealRecordsProvider.overrideWith(() => _TestMealRecords(meals)),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: DailyHistoryList(records: records),
          ),
        ),
      ),
    ),
  );
  // Allow async build of mealRecordsProvider to settle.
  await tester.pumpAndSettle();
}

void main() {
  group('DailyHistoryList meal preview', () {
    testWidgets('shows up to 3 meal chips and +N overflow for >3 meals', (
      tester,
    ) async {
      final day = DateTime(2026, 5, 8);
      final meals = [
        _meal(
          name: '目玉焼き',
          type: MealTimeType.breakfast,
          consumedAt: DateTime(2026, 5, 8, 8),
        ),
        _meal(
          name: 'カレー',
          type: MealTimeType.lunch,
          consumedAt: DateTime(2026, 5, 8, 12),
        ),
        _meal(
          name: 'ステーキ',
          type: MealTimeType.dinner,
          consumedAt: DateTime(2026, 5, 8, 19),
        ),
        _meal(
          name: 'クッキー',
          type: MealTimeType.snack,
          consumedAt: DateTime(2026, 5, 8, 15),
        ),
      ];
      final records = [_record(date: day, consumed: 1600)];

      await _pumpList(tester, records: records, meals: meals);

      // 3 chips visible (sorted by time), 4th overflows into "+1品".
      // Each chip renders RichText with name + kcal — assert via findRichText.
      expect(_findChipRichText(tester, contains: '目玉焼き'), 1);
      expect(_findChipRichText(tester, contains: 'カレー'), 1);
      expect(_findChipRichText(tester, contains: 'クッキー'), 1);
      expect(_findChipRichText(tester, contains: 'ステーキ'), 0);
      expect(find.text('+1品'), findsOneWidget);

      // kcal annotation present on chips (meals.calories = 400).
      expect(_findChipRichText(tester, contains: '400kcal'), greaterThan(0));
    });

    testWidgets('shows estimate CTA and no chips when meal calories are 0', (
      tester,
    ) async {
      final day = DateTime(2026, 5, 7);
      final records = [_record(date: day, consumed: 0)];

      await _pumpList(tester, records: records, meals: const []);

      expect(find.text('食事記録なし'), findsOneWidget);
      expect(find.text('推定で埋める'), findsOneWidget);
      // No chip RichText should render at all when meals are empty.
      expect(_findChipRichText(tester, contains: 'kcal'), 0);
    });

    testWidgets('shows fewer chips when meal count is below the cap', (
      tester,
    ) async {
      final day = DateTime(2026, 5, 6);
      final meals = [
        _meal(
          name: 'パンケーキ',
          type: MealTimeType.breakfast,
          consumedAt: DateTime(2026, 5, 6, 9),
        ),
        _meal(
          name: 'ラーメン',
          type: MealTimeType.lunch,
          consumedAt: DateTime(2026, 5, 6, 13),
        ),
      ];
      final records = [_record(date: day, consumed: 1200)];

      await _pumpList(tester, records: records, meals: meals);

      expect(_findChipRichText(tester, contains: 'パンケーキ'), 1);
      expect(_findChipRichText(tester, contains: 'ラーメン'), 1);
      // No overflow badge when total <= 3 (badge text format: "+N品").
      expect(find.textContaining('品'), findsNothing);
    });
  });
}

/// Count RichText widgets whose plain text contains [contains].
/// `find.text*` matchers don't traverse RichText spans by default, so we
/// flatten span text manually.
int _findChipRichText(WidgetTester tester, {required String contains}) {
  final richTexts = tester.widgetList<RichText>(find.byType(RichText));
  return richTexts.where((rt) {
    final flat = rt.text.toPlainText();
    return flat.contains(contains);
  }).length;
}
