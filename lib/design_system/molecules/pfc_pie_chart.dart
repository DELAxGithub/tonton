import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

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
        color: Theme.of(context).colorScheme.primary,
        title: 'P',
        radius: 30,
        titleStyle: Theme.of(context).textTheme.labelSmall,
      ),
      PieChartSectionData(
        value: fat,
        color: Theme.of(context).colorScheme.secondary,
        title: 'F',
        radius: 30,
        titleStyle: Theme.of(context).textTheme.labelSmall,
      ),
      PieChartSectionData(
        value: carbs,
        color: Theme.of(context).colorScheme.tertiary,
        title: 'C',
        radius: 30,
        titleStyle: Theme.of(context).textTheme.labelSmall,
      ),
    ];

    return PieChart(
      PieChartData(sections: sections, centerSpaceRadius: 18),
      swapAnimationDuration: const Duration(milliseconds: 300),
    );
  }
}
