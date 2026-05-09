import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../features/progress/providers/selected_period_provider.dart';
import '../models/calorie_savings_record.dart';
import '../models/weight_record.dart';
import '../utils/weight_loss_calculator.dart';

/// 3 線並走の体重トレンドチャート。
///
/// 縦軸 = 実体重 (kg)、開始体重 ([startingBodyWeightKg]) を上端アンカーに据えて
/// 下に向かって描画する。3 系列をすべて同じ kg 軸で重ねるので二重軸不要。
///
/// - **計画 (灰破線)**: [idealKgList] (週次%ペース由来) — null 区間は描画スキップ
/// - **理論 (ピンク)**: 累積カロリー貯金 ÷ 7700 を [startingBodyWeightKg] から引いた値
/// - **実測 (青)**: HealthKit 体重 ([weightRecords]) — null 区間は描画スキップ
///
/// 期間 ([period]) に応じて左軸の tick 間隔を自動切替する:
/// 週=0.1kg / 月=0.25kg / 3ヶ月=0.5kg / 全期間=範囲から自動。
class ThreeLineWeightChart extends StatelessWidget {
  final List<CalorieSavingsRecord> records;
  final List<WeightRecord?> weightRecords;
  final List<double?> idealKgList;
  final double startingBodyWeightKg;
  final SelectedPeriod period;

  const ThreeLineWeightChart({
    super.key,
    required this.records,
    required this.weightRecords,
    required this.idealKgList,
    required this.startingBodyWeightKg,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Center(child: Text('データがありません'));
    }

    // 理論値: cumulative savings (kcal) を kg に変換して開始体重から引く。
    final theoryKgs = <double>[
      for (final r in records)
        startingBodyWeightKg -
            (r.cumulativeSavings / WeightLossCalculator.kcalPerKg),
    ];

    // y 範囲は 3 系列 + 開始体重から決める。
    final allValues = <double>[
      startingBodyWeightKg,
      ...theoryKgs,
      ...idealKgList.whereType<double>(),
      for (final w in weightRecords)
        if (w != null) w.weight,
    ];
    final rawMin = allValues.reduce(math.min);
    final rawMax = allValues.reduce(math.max);

    final tick = _tickIntervalFor(period: period, range: rawMax - rawMin);

    // tick 境界に揃えて余白を 1 ティック分とる。
    final paddedMin =
        ((rawMin / tick).floor() * tick - tick * 0.5).clamp(0.0, double.infinity);
    final paddedMax = (rawMax / tick).ceil() * tick + tick * 0.5;

    // X 軸ラベル間引き間隔
    final xLabelStride = records.length > 30
        ? 7
        : records.length > 14
            ? 3
            : 1;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (records.length - 1).toDouble(),
        minY: paddedMin,
        maxY: paddedMax,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: tick,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.shade300, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= records.length) {
                  return const SizedBox.shrink();
                }
                if (idx % xLabelStride != 0) return const SizedBox.shrink();
                final date = records[idx].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${date.month}/${date.day}',
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: const Text(
              '体重 (kg)',
              style: TextStyle(fontSize: 11),
            ),
            axisNameSize: 18,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              interval: tick,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        lineBarsData: [
          // ① 計画ペース (理想体重 trajectory) — 灰の破線
          LineChartBarData(
            spots: [
              for (int i = 0; i < records.length; i++)
                if (idealKgList.length > i && idealKgList[i] != null)
                  FlSpot(i.toDouble(), idealKgList[i]!),
            ],
            isCurved: false,
            color: Colors.grey.shade500,
            barWidth: 1.8,
            dashArray: const [5, 4],
            dotData: const FlDotData(show: false),
          ),
          // ② 理論 (カロリー貯金 ÷ 7700) — ピンク
          LineChartBarData(
            spots: [
              for (int i = 0; i < records.length; i++)
                FlSpot(i.toDouble(), theoryKgs[i]),
            ],
            isCurved: false,
            color: const Color(0xFFFF9AA2), // pigPink
            barWidth: 2.2,
            dotData: FlDotData(
              show: records.length <= 14,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: const Color(0xFFFF9AA2),
                  strokeWidth: 1.5,
                  strokeColor: Colors.white,
                );
              },
            ),
          ),
          // ③ 実測 (HealthKit) — 青
          LineChartBarData(
            spots: [
              for (int i = 0; i < records.length; i++)
                if (weightRecords.length > i && weightRecords[i] != null)
                  FlSpot(i.toDouble(), weightRecords[i]!.weight),
            ],
            isCurved: true,
            color: const Color(0xFF4A90E2), // info blue
            barWidth: 2.5,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3.5,
                  color: const Color(0xFF4A90E2),
                  strokeWidth: 1.5,
                  strokeColor: Colors.white,
                );
              },
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots.map((spot) {
              final idx = spot.x.toInt();
              if (idx < 0 || idx >= records.length) return null;
              final date = records[idx].date;
              final dateStr = '${date.month}/${date.day}';
              final label = switch (spot.barIndex) {
                0 => '計画',
                1 => '理論',
                2 => '実測',
                _ => '',
              };
              final color = switch (spot.barIndex) {
                0 => Colors.grey.shade700,
                1 => const Color(0xFFE0576A),
                2 => const Color(0xFF2A6BB0),
                _ => Colors.black,
              };
              return LineTooltipItem(
                '$dateStr\n$label: ${spot.y.toStringAsFixed(2)} kg',
                TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  /// 期間別に y 軸の tick 間隔 (kg) を返す。
  /// 全期間時は実データの幅を見て自動調整する。
  static double _tickIntervalFor({
    required SelectedPeriod period,
    required double range,
  }) {
    switch (period) {
      case SelectedPeriod.week:
        return 0.1;
      case SelectedPeriod.month:
        return 0.25;
      case SelectedPeriod.quarter:
        return 0.5;
      case SelectedPeriod.all:
        if (range <= 1) return 0.1;
        if (range <= 3) return 0.25;
        if (range <= 6) return 0.5;
        return 1.0;
    }
  }
}
