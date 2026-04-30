import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/monthly_goal_progress_provider.dart';

/// トントンヒストリー画面の主役カード。
/// 「今月の目標達成度」をドーナツ + 数値 + ペース判定で見せる。
class MonthlyGoalProgressCard extends ConsumerWidget {
  const MonthlyGoalProgressCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(monthlyGoalProgressProvider);
    final theme = Theme.of(context);
    final paceColor = _paceColor(progress.pace, theme);

    final progressPercent = (progress.progressRatio * 100).clamp(0, 999);
    final actualText = progress.actualKcal.round().toString();
    final goalText = progress.goalKcal.round().toString();
    final remainingText = progress.remainingKcal.round().toString();

    final ringActual =
        progress.progressRatio.clamp(0.0, 1.0).toDouble();
    final ringRemaining = (1.0 - ringActual).clamp(0.0, 1.0).toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${progress.monthStart.year}年${progress.monthStart.month}月の目標達成度',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 60,
                      startDegreeOffset: -90,
                      sections: [
                        PieChartSectionData(
                          value: ringActual,
                          color: paceColor,
                          radius: 18,
                          showTitle: false,
                        ),
                        PieChartSectionData(
                          value: ringRemaining,
                          color: theme.colorScheme.surfaceContainerHighest,
                          radius: 18,
                          showTitle: false,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${progressPercent.round()}%',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: paceColor,
                        ),
                      ),
                      Text(
                        '達成',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    label: '現在の貯金',
                    value: '$actualText / $goalText kcal',
                  ),
                ),
                Expanded(
                  child: _StatTile(
                    label: '残り',
                    value: '$remainingText kcal',
                    sub: 'あと ${progress.daysRemaining} 日',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _PaceBadge(pace: progress.pace, color: paceColor),
          ],
        ),
      ),
    );
  }

  Color _paceColor(MonthlyPace pace, ThemeData theme) {
    switch (pace) {
      case MonthlyPace.onTrack:
        return Colors.green.shade600;
      case MonthlyPace.slightlyBehind:
        return Colors.orange.shade600;
      case MonthlyPace.wayBehind:
        return Colors.red.shade600;
      case MonthlyPace.notStarted:
        return theme.colorScheme.outline;
    }
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  const _StatTile({required this.label, required this.value, this.sub});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (sub != null) ...[
          const SizedBox(height: 2),
          Text(sub!, style: theme.textTheme.bodySmall),
        ],
      ],
    );
  }
}

class _PaceBadge extends StatelessWidget {
  final MonthlyPace pace;
  final Color color;
  const _PaceBadge({required this.pace, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, text) = _content(pace);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }

  (IconData, String) _content(MonthlyPace pace) {
    switch (pace) {
      case MonthlyPace.onTrack:
        return (Icons.check_circle, 'ペース通り進んでいます！この調子で。');
      case MonthlyPace.slightlyBehind:
        return (Icons.info_outline, 'やや遅れていますが、巻き返し可能なペースです。');
      case MonthlyPace.wayBehind:
        return (Icons.warning_amber, '目標から遅れています。ペースを上げましょう。');
      case MonthlyPace.notStarted:
        return (Icons.hourglass_empty, '今月はこれから。記録を続けていきましょう。');
    }
  }
}
