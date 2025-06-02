import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/calorie_savings_record.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';
import '../routes/router.dart';

/// 日別の履歴を表示するリストウィジェット
class DailyHistoryList extends StatelessWidget {
  final List<CalorieSavingsRecord> records;
  final bool showLatestFirst;

  const DailyHistoryList({
    super.key,
    required this.records,
    this.showLatestFirst = true,
  });

  @override
  Widget build(BuildContext context) {
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
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'まだ履歴がありません',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final sortedRecords = showLatestFirst 
        ? records.reversed.toList() 
        : records;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedRecords.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final record = sortedRecords[index];
        final isPositive = record.dailyBalance > 0;
        
        return Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              context.push(
                TontonRoutes.dailyMealsDetail,
                extra: {
                  'date': record.date,
                  'savingsRecord': record,
                },
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
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormatter.formatWeekdayJa(record.date),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Daily savings
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isPositive ? Icons.trending_up : Icons.trending_down,
                              size: 16,
                              color: isPositive 
                                  ? TontonColors.success 
                                  : TontonColors.error,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${isPositive ? "+" : ""}${record.dailyBalance.toStringAsFixed(0)} kcal',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Chevron icon
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
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