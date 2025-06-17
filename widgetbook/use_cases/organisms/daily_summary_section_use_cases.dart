import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:tonton/design_system/organisms/daily_summary_section.dart';
import 'package:tonton/design_system/organisms/calorie_summary_row.dart';
import 'package:tonton/models/daily_summary.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dailySummarySectionUseCases = WidgetbookComponent(
  name: 'DailySummarySection',
  useCases: [
    WidgetbookUseCase(
      name: 'Complete Summary',
      builder: (context) {
        final consumed = context.knobs.double.slider(
          label: 'Calories Consumed',
          min: 0,
          max: 3000,
          initialValue: 1850,
        );
        final burned = context.knobs.double.slider(
          label: 'Calories Burned',
          min: 0,
          max: 4000,
          initialValue: 2200,
        );

        final summary = DailySummary(
          id: DateTime.now().toIso8601String().split('T')[0],
          date: DateTime.now(),
          totalCaloriesConsumed: consumed,
          totalCaloriesBurned: burned,
          basalCalories: 1600,
          activeCalories: burned - 1600,
          netCalories: consumed - burned,
          mealRecordIds: [],
        );

        return ProviderScope(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: DailySummarySection(summary: summary),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Calorie Summary Row',
      builder: (context) {
        final consumed = context.knobs.double.slider(
          label: 'Consumed',
          min: 0,
          max: 3000,
          initialValue: 1650,
        );
        final burned = context.knobs.double.slider(
          label: 'Burned',
          min: 0,
          max: 3000,
          initialValue: 2100,
        );
        final showSavings = context.knobs.boolean(
          label: 'Show Savings',
          initialValue: true,
        );

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CalorieSummaryRow(
              consumed: consumed,
              burned: burned,
              saved: showSavings ? (burned - consumed) : null,
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Different Scenarios',
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildExample(
                'Calorie Deficit (Good Day)',
                CalorieSummaryRow(consumed: 1500, burned: 2200, saved: 700),
              ),
              _buildExample(
                'Maintenance',
                CalorieSummaryRow(consumed: 2000, burned: 2000, saved: 0),
              ),
              _buildExample(
                'Calorie Surplus',
                CalorieSummaryRow(consumed: 2500, burned: 2000, saved: -500),
              ),
              _buildExample(
                'Very Active Day',
                CalorieSummaryRow(consumed: 1800, burned: 3200, saved: 1400),
              ),
              _buildExample(
                'Rest Day',
                CalorieSummaryRow(consumed: 1600, burned: 1800, saved: 200),
              ),
            ],
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Summary States',
      builder: (context) {
        return ProviderScope(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildExample(
                  'Morning (No meals yet)',
                  DailySummarySection(
                    summary: DailySummary(
                      id: 'today',
                      date: DateTime.now(),
                      totalCaloriesConsumed: 0,
                      totalCaloriesBurned: 800,
                      basalCalories: 800,
                      activeCalories: 0,
                      netCalories: -800,
                      mealRecordIds: [],
                    ),
                  ),
                ),
                _buildExample(
                  'After Breakfast',
                  DailySummarySection(
                    summary: DailySummary(
                      id: 'today',
                      date: DateTime.now(),
                      totalCaloriesConsumed: 450,
                      totalCaloriesBurned: 1000,
                      basalCalories: 900,
                      activeCalories: 100,
                      netCalories: -550,
                      mealRecordIds: ['meal1'],
                    ),
                  ),
                ),
                _buildExample(
                  'End of Day',
                  DailySummarySection(
                    summary: DailySummary(
                      id: 'today',
                      date: DateTime.now(),
                      totalCaloriesConsumed: 1850,
                      totalCaloriesBurned: 2400,
                      basalCalories: 1600,
                      activeCalories: 800,
                      netCalories: -550,
                      mealRecordIds: ['meal1', 'meal2', 'meal3', 'snack1'],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Compact View',
      builder: (context) {
        return Center(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '今日のサマリー',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateTime.now().toString().split(' ')[0],
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CalorieSummaryRow(consumed: 1750, burned: 2150, saved: 400),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildCompactStat(
                        context,
                        'Active',
                        '550',
                        'kcal',
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildCompactStat(
                        context,
                        'Basal',
                        '1600',
                        'kcal',
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  ],
);

Widget _buildExample(String title, Widget widget) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      widget,
      const SizedBox(height: 24),
    ],
  );
}

Widget _buildCompactStat(
  BuildContext context,
  String label,
  String value,
  String unit,
  Color color,
) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
        ),
        const SizedBox(height: 4),
        Row(
          baseline: TextBaseline.alphabetic,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: color),
            ),
          ],
        ),
      ],
    ),
  );
}
