import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart' as provider_pkg;
import '../widgets/dual_axis_chart.dart';

import '../providers/calorie_savings_provider.dart';
import '../models/calorie_savings_record.dart';
import '../providers/health_provider.dart';
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
    final records = ref.watch(calorieSavingsDataProvider);
    final totalSavings =
        records.isNotEmpty ? records.last.cumulativeSavings : 0.0;
    final weights = records
        .map((r) => 70 - r.cumulativeSavings / 7700)
        .toList(growable: false);

    return provider_pkg.Consumer<HealthProvider>(
      builder: (context, hp, child) {
        return StandardPageLayout(
          children: [
            HeroPiggyBankDisplay(totalSavings: totalSavings),
            const SizedBox(height: Spacing.lg),
            SizedBox(
              height: 200,
              child: DualAxisChart(records: records, weights: weights),
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
  }
}

