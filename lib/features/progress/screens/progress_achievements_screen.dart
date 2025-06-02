import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider_pkg;
import '../../../widgets/calorie_weight_chart.dart';

import '../../../providers/providers.dart';
import '../../../models/calorie_savings_record.dart';
import '../../../models/weight_record.dart';
import '../../../design_system/templates/standard_page_layout.dart';
import '../../../routes/app_page.dart';
import '../../../widgets/daily_history_list.dart';

class ProgressAchievementsScreen extends ConsumerWidget implements AppPage {
  const ProgressAchievementsScreen({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(title: const Text('トントンヒストリー'));
  }

  @override
  Widget? buildFloatingActionButton(BuildContext context) => null;

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

        // Copy records so we can mutate when applying start date filter
        final records = List<CalorieSavingsRecord>.from(filteredRecords);

        if (startDate != null && records.isNotEmpty) {
          final firstAllowed = DateTime(startDate.year, startDate.month, startDate.day);
          records.removeWhere((r) => r.date.isBefore(firstAllowed));
        }

        return provider_pkg.Consumer<HealthProvider>(
          builder: (context, hp, child) {
            // Get weight records - for now, we'll use empty list
            // TODO: Implement weight history fetching
            final weightRecords = List.generate(
              records.length, 
              (index) => null as WeightRecord?,
            );

            final weeklyAvg = ref.watch(weeklyAverageSavingsProvider);
            final periodText = switch (period) {
              SelectedPeriod.week => '過去7日間',
              SelectedPeriod.month => '過去30日間',
              SelectedPeriod.quarter => '過去30日間', // Fallback to month if quarter is somehow selected
              SelectedPeriod.all => '全期間',
            };
            return StandardPageLayout(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              children: [
            // Add top spacing for the period selector
            const SizedBox(height: 16),
            // Period selector
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
                  ref.read(selectedPeriodProvider.notifier).state = newSelection.first;
                },
              ),
            ),
            const SizedBox(height: 24),
            
            // Chart section
            Container(
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
                    'カロリー貯金と体重の推移',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
            const SizedBox(height: 16),
            Card(
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
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.analytics_outlined,
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
                                '期間平均',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${weeklyAvg > 0 ? "+" : ""}${weeklyAvg.toStringAsFixed(0)} kcal/日',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
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
                            weeklyAvg > 0 ? Icons.thumb_up_outlined : Icons.info_outline,
                            size: 16,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              weeklyAvg > 0 
                                ? '$periodTextで順調にカロリー貯金ができています！'
                                : '$periodTextの貯金を確認してみましょう',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Daily history section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Text(
                    '日別履歴',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DailyHistoryList(
                  records: records,
                  showLatestFirst: true,
                ),
              ],
            ),
            const SizedBox(height: 80), // Bottom padding for navigation bar
          ],
        );
        },
      );
    },
  );
  }
}

