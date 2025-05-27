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
    final maxSavings = records.map((r) => r.cumulativeSavings).reduce(math.max);

    // Scale factor to overlay cumulative savings on the weight axis
    final scale = (maxFatMass - minFatMass) / (maxSavings == 0 ? 1 : maxSavings);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (records.length - 1).toDouble(),
        minY: minFatMass,
        maxY: maxFatMass,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxFatMass - minFatMass) / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.shade300,
            strokeWidth: 1,
          ),
        ),
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
          leftTitles: AxisTitles(
            axisNameWidget: const Text('累積貯金(kcal)'),
            axisNameSize: 28,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (value, meta) {
                final savings = ((value - minFatMass) / scale).round();
                return Text('$savings');
              },
            ),
          ),
          rightTitles: AxisTitles(
            axisNameWidget: const Text('体重(kg)'),
            axisNameSize: 28,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (value, meta) => Text(value.toStringAsFixed(1)),
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
            dotData: const FlDotData(show: true),
          ),
          LineChartBarData(
            spots: [
              for (int i = 0; i < records.length; i++)
                FlSpot(i.toDouble(), minFatMass + records[i].cumulativeSavings * scale)
            ],
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}