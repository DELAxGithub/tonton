import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart' as provider_pkg;

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

class DualAxisChart extends StatelessWidget {
  final List<CalorieSavingsRecord> records;
  final List<double> weights;

  const DualAxisChart({
    super.key,
    required this.records,
    required this.weights,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty || weights.isEmpty) {
      return const Center(child: Text('No data'));
    }

    final minWeight = weights.reduce(math.min);
    final maxWeight = weights.reduce(math.max);
    final maxSavings =
        records.map((r) => r.cumulativeSavings).reduce(math.max);

    final scale = (maxWeight - minWeight) / (maxSavings == 0 ? 1 : maxSavings);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (records.length - 1).toDouble(),
        minY: minWeight,
        maxY: maxWeight,
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 20,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= records.length || idx % 2 != 0) {
                  return const SizedBox.shrink();
                }
                return Text('${records[idx].dayOfMonth}');
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                final savings = ((value - minWeight) / scale).round();
                return Text('$savings');
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (int i = 0; i < weights.length; i++)
                FlSpot(i.toDouble(), weights[i])
            ],
            isCurved: true,
            color: Colors.orange,
            barWidth: 3,
            dotData: const FlDotData(show: false),
          ),
          LineChartBarData(
            spots: [
              for (int i = 0; i < records.length; i++)
                FlSpot(i.toDouble(), minWeight + records[i].cumulativeSavings * scale)
            ],
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}
