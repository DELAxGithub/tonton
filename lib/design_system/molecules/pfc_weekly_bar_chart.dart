import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../models/daily_pfc_summary.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart' as app_theme;

/// 7-day stacked bar chart showing PFC breakdown per day.
class PfcWeeklyBarChart extends StatelessWidget {
  final List<DailyPfcSummary> weekData; // exactly 7 items

  const PfcWeeklyBarChart({super.key, required this.weekData});

  @override
  Widget build(BuildContext context) {
    final maxY = _calculateMaxY();

    return SizedBox(
      height: 120,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barGroups: _buildBarGroups(),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= weekData.length) {
                    return const SizedBox.shrink();
                  }
                  final isToday = index == weekData.length - 1;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      weekData[index].dayLabel,
                      style: TextStyle(
                        color: isToday
                            ? app_theme.TontonColors.textPrimary
                            : app_theme.TontonColors.textSecondary,
                        fontSize: 11,
                        fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barTouchData: BarTouchData(enabled: false),
        ),
        swapAnimationDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  double _calculateMaxY() {
    double max = 0;
    for (final day in weekData) {
      final total = day.totalGrams;
      if (total > max) max = total;
    }
    // Add 10% padding, minimum 100 to avoid empty chart
    return max > 0 ? max * 1.1 : 100;
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(weekData.length, (index) {
      final day = weekData[index];
      final isToday = index == weekData.length - 1;
      final p = day.pfc.protein;
      final f = day.pfc.fat;
      final c = day.pfc.carbohydrate;
      final total = p + f + c;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: total,
            color: Colors.transparent,
            width: isToday ? 18 : 14,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            rodStackItems: [
              // Protein (bottom)
              BarChartRodStackItem(0, p, TontonColors.proteinColor),
              // Fat (middle)
              BarChartRodStackItem(p, p + f, TontonColors.fatColor),
              // Carbs (top)
              BarChartRodStackItem(p + f, total, TontonColors.carbsColor),
            ],
          ),
        ],
      );
    });
  }
}
