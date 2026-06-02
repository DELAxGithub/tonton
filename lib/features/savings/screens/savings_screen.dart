import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/providers.dart';
import '../../../models/calorie_savings_record.dart';
import '../../../models/weight_record.dart';
import '../../../design_system/atoms/tonton_button.dart';
import '../../../utils/weight_loss_calculator.dart';
import '../../../widgets/three_line_weight_chart.dart';
import '../../../routes/router.dart';
import '../../health/providers/weight_history_provider.dart';
import '../../progress/providers/ideal_weight_trajectory_provider.dart';
import '../../progress/providers/monthly_goal_progress_provider.dart';
import '../models/pattern_narrative.dart';
import '../services/pattern_matching_service.dart';
import '../services/pattern_narrative_service.dart';
import '../models/dietary_pattern.dart';
import '../widgets/pattern_dictionary_card.dart';

/// 貯金タブ。結果軸（カロリー貯金 + 体重 + 楽しみ枠）に集約。
/// 食事の日別履歴は記録タブに寄せた。
class SavingsScreen extends ConsumerWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allRecordsAsync = ref.watch(calorieSavingsDataProvider);
    final period = ref.watch(selectedPeriodProvider);
    final filteredRecords = ref.watch(filteredCalorieSavingsProvider);

    return allRecordsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (allRecords) {
        final startDate = ref.watch(onboardingStartDateProvider);
        final now = DateTime.now();
        final monthStart = DateTime(now.year, now.month, 1);

        final records = List<CalorieSavingsRecord>.from(filteredRecords);
        final currentMonthRecords = List<CalorieSavingsRecord>.from(
          allRecords.where((r) => !r.date.isBefore(monthStart)),
        );

        if (startDate != null && records.isNotEmpty) {
          final firstAllowed = DateTime(
            startDate.year,
            startDate.month,
            startDate.day,
          );
          records.removeWhere((r) => r.date.isBefore(firstAllowed));
          currentMonthRecords.removeWhere((r) => r.date.isBefore(firstAllowed));
        }

        // Align weight + ideal trajectory by date so the chart can draw both
        // lines on top of cumulative savings.
        final weightHistoryAsync = ref.watch(weightHistoryProvider);
        final ideal = ref.watch(idealWeightTrajectoryProvider);
        final weightHistory = weightHistoryAsync.maybeWhen(
          data: (list) => list,
          orElse: () => const <WeightRecord>[],
        );
        String dayKey(DateTime d) =>
            '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        final weightByDay = <String, WeightRecord>{};
        for (final w in weightHistory) {
          weightByDay[dayKey(w.date)] = w;
        }
        final idealByDay = <String, double>{};
        for (final p in ideal) {
          idealByDay[dayKey(p.date)] = p.idealKg;
        }
        final weightRecords = <WeightRecord?>[
          for (final r in records) weightByDay[dayKey(r.date)],
        ];
        final idealWeightsKg = <double?>[
          for (final r in records) idealByDay[dayKey(r.date)],
        ];

        final cumulativeSavings =
            currentMonthRecords.isNotEmpty
                ? currentMonthRecords.last.cumulativeSavings
                : 0.0;
        final todaysBalance =
            currentMonthRecords.isNotEmpty &&
                    currentMonthRecords.last.date.year == now.year &&
                    currentMonthRecords.last.date.month == now.month &&
                    currentMonthRecords.last.date.day == now.day
                ? currentMonthRecords.last.dailyBalance
                : 0.0;
        final monthlyProgress = ref.watch(monthlyGoalProgressProvider);
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  'カロリー貯金',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                _MonthlyOverviewCard(
                  cumulativeSavings: cumulativeSavings,
                  todaysBalance: todaysBalance,
                  monthlyProgress: monthlyProgress,
                ),
                const SizedBox(height: 20),

                _MonthlySavingsTrendCard(records: currentMonthRecords),
                const SizedBox(height: 20),

                // 体重トレンドチャート (3線並走 / kg軸単独)
                Builder(
                  builder: (_) {
                    final goals = ref.watch(userGoalsProvider);
                    final startWeight =
                        goals.startingBodyWeightKg ??
                        goals.bodyWeightKg ??
                        (records.isNotEmpty &&
                                weightRecords.isNotEmpty &&
                                weightRecords.first != null
                            ? weightRecords.first!.weight
                            : 70.0);

                    // idealWeightTrajectoryProvider は startingBodyWeightDate
                    // が未設定だと空リストを返す。プロフィール開始日を未設定の
                    // ユーザーでも計画線が描けるよう、フォールバックでローカル
                    // 計算する: records.first.date を anchor、weeklyPace で線形。
                    final hasIdealData = idealWeightsKg.any((v) => v != null);
                    final planList = <double?>[];
                    if (hasIdealData) {
                      planList.addAll(idealWeightsKg);
                    } else if (records.isNotEmpty) {
                      final pace = goals.targetWeeklyPercentLoss;
                      final anchor = records.first.date;
                      for (final r in records) {
                        final days = r.date.difference(anchor).inDays;
                        final weeks = days / 7.0;
                        planList.add(startWeight * (1 - pace * weeks));
                      }
                    } else {
                      planList.addAll(idealWeightsKg);
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ThreeLineChartCard(
                          records: records,
                          weightRecords: weightRecords,
                          idealKgList: planList,
                          startingBodyWeightKg: startWeight,
                          period: period,
                        ),
                        const SizedBox(height: 12),
                        _PatternMatchSection(
                          records: records,
                          weightRecords: weightRecords,
                          idealKgList: planList,
                          startingBodyWeightKg: startWeight,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),

                // 楽しみ枠の候補ボタン
                Center(
                  child: TontonButton.primary(
                    label: '楽しみ候補を見る',
                    icon: Icons.restaurant_menu,
                    onPressed: () => context.push(TontonRoutes.useSavings),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MonthlySavingsTrendCard extends StatelessWidget {
  final List<CalorieSavingsRecord> records;

  const _MonthlySavingsTrendCard({required this.records});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthLabel = DateTime.now().month;

    final values = records.map((r) => r.cumulativeSavings).toList();
    final minValue =
        values.isEmpty ? 0.0 : values.reduce((a, b) => a < b ? a : b);
    final maxValue =
        values.isEmpty ? 0.0 : values.reduce((a, b) => a > b ? a : b);
    final yPadding = ((maxValue - minValue).abs() * 0.15).clamp(200.0, 1200.0);
    final minY = (minValue - yPadding).clamp(-100000.0, 0.0);
    final maxY = (maxValue + yPadding).clamp(500.0, 100000.0);
    final stride =
        records.length > 20
            ? 7
            : records.length > 10
            ? 3
            : 1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$monthLabel月の推移',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '月初からの増減だけを表示します',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child:
                  records.isEmpty
                      ? Center(
                        child: Text(
                          '今月の記録はまだありません',
                          style: theme.textTheme.bodyMedium,
                        ),
                      )
                      : LineChart(
                        LineChartData(
                          minX: 0,
                          maxX: (records.length - 1).toDouble(),
                          minY: minY.toDouble(),
                          maxY: maxY.toDouble(),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine:
                                (value) => FlLine(
                                  color: theme.colorScheme.outline.withValues(
                                    alpha: 0.18,
                                  ),
                                  strokeWidth: 1,
                                ),
                          ),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 44,
                                getTitlesWidget:
                                    (value, meta) => Text(
                                      value.abs() >= 1000
                                          ? '${(value / 1000).toStringAsFixed(1)}k'
                                          : value.toStringAsFixed(0),
                                      style: const TextStyle(fontSize: 10),
                                    ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index < 0 || index >= records.length) {
                                    return const SizedBox.shrink();
                                  }
                                  if (index % stride != 0) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      '${records[index].date.day}日',
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: [
                                for (int i = 0; i < records.length; i++)
                                  FlSpot(
                                    i.toDouble(),
                                    records[i].cumulativeSavings,
                                  ),
                              ],
                              isCurved: true,
                              color: theme.colorScheme.primary,
                              barWidth: 3,
                              belowBarData: BarAreaData(
                                show: true,
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.12,
                                ),
                              ),
                              dotData: FlDotData(show: records.length <= 14),
                            ),
                          ],
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipItems:
                                  (spots) =>
                                      spots.map((spot) {
                                        final index = spot.x.toInt();
                                        if (index < 0 ||
                                            index >= records.length)
                                          return null;
                                        final record = records[index];
                                        return LineTooltipItem(
                                          '${record.date.month}/${record.date.day}\n'
                                          '${record.cumulativeSavings.toStringAsFixed(0)} kcal',
                                          TextStyle(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      }).toList(),
                            ),
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 3 線並走チャート + 直下の 3 セル数値リードアウト (計画/理論/実測)。
/// 旧 ExpectedVsActualCard を吸収する役割。
class _ThreeLineChartCard extends ConsumerWidget {
  final List<CalorieSavingsRecord> records;
  final List<WeightRecord?> weightRecords;
  final List<double?> idealKgList;
  final double startingBodyWeightKg;
  final SelectedPeriod period;

  const _ThreeLineChartCard({
    required this.records,
    required this.weightRecords,
    required this.idealKgList,
    required this.startingBodyWeightKg,
    required this.period,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Compute visible-period deltas for the readout.
    String fmtDelta(double kg) {
      final sign = kg >= 0 ? '+' : '−';
      return '$sign${kg.abs().toStringAsFixed(2)}kg';
    }

    double? planDeltaKg;
    final planValues = idealKgList.whereType<double>().toList();
    if (planValues.length >= 2) {
      planDeltaKg = planValues.last - planValues.first;
    }

    double? theoryDeltaKg;
    if (records.isNotEmpty) {
      final visibleSavings = records.fold<double>(
        0,
        (sum, record) => sum + record.dailyBalance,
      );
      theoryDeltaKg = -visibleSavings / WeightLossCalculator.kcalPerKg;
    }

    double? actualDeltaKg;
    final actualValues = [
      for (final w in weightRecords)
        if (w != null) w.weight,
    ];
    if (actualValues.length >= 2) {
      actualDeltaKg = actualValues.last - actualValues.first;
    }
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '体重トレンド',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _TrendPeriodSelector(period: period),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '計画 (灰破線) / 理論 = 期間内の日次収支÷7700 / 実測 (HealthKit)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ThreeLineWeightChart(
              records: records,
              weightRecords: weightRecords,
              idealKgList: idealKgList,
              startingBodyWeightKg: startingBodyWeightKg,
              period: period,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _ReadoutCell(
                label: '計画',
                value: planDeltaKg == null ? '—' : fmtDelta(planDeltaKg),
                color: Colors.grey.shade700,
              ),
              const SizedBox(width: 8),
              _ReadoutCell(
                label: '理論',
                value: theoryDeltaKg == null ? '—' : fmtDelta(theoryDeltaKg),
                color: const Color(0xFFE0576A),
              ),
              const SizedBox(width: 8),
              _ReadoutCell(
                label: '実測',
                value: actualDeltaKg == null ? '—' : fmtDelta(actualDeltaKg),
                color: const Color(0xFF2A6BB0),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendPeriodSelector extends ConsumerWidget {
  final SelectedPeriod period;

  const _TrendPeriodSelector({required this.period});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SegmentedButton<SelectedPeriod>(
      showSelectedIcon: false,
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 8),
        ),
        textStyle: WidgetStatePropertyAll(
          Theme.of(context).textTheme.labelSmall,
        ),
      ),
      segments: const [
        ButtonSegment(value: SelectedPeriod.week, label: Text('7日')),
        ButtonSegment(value: SelectedPeriod.month, label: Text('今月')),
        ButtonSegment(value: SelectedPeriod.all, label: Text('全期間')),
      ],
      selected: {period},
      onSelectionChanged: (newSelection) {
        ref.read(selectedPeriodProvider.notifier).state = newSelection.first;
      },
    );
  }
}

class _ReadoutCell extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ReadoutCell({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyOverviewCard extends StatelessWidget {
  final double cumulativeSavings;
  final double todaysBalance;
  final MonthlyGoalProgress monthlyProgress;

  const _MonthlyOverviewCard({
    required this.cumulativeSavings,
    required this.todaysBalance,
    required this.monthlyProgress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressPercent = (monthlyProgress.progressRatio * 100).clamp(0, 999);
    final barProgress = monthlyProgress.progressRatio.clamp(0.0, 1.0);
    final paceColor = _paceColor(monthlyProgress.pace, theme);
    final todayText =
        '${todaysBalance >= 0 ? "+" : ""}${todaysBalance.toStringAsFixed(0)} kcal';

    return Card(
      elevation: 2,
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.savings_outlined,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '今月のカロリー貯金',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${cumulativeSavings > 0 ? "+" : ""}${cumulativeSavings.toStringAsFixed(0)} kcal',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${progressPercent.round()}%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: paceColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: barProgress.toDouble(),
                minHeight: 8,
                backgroundColor: theme.colorScheme.surface.withValues(
                  alpha: 0.72,
                ),
                valueColor: AlwaysStoppedAnimation<Color>(paceColor),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MiniMetric(
                    label: '今日',
                    value: todayText,
                    color:
                        todaysBalance >= 0 ? Colors.green.shade700 : paceColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MiniMetric(
                    label: '残り',
                    value: '${monthlyProgress.remainingKcal.round()} kcal',
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MiniMetric(
                    label: 'あと',
                    value: '${monthlyProgress.daysRemaining}日',
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _paceIcon(monthlyProgress.pace),
                    size: 16,
                    color: paceColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _paceText(monthlyProgress.pace),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: paceColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
        return Colors.orange.shade700;
      case MonthlyPace.wayBehind:
        return Colors.red.shade600;
      case MonthlyPace.notStarted:
        return theme.colorScheme.outline;
    }
  }

  IconData _paceIcon(MonthlyPace pace) {
    switch (pace) {
      case MonthlyPace.onTrack:
        return Icons.check_circle_outline;
      case MonthlyPace.slightlyBehind:
        return Icons.info_outline;
      case MonthlyPace.wayBehind:
        return Icons.warning_amber;
      case MonthlyPace.notStarted:
        return Icons.hourglass_empty;
    }
  }

  String _paceText(MonthlyPace pace) {
    switch (pace) {
      case MonthlyPace.onTrack:
        return '今月はペース内です';
      case MonthlyPace.slightlyBehind:
        return '少し遅れていますが調整できます';
      case MonthlyPace.wayBehind:
        return '目標ペースより遅れています';
      case MonthlyPace.notStarted:
        return '今月はこれからです';
    }
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// チャート直下に置く「📚 挫折パターン辞典で照合」トリガーセクション。
///
/// 押すまで結果カードは出さない (チャート上の主役を消さない / 計算負荷を遅延)。
/// 結果は同セクション内のローカル state で保持。
class _PatternMatchSection extends StatefulWidget {
  final List<CalorieSavingsRecord> records;
  final List<WeightRecord?> weightRecords;
  final List<double?> idealKgList;
  final double startingBodyWeightKg;

  const _PatternMatchSection({
    required this.records,
    required this.weightRecords,
    required this.idealKgList,
    required this.startingBodyWeightKg,
  });

  @override
  State<_PatternMatchSection> createState() => _PatternMatchSectionState();
}

class _PatternMatchSectionState extends State<_PatternMatchSection> {
  PatternMatchResult? _result;
  PatternNarrative? _narrative;
  bool _narrativeLoading = false;

  Future<void> _classify() async {
    final result = PatternMatchingService.classify(
      records: widget.records,
      weightRecords: widget.weightRecords,
      idealKgList: widget.idealKgList,
      startingBodyWeightKg: widget.startingBodyWeightKg,
    );
    setState(() {
      _result = result;
      _narrative = null;
    });

    // 類似度が高い時だけ LLM の paraphrase を試みる (低類似度はテンプレで十分)。
    if (result.similarity < 0.4) return;

    setState(() => _narrativeLoading = true);
    try {
      final entry = DietaryPatternDictionary.get(result.patternId);
      final narrative = await PatternNarrativeService.generate(
        result: result,
        templateEntry: entry,
        summaryStats: result.dataObservation,
      );
      if (!mounted) return;
      setState(() {
        _narrative = narrative.isEmpty ? null : narrative;
        _narrativeLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      // 失敗してもテンプレで描画継続。エラー UI は出さない (ノイズ防止)。
      setState(() => _narrativeLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    if (result == null) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _classify,
          icon: const Icon(Icons.search, size: 18),
          label: const Text('いま何が起きてる？'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF5EDFF),
            foregroundColor: const Color(0xFF5B3EA8),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Color(0xFFDCC9F0)),
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            elevation: 0,
          ),
        ),
      );
    }
    return PatternDictionaryCard(
      result: result,
      narrative: _narrative,
      narrativeLoading: _narrativeLoading,
      onRefresh: _classify,
    );
  }
}
