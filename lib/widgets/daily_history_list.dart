import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/meal_logging/widgets/estimation_bottom_sheet.dart';
import '../models/calorie_savings_record.dart';
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

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedRecords.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final record = sortedRecords[index];
        final isPositive = record.dailyBalance > 0;
        final hasNoMeals = record.caloriesConsumed < 50;

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
              child: Row(
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
                    child: hasNoMeals
                        ? _EstimateCta(
                            date: record.date,
                            burnedKcal: record.caloriesBurned,
                          )
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
                                    color: isPositive
                                        ? TontonColors.success
                                        : TontonColors.error,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${isPositive ? "+" : ""}${record.dailyBalance.toStringAsFixed(0)} kcal',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: isPositive
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
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
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
  final double burnedKcal;

  const _EstimateCta({required this.date, required this.burnedKcal});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '食事記録なし',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
          ),
        ),
        TextButton.icon(
          onPressed: () {
            EstimationBottomSheet.show(
              context,
              date: date,
              burnedKcal: burnedKcal,
            );
          },
          icon: const Icon(Icons.auto_fix_high, size: 18),
          label: const Text('推定で埋める'),
        ),
      ],
    );
  }
}
