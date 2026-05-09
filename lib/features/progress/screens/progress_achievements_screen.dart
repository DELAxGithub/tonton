import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/providers.dart';
import '../../../models/calorie_savings_record.dart';
import '../../../design_system/templates/standard_page_layout.dart';
import '../../../widgets/daily_history_list.dart';

/// 記録タブ。食事ログの振り返りに特化（チャート/累計/達成度は貯金タブへ寄せた）。
class ProgressAchievementsScreen extends ConsumerWidget {
  const ProgressAchievementsScreen({super.key});

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

        return SafeArea(
          child: StandardPageLayout(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            children: [
              const SizedBox(height: 16),
              Text(
                '食事の記録',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '日々の食事を振り返ってみましょう',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 16),
              // Period selector (filters which days appear in the list).
              Center(
                child: SegmentedButton<SelectedPeriod>(
                  segments: const [
                    ButtonSegment(value: SelectedPeriod.week, label: Text('週')),
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
              const SizedBox(height: 24),
              // Daily history list with meal-name chip previews.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Text(
                  '日別履歴',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DailyHistoryList(records: records, showLatestFirst: true),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }
}
