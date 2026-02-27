import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/colors.dart';

class PfcPieChart extends StatelessWidget {
  final double protein;
  final double fat;
  final double carbs;

  const PfcPieChart({
    super.key,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  @override
  Widget build(BuildContext context) {
    final sections = [
      PieChartSectionData(
        value: protein,
        color: TontonColors.proteinColor,
        title: 'P',
        radius: 30,
        titleStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
      ),
      PieChartSectionData(
        value: fat,
        color: TontonColors.fatColor,
        title: 'F',
        radius: 30,
        titleStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
      ),
      PieChartSectionData(
        value: carbs,
        color: TontonColors.carbsColor,
        title: 'C',
        radius: 30,
        titleStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
      ),
    ];

    return PieChart(
      PieChartData(sections: sections, centerSpaceRadius: 18),
      swapAnimationDuration: const Duration(milliseconds: 300),
    );
  }
}
