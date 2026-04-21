import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/calorie_savings_provider.dart';
import '../../../core/providers/diagnosis_provider.dart';
import '../../../utils/weight_loss_calculator.dart';

/// 期待減量 vs 実測減量 を並べる軽量カード。
class ExpectedVsActualCard extends ConsumerWidget {
  const ExpectedVsActualCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summariesAsync = ref.watch(dailySummariesProvider);
    final diagnosis = ref.watch(diagnosisProvider);

    return summariesAsync.maybeWhen(
      data: (summaries) {
        if (summaries.isEmpty) return const SizedBox.shrink();
        final cumulativeDeficit = summaries.fold<double>(
          0,
          (sum, s) => sum + (s.caloriesBurned - s.caloriesConsumed),
        );
        final expectedKg = WeightLossCalculator.expectedWeightLossKg(
          cumulativeDeficitKcal: cumulativeDeficit,
        );
        final actualKg = diagnosis?.actualLossKg;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .outline
                  .withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '理論値と実測',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _Metric(
                    label: '期待',
                    value: '-${expectedKg.toStringAsFixed(1)} kg',
                    caption: '累積赤字 ÷ 7700',
                  ),
                  const SizedBox(width: 24),
                  _Metric(
                    label: '実測',
                    value: actualKg == null
                        ? '—'
                        : '${actualKg >= 0 ? "-" : "+"}${actualKg.abs().toStringAsFixed(1)} kg',
                    caption: '期間初日 → 当日',
                  ),
                ],
              ),
              if (diagnosis?.actualPerExpectedRatio != null) ...[
                const SizedBox(height: 8),
                Text(
                  '達成率: ${(diagnosis!.actualPerExpectedRatio! * 100).round()}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final String caption;

  const _Metric({
    required this.label,
    required this.value,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                ),
          ),
        ],
      ),
    );
  }
}
