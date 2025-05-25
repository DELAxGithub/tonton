import 'package:flutter/material.dart';
import '../atoms/tonton_text.dart';
import '../molecules/daily_stat_ring.dart';
import '../atoms/tonton_card_base.dart';
import '../atoms/tonton_icon.dart';
import '../../theme/tokens.dart';
import '../../theme/theme.dart';
import '../../utils/icon_mapper.dart';

class DailySummarySection extends StatelessWidget {
  final double eatenCalories;
  final double burnedCalories;
  final double? realtimeBurnedCalories;
  final double dailySavings;
  final double targetCalories;

  const DailySummarySection({
    super.key,
    required this.eatenCalories,
    required this.burnedCalories,
    this.realtimeBurnedCalories,
    required this.dailySavings,
    this.targetCalories = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final intakeProgress = targetCalories > 0
        ? (eatenCalories / targetCalories).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TontonText(
          '今日のバランス',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: Spacing.sm),
        Row(
          children: [
            Expanded(
              child: DailyStatRing(
                icon: TontonIcons.food,
                label: '食べたキロカロリー',
                currentValue: eatenCalories.toStringAsFixed(0),
                targetValue: '/ ${targetCalories.toStringAsFixed(0)} kcal',
                progress: intakeProgress,
              ),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: DailyStatRing(
                icon: TontonIcons.workout,
                label: '活動したキロカロリー',
                currentValue: '${burnedCalories.toStringAsFixed(0)} kcal',
                progress: 1.0,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: _SavingsCard(
                savings: dailySavings,
              ),
            ),
          ],
        ),
        if (realtimeBurnedCalories != null &&
            realtimeBurnedCalories != burnedCalories)
          Padding(
            padding: const EdgeInsets.only(top: Spacing.xs),
            child: TontonText(
              'リアルタイム: ${realtimeBurnedCalories!.toStringAsFixed(0)} kcal',
              style: theme.textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}

class _SavingsCard extends StatelessWidget {
  final double savings;

  const _SavingsCard({required this.savings});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final positive = savings >= 0;
    final color = positive ? theme.colorScheme.success : theme.colorScheme.error;
    final prefix = positive ? '+' : '-';

    return TontonCardBase(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TontonIcon(
            TontonIcons.coin,
            size: 24,
            color: color,
          ),
          const SizedBox(height: Spacing.sm),
          TontonText(
            '$prefix${savings.abs().toStringAsFixed(0)} kcal',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            align: TextAlign.center,
          ),
          const SizedBox(height: Spacing.xs),
          TontonText(
            '今日の貯金',
            style: theme.textTheme.bodyMedium,
            align: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
