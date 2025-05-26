import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider_pkg;
import '../widgets/dual_axis_chart.dart';

import '../providers/calorie_savings_provider.dart';
import '../providers/health_provider.dart';
import '../providers/onboarding_start_date_provider.dart';
import '../design_system/organisms/hero_piggy_bank_display.dart';
import '../design_system/templates/standard_page_layout.dart';
import '../design_system/atoms/tonton_text.dart';
import '../design_system/atoms/tonton_card_base.dart';
import '../theme/tokens.dart';
import '../routes/app_page.dart';

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

    return allRecordsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (allRecords) {
        final startDate = ref.watch(onboardingStartDateProvider);

        // Filter records from start date up to yesterday
        final today = DateTime.now();
        final yesterday = DateTime(today.year, today.month, today.day - 1);
        final records = allRecords.where((r) {
          if (r.date.isAfter(yesterday)) return false;
          if (startDate != null && r.date.isBefore(startDate)) return false;
          return true;
        }).toList();

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

            return StandardPageLayout(
              children: [
            HeroPiggyBankDisplay(totalSavings: totalSavings),
            const SizedBox(height: Spacing.lg),
            SizedBox(
              height: 200,
              child: DualAxisChart(records: records, bodyFatMasses: bodyFatMasses),
            ),
            const SizedBox(height: Spacing.lg),
            const TontonCardBase(
              child: TontonText('Weekly feedback coming soon.'),
            ),
            const SizedBox(height: Spacing.lg),
            const TontonCardBase(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TontonText('Achievements'),
                  SizedBox(height: Spacing.sm),
                  TontonText('• Achievement 1'),
                  TontonText('• Achievement 2'),
                ],
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

