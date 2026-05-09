import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/meal_logging/providers/meal_records_provider.dart';
import '../features/meal_logging/widgets/estimation_bottom_sheet.dart';
import '../models/calorie_savings_record.dart';
import '../models/meal_record.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';
import '../routes/router.dart';

/// 日別の履歴を表示するリストウィジェット
class DailyHistoryList extends ConsumerWidget {
  final List<CalorieSavingsRecord> records;
  final bool showLatestFirst;

  const DailyHistoryList({
    super.key,
    required this.records,
    this.showLatestFirst = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (records.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.history,
                size: 48,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'まだ履歴がありません',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final sortedRecords = showLatestFirst ? records.reversed.toList() : records;

    // Group meals by day key for fast per-card lookup. Async data falls back
    // to empty so the card still renders kcal balance.
    final mealsAsync = ref.watch(mealRecordsProvider);
    final mealsByDay = <String, List<MealRecord>>{};
    final allMeals = mealsAsync.maybeWhen(
      data: (state) => state.records,
      orElse: () => const <MealRecord>[],
    );
    String dayKey(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    for (final m in allMeals) {
      final key = dayKey(m.consumedAt.toLocal());
      mealsByDay.putIfAbsent(key, () => []).add(m);
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedRecords.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final record = sortedRecords[index];
        final isPositive = record.dailyBalance > 0;
        final hasNoMeals = record.caloriesConsumed < 50;
        final dayMeals =
            mealsByDay[dayKey(record.date)] ?? const <MealRecord>[];

        return Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              context.push(
                TontonRoutes.dailyMealsDetail,
                extra: {'date': record.date},
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Date column
                      SizedBox(
                        width: 80,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormatter.formatMonthDay(record.date),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              DateFormatter.formatWeekdayJa(record.date),
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Daily savings / empty meals estimate button
                      Expanded(
                        child:
                            hasNoMeals
                                ? _EstimateCta(date: record.date)
                                : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          isPositive
                                              ? Icons.trending_up
                                              : Icons.trending_down,
                                          size: 16,
                                          color:
                                              isPositive
                                                  ? TontonColors.success
                                                  : TontonColors.error,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${isPositive ? "+" : ""}${record.dailyBalance.toStringAsFixed(0)} kcal',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium?.copyWith(
                                            color:
                                                isPositive
                                                    ? TontonColors.success
                                                    : TontonColors.error,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '累積: ${record.cumulativeSavings.toStringAsFixed(0)} kcal',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                      // Chevron icon
                      if (!hasNoMeals)
                        Icon(
                          Icons.chevron_right,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                    ],
                  ),
                  if (!hasNoMeals && dayMeals.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _MealPreviewChips(meals: dayMeals),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 食事記録ゼロの日に出す「推定」CTA。
class _EstimateCta extends StatelessWidget {
  final DateTime date;

  const _EstimateCta({required this.date});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '食事記録なし',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        TextButton.icon(
          onPressed: () {
            EstimationBottomSheet.show(context, date: date);
          },
          icon: const Icon(Icons.auto_fix_high, size: 18),
          label: const Text('推定で埋める'),
        ),
      ],
    );
  }
}

/// 1日の食事プレビューチップ列。最大3件 + あふれは `+N品` で表現。
/// チップは「食事名 + kcal」の二段で読める形 (例: `カレーライス 650kcal`)。
class _MealPreviewChips extends StatelessWidget {
  final List<MealRecord> meals;

  const _MealPreviewChips({required this.meals});

  static const int _maxVisible = 3;

  @override
  Widget build(BuildContext context) {
    final sorted = List<MealRecord>.from(meals)
      ..sort((a, b) => a.consumedAt.compareTo(b.consumedAt));
    final visible = sorted.take(_maxVisible).toList();
    final overflow = sorted.length - visible.length;

    final chipColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    final textColor = Theme.of(context).colorScheme.onSurface;

    final baseStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: textColor.withValues(alpha: 0.85),
    );
    final kcalStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: textColor.withValues(alpha: 0.55),
      fontWeight: FontWeight.w600,
      fontSize: 11,
    );

    return Padding(
      padding: const EdgeInsets.only(left: 96), // align under content column
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final meal in visible)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: chipColor,
                borderRadius: BorderRadius.circular(12),
              ),
              constraints: const BoxConstraints(maxWidth: 160),
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(text: meal.mealName, style: baseStyle),
                    TextSpan(
                      text: ' ${meal.calories.round()}kcal',
                      style: kcalStyle,
                    ),
                  ],
                ),
              ),
            ),
          if (overflow > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: chipColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '+$overflow品',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
