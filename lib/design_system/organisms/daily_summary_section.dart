import 'package:flutter/material.dart';
import '../atoms/tonton_text.dart';
import '../atoms/tonton_card_base.dart';
import '../atoms/tonton_icon.dart';
import '../../theme/tokens.dart';
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
    final positive = dailySavings >= 0;
    final color = positive ? theme.colorScheme.primary : theme.colorScheme.error;
    final prefix = positive ? '+' : '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TontonText(
          '今日の貯金',
          style: theme.textTheme.bodyMedium,
          align: TextAlign.center,
        ),
        const SizedBox(height: Spacing.xs),
        TontonIcon(
          TontonIcons.coin,
          size: 48,
          color: color,
        ),
        const SizedBox(height: Spacing.sm),
        TontonText(
          '$prefix${dailySavings.abs().toStringAsFixed(0)} kcal',
          style: theme.textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
          align: TextAlign.center,
        ),
        const SizedBox(height: Spacing.lg),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: TontonIcons.food,
                label: '食べた',
                value: '${eatenCalories.toStringAsFixed(0)} kcal',
              ),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: _StatCard(
                icon: TontonIcons.workout,
                label: '活動した',
                value: '${burnedCalories.toStringAsFixed(0)} kcal',
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;

    return TontonCardBase(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TontonIcon(icon, size: 32, color: color),
          const SizedBox(height: Spacing.sm),
          TontonText(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            align: TextAlign.center,
          ),
          const SizedBox(height: Spacing.xs),
          TontonText(
            label,
            style: theme.textTheme.bodyMedium,
            align: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
