import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../models/calorie_savings_record.dart';
import '../providers/calorie_savings_provider.dart';
import '../design_system/atoms/tonton_button.dart';
import '../utils/icon_mapper.dart';
import '../routes/router.dart';

class SavingsTrendScreen extends ConsumerWidget {
  const SavingsTrendScreen({super.key});
  
  // Show dialog to edit monthly goal
  void _showGoalEditDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(
      text: ref.read(monthlyCalorieGoalProvider).toString()
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('月間目標設定'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '目標カロリー (kcal)',
            suffixText: 'kcal',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null && value > 0) {
                ref.read(monthlyCalorieGoalProvider.notifier).setGoal(value);
                Navigator.pop(context);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savingsRecordsAsync = ref.watch(calorieSavingsDataProvider);
    final monthlyTarget = ref.watch(monthlyCalorieGoalProvider);

    return savingsRecordsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (savingsRecords) {
        return Scaffold(
      appBar: AppBar(
        title: const Text('カロリー貯金'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Tab selector (先月 / 今月)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('先月', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 16),
                Container(
                  width: 120,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 60,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Text('今月', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TontonButton.primary(
              label: '貯金をつかってご褒美！',
              leading: TontonIcons.present,
              onPressed: () => context.push(TontonRoutes.useSavings),
            ),
          ),
          
          // Monthly target display with edit button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'カロリー貯金 ${monthlyTarget.toStringAsFixed(0)} kcal',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showGoalEditDialog(context, ref),
                  tooltip: '月間目標を設定',
                ),
              ],
            ),
          ),
          
          // Cumulative savings line chart
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
              child: savingsRecords.isEmpty
                ? const Center(child: Text('データがありません'))
                : CombinedChart(
                    records: savingsRecords,
                    monthlyTarget: monthlyTarget,
                  ),
            ),
          ),
          
          // Daily balance bars chart
          SizedBox(
            height: 120,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
              child: savingsRecords.isEmpty
                ? const SizedBox()
                : DailyBalanceBars(
                    records: savingsRecords,
                  ),
            ),
          ),
          
          // Data Table
          Expanded(
            flex: 2,
            child: SavingsDataTable(records: savingsRecords),
          ),

        ],
      ),
    );
  },
);
}

class CombinedChart extends StatelessWidget {
  final List<CalorieSavingsRecord> records;
  final double monthlyTarget;
  
  const CombinedChart({
    super.key,
    required this.records,
    required this.monthlyTarget,
  });
  
  @override
  Widget build(BuildContext context) {
    // Calculate min and max values for Y axis
    double minY = 0;
    double maxY = monthlyTarget * 1.1;
    
    for (final record in records) {
      if (record.cumulativeSavings > maxY) {
        maxY = record.cumulativeSavings * 1.1;
      }
      if (record.cumulativeSavings < minY) {
        minY = record.cumulativeSavings * 1.1;
      }
    }
    
    minY = minY > -500 ? -500 : minY;
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 2000,
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= records.length || index % 2 != 0) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    records[index].dayOfMonth.toString(),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        minX: 0,
        maxX: (records.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          // Cumulative savings line
          LineChartBarData(
            spots: List.generate(records.length, (index) {
              return FlSpot(index.toDouble(), records[index].cumulativeSavings);
            }),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withValues(alpha: 0.2),
            ),
          ),
        ],
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            // Monthly target line
            HorizontalLine(
              y: monthlyTarget,
              color: Colors.red,
              strokeWidth: 2,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                padding: const EdgeInsets.only(right: 5, bottom: 5),
                style: const TextStyle(color: Colors.red),
                labelResolver: (line) => '目標: ${monthlyTarget.toStringAsFixed(0)} kcal',
              ),
            ),
            // Zero line
            HorizontalLine(
              y: 0,
              color: Colors.grey,
              strokeWidth: 1,
            ),
          ],
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor:
                Colors.blue.withValues(alpha: 0.8),
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final index = touchedSpot.x.toInt();
                if (index >= 0 && index < records.length) {
                  final record = records[index];
                  return LineTooltipItem(
                    '${record.date.day}日: ${record.cumulativeSavings.toStringAsFixed(0)} kcal',
                    const TextStyle(color: Colors.white),
                  );
                } else {
                  return null;
                }
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}

class DailyBalanceBars extends StatelessWidget {
  final List<CalorieSavingsRecord> records;
  
  const DailyBalanceBars({
    super.key,
    required this.records,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.center,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.black87,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final record = records[group.x.toInt()];
                return BarTooltipItem(
                  '${record.date.day}日: ${record.dailyBalance > 0 ? "+" : ""}${record.dailyBalance.toStringAsFixed(0)} kcal',
                  const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= records.length || index % 3 != 0) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      records[index].dayOfMonth.toString(),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barGroups: List.generate(records.length, (index) {
            final record = records[index];
            final isPositive = record.dailyBalance >= 0;
            
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: record.dailyBalance,
                  color: isPositive ? Colors.green : Colors.red,
                  width: 12,
                  borderRadius: BorderRadius.vertical(
                    top: isPositive ? const Radius.circular(4) : Radius.zero,
                    bottom: !isPositive ? const Radius.circular(4) : Radius.zero,
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class SavingsDataTable extends StatelessWidget {
  final List<CalorieSavingsRecord> records;

  const SavingsDataTable({
    super.key,
    required this.records,
  });
  
  @override
  Widget build(BuildContext context) {
    
    return Column(
      children: [
        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: const Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  '日付',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  '摂取',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  '消費',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  '収支',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        
        // Table Body
        Expanded(
          child: ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              final isPositive = record.dailyBalance >= 0;
              
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        record.dayOfMonth.toString(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        '${record.caloriesConsumed.toStringAsFixed(0)}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        '${record.caloriesBurned.toStringAsFixed(0)}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        '${isPositive ? '+' : ''}${record.dailyBalance.toStringAsFixed(0)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isPositive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Removing the BalanceValuePainter class due to compatibility issues
// We'll add values directly to the bar chart instead