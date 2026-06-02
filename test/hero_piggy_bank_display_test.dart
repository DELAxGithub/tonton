import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tonton/core/providers/realtime_calories_provider.dart';
import 'package:tonton/design_system/organisms/hero_piggy_bank_display.dart';
import 'package:tonton/enums/meal_time_type.dart';
import 'package:tonton/features/meal_logging/providers/meal_records_provider.dart';
import 'package:tonton/models/daily_summary.dart';
import 'package:tonton/models/meal_record.dart';

void main() {
  testWidgets('shows today savings from meals and realtime calories', (
    tester,
  ) async {
    final today = DateTime.now();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todaysMealRecordsProvider.overrideWith(
            (ref) => [
              MealRecord(
                id: 'meal-1',
                mealName: '朝食',
                calories: 600,
                protein: 20,
                fat: 15,
                carbs: 80,
                mealTimeType: MealTimeType.breakfast,
                consumedAt: today,
              ),
            ],
          ),
          realtimeDailySummaryProvider.overrideWith(
            (ref) async => DailySummary(
              date: today,
              caloriesConsumed: 600,
              caloriesBurned: 1200,
            ),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: HeroPiggyBankDisplay())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('今日のカロリー貯金'), findsOneWidget);
    expect(find.text('+600'), findsOneWidget);
    expect(find.text('摂取: 600'), findsOneWidget);
    expect(find.text('消費: 1200'), findsOneWidget);
  });
}
