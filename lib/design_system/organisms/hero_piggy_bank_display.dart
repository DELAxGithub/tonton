import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../atoms/tonton_text.dart';
import '../atoms/tonton_card_base.dart';
import '../../theme/tokens.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../providers/providers.dart';

class HeroPiggyBankDisplay extends ConsumerWidget {
  const HeroPiggyBankDisplay({
    super.key,
  });


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final summaryAsync = ref.watch(monthlyProgressSummaryProvider);
    return summaryAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
      data: (summary) {
        final progress = summary.completionPercentage / 100.0;
        final remainingDays = summary.remainingDaysInMonth;
        final targetMonthlyNetBurn = summary.targetMonthlyNetBurn;
        final currentMonthlyNetBurn = summary.currentMonthlyNetBurn;
        final requiredDailyAverage = remainingDays > 0 
            ? (targetMonthlyNetBurn - currentMonthlyNetBurn) / remainingDays
            : 0.0;

        return TontonCardBase(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TontonText(
                    '今月の貯金目標',
                    style: TontonTypography.headline,
                  ),
                  const SizedBox(height: Spacing.xs),
                  TontonText(
                    '${currentMonthlyNetBurn.toStringAsFixed(0)} / ${targetMonthlyNetBurn.toStringAsFixed(0)} kcal',
                    style: TontonTypography.title2.copyWith(
                      fontWeight: FontWeight.bold,
                      color: TontonColors.pigPink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.lg),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 20,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 1.0 ? TontonColors.systemGreen : TontonColors.pigPink,
                  ),
                ),
              ),
              const SizedBox(height: Spacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TontonText(
                    '${(progress * 100).toStringAsFixed(0)}% 達成',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TontonText(
                    'あと$remainingDays日',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              if (requiredDailyAverage > 0) ...[
                const SizedBox(height: Spacing.sm),
                Container(
                  padding: const EdgeInsets.all(Spacing.sm),
                  decoration: BoxDecoration(
                    color: TontonColors.fillColor(context),
                    borderRadius: Radii.mediumBorderRadius,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: Spacing.xs),
                      TontonText(
                        'あと$remainingDays日で平均${requiredDailyAverage.toStringAsFixed(0)}kcal/日必要',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
