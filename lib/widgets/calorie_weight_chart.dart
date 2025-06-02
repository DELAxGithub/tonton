import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/calorie_savings_record.dart';
import '../models/weight_record.dart';
import '../theme/app_theme.dart';

/// カロリー貯金と体重を表示するデュアルアクシスチャート
class CalorieWeightChart extends StatelessWidget {
  final List<CalorieSavingsRecord> records;
  final List<WeightRecord?> weightRecords;

  const CalorieWeightChart({
    super.key,
    required this.records,
    required this.weightRecords,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Center(child: Text('データがありません'));
    }

    // Get valid weight records (non-null)
    final validWeights = <int, double>{};
    for (int i = 0; i < weightRecords.length && i < records.length; i++) {
      if (weightRecords[i] != null) {
        validWeights[i] = weightRecords[i]!.weight;
      }
    }

    if (validWeights.isEmpty) {
      // If no weight data, show only calorie savings as bar chart
      return _buildCaloriesOnlyChart(context);
    }

    // Calculate ranges
    final maxSavings = records.map((r) => r.cumulativeSavings).reduce(math.max);
    final minWeight = validWeights.values.reduce(math.min) - 2; // Add padding
    final maxWeight = validWeights.values.reduce(math.max) + 2;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (records.length - 1).toDouble(),
        minY: 0,
        maxY: maxSavings > 0 ? maxSavings * 1.1 : 1000, // Add 10% padding or default
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxSavings > 0 ? maxSavings / 5 : 1000,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.shade300,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= records.length) {
                  return const SizedBox.shrink();
                }
                
                // Show dates at appropriate intervals
                final showInterval = records.length > 30 ? 7 : 
                                    records.length > 14 ? 3 : 1;
                if (idx % showInterval != 0) {
                  return const SizedBox.shrink();
                }
                
                final date = records[idx].date;
                return Text(
                  '${date.month}/${date.day}',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: const Text('累積貯金 (kcal)', style: TextStyle(fontSize: 12)),
            axisNameSize: 20,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(
            axisNameWidget: const Text('体重 (kg)', style: TextStyle(fontSize: 12)),
            axisNameSize: 20,
            sideTitles: SideTitles(
              showTitles: validWeights.isNotEmpty,
              reservedSize: 48,
              getTitlesWidget: (value, meta) {
                // Map from calorie scale to weight scale
                final weightValue = minWeight + (value / maxSavings) * (maxWeight - minWeight);
                return Text(
                  weightValue.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          // Calorie savings bar chart
          LineChartBarData(
            spots: [
              for (int i = 0; i < records.length; i++)
                FlSpot(i.toDouble(), records[i].cumulativeSavings)
            ],
            isCurved: false,
            color: TontonColors.secondary,
            barWidth: 0,
            isStrokeCapRound: false,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: TontonColors.secondary.withValues(alpha: 0.3),
            ),
          ),
          // Weight line chart (if available)
          if (validWeights.isNotEmpty)
            LineChartBarData(
              spots: [
                for (final entry in validWeights.entries)
                  FlSpot(
                    entry.key.toDouble(), 
                    // Map weight to calorie scale for display
                    ((entry.value - minWeight) / (maxWeight - minWeight)) * maxSavings
                  )
              ],
              isCurved: true,
              color: TontonColors.primary,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: TontonColors.primary,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
            ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final idx = spot.x.toInt();
                if (idx < 0 || idx >= records.length) return null;
                
                final date = records[idx].date;
                final dateStr = '${date.month}/${date.day}';
                
                if (spot.barIndex == 0) {
                  // Calorie savings
                  return LineTooltipItem(
                    '$dateStr\n${spot.y.toInt()} kcal',
                    TextStyle(
                      color: TontonColors.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                } else {
                  // Weight
                  final weightEntry = validWeights.entries
                      .firstWhere((e) => e.key == idx, orElse: () => MapEntry(-1, 0));
                  if (weightEntry.key != -1) {
                    return LineTooltipItem(
                      '$dateStr\n${weightEntry.value.toStringAsFixed(1)} kg',
                      TextStyle(
                        color: TontonColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  }
                }
                return null;
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCaloriesOnlyChart(BuildContext context) {
    final maxSavings = records.map((r) => r.cumulativeSavings).reduce(math.max);
    
    return BarChart(
      BarChartData(
        barGroups: [
          for (int i = 0; i < records.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: records[i].cumulativeSavings,
                  color: TontonColors.secondary,
                  width: records.length > 30 ? 2 : 8,
                ),
              ],
            ),
        ],
        minY: 0,
        maxY: maxSavings > 0 ? maxSavings * 1.1 : 1000,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxSavings > 0 ? maxSavings / 5 : 1000,
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= records.length) {
                  return const SizedBox.shrink();
                }
                
                final showInterval = records.length > 30 ? 7 : 
                                    records.length > 14 ? 3 : 1;
                if (idx % showInterval != 0) {
                  return const SizedBox.shrink();
                }
                
                final date = records[idx].date;
                return Text(
                  '${date.month}/${date.day}',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: const Text('累積貯金 (kcal)', style: TextStyle(fontSize: 12)),
            axisNameSize: 20,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      ),
    );
  }
}