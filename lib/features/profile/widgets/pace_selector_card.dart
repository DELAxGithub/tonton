import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/atoms/tonton_card_base.dart';
import '../../../theme/tokens.dart';
import '../../../utils/weight_loss_calculator.dart';
import '../../progress/providers/pfc_balance_provider.dart';

/// 減量ペース (0.5% / 0.7% / 1.0% per week) を選んで、必要な日次赤字を
/// 自動的に目標へ反映させるカード。
class PaceSelectorCard extends ConsumerWidget {
  const PaceSelectorCard({super.key});

  static const _presets = [
    (label: 'ゆるめ', percent: 0.005),
    (label: '標準', percent: 0.007),
    (label: '攻め', percent: 0.010),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(userGoalsProvider);
    final weight = goals.bodyWeightKg;
    final selected = goals.targetWeeklyPercentLoss;

    return TontonCardBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('減量ペース', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            '健康的な範囲は体重の 0.5〜1.0% / 週。プリセットを選ぶと、'
            '必要な日次カロリー赤字が自動で設定されます。',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: Spacing.md),
          SegmentedButton<double>(
            segments: _presets
                .map(
                  (p) => ButtonSegment<double>(
                    value: p.percent,
                    label: Text(
                      '${p.label}\n${(p.percent * 100).toStringAsFixed(1)}%/週',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
                .toList(),
            selected: {_closest(selected)},
            onSelectionChanged: (Set<double> v) {
              ref
                  .read(userGoalsProvider.notifier)
                  .applyPacePreset(v.first);
            },
          ),
          const SizedBox(height: Spacing.md),
          if (weight == null)
            Text(
              '体重を設定すると、必要な日次赤字が計算されます。',
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            _SummaryRow(
              weeklyKg: weight * selected,
              dailyKcal: WeightLossCalculator.requiredDailyDeficit(
                weightKg: weight,
                weeklyPercentLoss: selected,
              ),
              currentGoal: goals.dailyDeficitGoalKcal,
            ),
        ],
      ),
    );
  }

  double _closest(double value) {
    return _presets
        .map((p) => p.percent)
        .reduce((a, b) => (a - value).abs() < (b - value).abs() ? a : b);
  }
}

class _SummaryRow extends StatelessWidget {
  final double weeklyKg;
  final double dailyKcal;
  final double currentGoal;

  const _SummaryRow({
    required this.weeklyKg,
    required this.dailyKcal,
    required this.currentGoal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mismatch = (currentGoal - dailyKcal).abs() > 1.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _InlineMetric(
              label: '週あたり',
              value: '-${weeklyKg.toStringAsFixed(2)} kg',
            ),
            const SizedBox(width: 24),
            _InlineMetric(
              label: '必要な日次赤字',
              value: '${dailyKcal.round()} kcal',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '現在の目標: ${currentGoal.round()} kcal/日'
          '${mismatch ? "（未反映）" : ""}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: mismatch
                ? theme.colorScheme.error
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _InlineMetric extends StatelessWidget {
  final String label;
  final String value;

  const _InlineMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
