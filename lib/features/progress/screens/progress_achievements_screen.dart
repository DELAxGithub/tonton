import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider_pkg;
import '../../../widgets/dual_axis_chart.dart';

import '../../../providers/providers.dart';
import '../providers/selected_period_provider.dart';
import '../../../models/calorie_savings_record.dart';
import '../../../design_system/organisms/hero_piggy_bank_display.dart';
import '../../../design_system/templates/standard_page_layout.dart';
import '../../../theme/tokens.dart';
import '../../../routes/app_page.dart';

class ProgressAchievementsScreen extends ConsumerWidget implements AppPage {
  const ProgressAchievementsScreen({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(title: const Text('Progress & Achievements'));
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

        final totalSavings =
            records.isNotEmpty ? records.last.cumulativeSavings : 0.0;

        // Body fat mass calculation using latest available data
        final placeholderMasses = records
            .map((r) {
              final weight = 70 - r.cumulativeSavings / 7700;
              return weight * 0.2;
            })
            .toList(growable: false);

        return provider_pkg.Consumer<HealthProvider>(
          builder: (context, hp, child) {
            final latestMass = hp.yesterdayWeight?.bodyFatMass;
            final bodyFatMasses = latestMass != null
                ? List<double>.filled(records.length, latestMass)
                : placeholderMasses;

            final weeklyAvg = ref.watch(weeklyAverageSavingsProvider);
            final periodText = switch (period) {
              SelectedPeriod.week => '過去7日間',
              SelectedPeriod.month => '過去30日間',
              SelectedPeriod.quarter => '過去90日間',
              SelectedPeriod.all => '全期間',
            };
            return StandardPageLayout(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              children: [
            HeroPiggyBankDisplay(totalSavings: totalSavings),
            const SizedBox(height: 16),
            Wrap(
              spacing: Spacing.sm,
              children: [
                FilterChip(
                  label: const Text('7日'),
                  selected: period == SelectedPeriod.week,
                  onSelected: (_) =>
                      ref.read(selectedPeriodProvider.notifier).state = SelectedPeriod.week,
                ),
                FilterChip(
                  label: const Text('30日'),
                  selected: period == SelectedPeriod.month,
                  onSelected: (_) =>
                      ref.read(selectedPeriodProvider.notifier).state = SelectedPeriod.month,
                ),
                FilterChip(
                  label: const Text('90日'),
                  selected: period == SelectedPeriod.quarter,
                  onSelected: (_) =>
                      ref.read(selectedPeriodProvider.notifier).state = SelectedPeriod.quarter,
                ),
                FilterChip(
                  label: const Text('全期間'),
                  selected: period == SelectedPeriod.all,
                  onSelected: (_) =>
                      ref.read(selectedPeriodProvider.notifier).state = SelectedPeriod.all,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: DualAxisChart(records: records, bodyFatMasses: bodyFatMasses),
            ),
            const SizedBox(height: 24),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('$periodTextで平均 +${weeklyAvg.toStringAsFixed(0)} kcal/日 のカロリー貯金ができました！'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
        },
      );
    },
  );
  }
}

