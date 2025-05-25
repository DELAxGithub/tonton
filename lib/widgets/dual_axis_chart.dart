import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/calorie_savings_record.dart';

class DualAxisChart extends StatelessWidget {
  final List<CalorieSavingsRecord> records;
  final List<double> bodyFatMasses;

  const DualAxisChart({
    super.key,
    required this.records,
    required this.bodyFatMasses,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty || bodyFatMasses.isEmpty) {
      return const Center(child: Text('No data'));
    }

    final minFatMass = bodyFatMasses.reduce(math.min);
    final maxFatMass = bodyFatMasses.reduce(math.max);
    final maxSavings =
        records.map((r) => r.cumulativeSavings).reduce(math.max);

    final scale = (maxFatMass - minFatMass) / (maxSavings == 0 ? 1 : maxSavings);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (records.length - 1).toDouble(),
        minY: minFatMass,
        maxY: maxFatMass,
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
                final savings = ((value - minFatMass) / scale).round();
                return Text('$savings');
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (int i = 0; i < bodyFatMasses.length; i++)
                FlSpot(i.toDouble(), bodyFatMasses[i])
            ],
            isCurved: true,
            color: Colors.orange,
            barWidth: 3,
            dotData: const FlDotData(show: false),
          ),
          LineChartBarData(
            spots: [
              for (int i = 0; i < records.length; i++)
                FlSpot(i.toDouble(), minFatMass + records[i].cumulativeSavings * scale)
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