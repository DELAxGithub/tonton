import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/providers.dart';
import '../../../models/calorie_savings_record.dart';
import '../../../models/weight_record.dart';
import '../../../design_system/organisms/hero_piggy_bank_display.dart';
import '../../../design_system/atoms/tonton_button.dart';
import '../../../utils/weight_loss_calculator.dart';
import '../../../widgets/three_line_weight_chart.dart';
import '../../../routes/router.dart';
import '../../../utils/icon_mapper.dart';
import '../../health/providers/weight_history_provider.dart';
import '../../progress/providers/ideal_weight_trajectory_provider.dart';
import '../../progress/widgets/monthly_goal_progress_card.dart';
import '../models/pattern_narrative.dart';
import '../services/pattern_matching_service.dart';
import '../services/pattern_narrative_service.dart';
import '../models/dietary_pattern.dart';
import '../widgets/pattern_dictionary_card.dart';

/// 貯金タブ。結果軸（カロリー貯金 + 体重 + 月次達成度 + ご褒美）に集約。
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
      data: (_) {
        final startDate = ref.watch(onboardingStartDateProvider);

        final records = List<CalorieSavingsRecord>.from(filteredRecords);

        if (startDate != null && records.isNotEmpty) {
          final firstAllowed = DateTime(
            startDate.year,
            startDate.month,
            startDate.day,
          );
          records.removeWhere((r) => r.date.isBefore(firstAllowed));
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
            records.isNotEmpty ? records.last.cumulativeSavings : 0.0;
        final weeklyAvg = ref.watch(weeklyAverageSavingsProvider);
        final periodText = switch (period) {
          SelectedPeriod.week => '過去7日間',
          SelectedPeriod.month => '過去30日間',
          SelectedPeriod.quarter => '過去30日間',
          SelectedPeriod.all => '全期間',
        };

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

                // ヒーローカード
                const HeroPiggyBankDisplay(),
                const SizedBox(height: 20),

                // 累計サマリーカード
                _CumulativeSummaryCard(
                  cumulativeSavings: cumulativeSavings,
                  weeklyAvg: weeklyAvg,
                  periodText: periodText,
                ),
                const SizedBox(height: 20),

                // 月次目標達成度（記録タブから移植）
                const MonthlyGoalProgressCard(),
                const SizedBox(height: 20),

                // 期間セレクター
                Center(
                  child: SegmentedButton<SelectedPeriod>(
                    segments: const [
                      ButtonSegment(
                        value: SelectedPeriod.week,
                        label: Text('週'),
                      ),
                      ButtonSegment(
                        value: SelectedPeriod.month,
                        label: Text('月'),
                      ),
                      ButtonSegment(
                        value: SelectedPeriod.all,
                        label: Text('全期間'),
                      ),
                    ],
                    selected: {period},
                    onSelectionChanged: (Set<SelectedPeriod> newSelection) {
                      ref.read(selectedPeriodProvider.notifier).state =
                          newSelection.first;
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // 体重トレンドチャート (3線並走 / kg軸単独)
                Builder(
                  builder: (_) {
                    final startWeight = ref
                            .watch(userGoalsProvider)
                            .startingBodyWeightKg ??
                        ref.watch(userGoalsProvider).bodyWeightKg ??
                        (records.isNotEmpty &&
                                weightRecords.isNotEmpty &&
                                weightRecords.first != null
                            ? weightRecords.first!.weight
                            : 70.0);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ThreeLineChartCard(
                          records: records,
                          weightRecords: weightRecords,
                          idealKgList: idealWeightsKg,
                          startingBodyWeightKg: startWeight,
                          period: period,
                        ),
                        const SizedBox(height: 12),
                        _PatternMatchSection(
                          records: records,
                          weightRecords: weightRecords,
                          idealKgList: idealWeightsKg,
                          startingBodyWeightKg: startWeight,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),

                // ご褒美ボタン
                Center(
                  child: TontonButton.primary(
                    label: 'ご褒美を使う',
                    icon: TontonIcons.present,
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

/// 3 線並走チャート + 直下の 3 セル数値リードアウト (計画/理論/実測)。
/// 旧 ExpectedVsActualCard を吸収する役割。
class _ThreeLineChartCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // Compute deltas from start weight for the readout.
    String fmtDelta(double kg) {
      final sign = kg >= 0 ? '+' : '−';
      return '$sign${kg.abs().toStringAsFixed(2)}kg';
    }

    double? planDeltaKg;
    if (idealKgList.isNotEmpty) {
      // Last non-null ideal point.
      for (final ideal in idealKgList.reversed) {
        if (ideal != null) {
          planDeltaKg = ideal - startingBodyWeightKg;
          break;
        }
      }
    }

    double? theoryDeltaKg;
    if (records.isNotEmpty) {
      theoryDeltaKg =
          -records.last.cumulativeSavings / WeightLossCalculator.kcalPerKg;
    }

    double? actualDeltaKg;
    for (final w in weightRecords.reversed) {
      if (w != null) {
        actualDeltaKg = w.weight - startingBodyWeightKg;
        break;
      }
    }

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
          Text(
            '体重トレンド',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '計画 (灰破線) / 理論 = カロリー貯金÷7700 / 実測 (HealthKit)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
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
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.5),
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

/// 累計貯金サマリーカード
class _CumulativeSummaryCard extends StatelessWidget {
  final double cumulativeSavings;
  final double weeklyAvg;
  final String periodText;

  const _CumulativeSummaryCard({
    required this.cumulativeSavings,
    required this.weeklyAvg,
    required this.periodText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.savings_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '累計カロリー貯金',
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer
                              .withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${cumulativeSavings > 0 ? "+" : ""}${cumulativeSavings.toStringAsFixed(0)} kcal',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    weeklyAvg > 0
                        ? Icons.thumb_up_outlined
                        : Icons.info_outline,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      weeklyAvg > 0
                          ? '$periodTextの平均: +${weeklyAvg.toStringAsFixed(0)} kcal/日'
                          : '$periodTextの貯金を確認してみましょう',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.8),
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
            backgroundColor: const Color(0xFFB08AFF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
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
