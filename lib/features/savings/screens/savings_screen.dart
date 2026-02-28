import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as provider_pkg;

import '../../../providers/providers.dart';
import '../../../models/calorie_savings_record.dart';
import '../../../models/weight_record.dart';
import '../../../design_system/organisms/hero_piggy_bank_display.dart';
import '../../../design_system/atoms/tonton_button.dart';
import '../../../widgets/calorie_weight_chart.dart';
import '../../../widgets/daily_history_list.dart';
import '../../../routes/router.dart';
import '../../../theme/colors.dart';
import '../../../utils/icon_mapper.dart';

/// 貯金タブのメイン画面
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

        final cumulativeSavings =
            records.isNotEmpty ? records.last.cumulativeSavings : 0.0;
        final weeklyAvg = ref.watch(weeklyAverageSavingsProvider);
        final periodText = switch (period) {
          SelectedPeriod.week => '過去7日間',
          SelectedPeriod.month => '過去30日間',
          SelectedPeriod.quarter => '過去30日間',
          SelectedPeriod.all => '全期間',
        };

        return provider_pkg.Consumer<HealthProvider>(
          builder: (context, hp, child) {
            final weightRecords = List.generate(
              records.length,
              (index) => null as WeightRecord?,
            );

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'カロリー貯金',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
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

                    // 推移チャート
                    Container(
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
                            'カロリー貯金の推移',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 240,
                            child: CalorieWeightChart(
                              records: records,
                              weightRecords: weightRecords,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ご褒美ボタン
                    Center(
                      child: TontonButton.primary(
                        label: 'ご褒美を使う',
                        icon: TontonIcons.present,
                        onPressed: () =>
                            context.push(TontonRoutes.useSavings),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 日別履歴
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      child: Text(
                        '日別履歴',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DailyHistoryList(
                      records: records,
                      showLatestFirst: true,
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            );
          },
        );
      },
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
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
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
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer
                                      .withValues(alpha: 0.7),
                                ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${cumulativeSavings > 0 ? "+" : ""}${cumulativeSavings.toStringAsFixed(0)} kcal',
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
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
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      weeklyAvg > 0
                          ? '$periodTextの平均: +${weeklyAvg.toStringAsFixed(0)} kcal/日'
                          : '$periodTextの貯金を確認してみましょう',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.8),
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
