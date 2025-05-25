import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/monthly_progress_provider.dart';
import '../models/monthly_progress_summary.dart';
import '../models/daily_calorie_summary.dart';
import '../screens/savings_trend_screen.dart';

class MonthlyProgressWidget extends ConsumerWidget {
  const MonthlyProgressWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthlyProgressAsync = ref.watch(monthlyProgressSummaryProvider);
    final dailySummaryAsync = ref.watch(todayCalorieSummaryProvider);
    
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Calorie Savings',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            
            // Monthly progress
            monthlyProgressAsync.when(
              data: (progress) => _buildMonthlyProgress(context, progress),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error: $error'),
            ),
            
            const SizedBox(height: 24),
            Text(
              "Today's Summary",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            
            // Daily summary
            dailySummaryAsync.when(
              data: (summary) => _buildDailySummary(context, summary),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error: $error'),
            ),
            
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTargetSetter(context, ref),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SavingsTrendScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.trending_up),
                  tooltip: 'View Calorie Savings Trend',
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMonthlyProgress(BuildContext context, MonthlyProgressSummary progress) {
    final theme = Theme.of(context);
    final percentComplete = progress.completionPercentage;
    final isOnTrack = progress.isOnTrack;
    
    // Choose color based on progress
    final progressColor = isOnTrack ? Colors.green : Colors.orange;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Monthly Goal:', style: theme.textTheme.bodyMedium),
            Text(
              '${progress.targetMonthlyNetBurn.toStringAsFixed(0)} kcal',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Current Progress:', style: theme.textTheme.bodyMedium),
            Text(
              '${progress.currentMonthlyNetBurn.toStringAsFixed(0)} kcal',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: progress.currentMonthlyNetBurn >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentComplete / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${percentComplete.toStringAsFixed(1)}% Complete',
          style: theme.textTheme.bodySmall?.copyWith(
            color: progressColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Daily requirement or goal achievement message
        if (progress.remainingDaysInMonth > 0)
          progress.currentMonthlyNetBurn >= progress.targetMonthlyNetBurn
            // Goal already met
            ? Text(
                'Goal achieved! Exceeded by ${(progress.currentMonthlyNetBurn - progress.targetMonthlyNetBurn).toStringAsFixed(0)} kcal',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              )
            // Still working toward goal
            : Text(
                'Need ${progress.averageDailyNetBurnNeeded.abs().toStringAsFixed(0)} kcal/day to reach goal',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
      ],
    );
  }
  
  Widget _buildDailySummary(BuildContext context, DailyCalorieSummary summary) {
    final theme = Theme.of(context);
    final netColor = summary.isCalorieSurplus ? Colors.red : Colors.green;
    final dateFormat = DateFormat('EEEE, MMMM d');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateFormat.format(summary.date),
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Calories Consumed:', style: theme.textTheme.bodyMedium),
            Text(
              '${summary.totalCaloriesConsumed.toStringAsFixed(0)} kcal',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Calories Burned:', style: theme.textTheme.bodyMedium),
            Text(
              '${summary.totalCaloriesBurned.toStringAsFixed(0)} kcal',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        if (summary.workoutCalories != summary.totalCaloriesBurned)
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('  • Workout:', style: theme.textTheme.bodySmall),
                Text(
                  '${summary.workoutCalories.toStringAsFixed(0)} kcal',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Net Balance:', 
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '${summary.netCalories.toStringAsFixed(0)} kcal',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: netColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildTargetSetter(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        final currentTarget = await ref.read(monthlyTargetProvider.future);
          if (!context.mounted) return;
        final result = await showDialog<double>(
          context: context,
          builder: (context) => _TargetSettingDialog(currentTarget: currentTarget),
        );
        
        if (result != null) {
          final notifier = ref.read(monthlyTargetNotifierProvider.notifier);
          await notifier.updateTarget(result);
        }
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 40),
      ),
      child: const Text('Set Monthly Goal'),
    );
  }
}

class _TargetSettingDialog extends StatefulWidget {
  final double currentTarget;
  
  const _TargetSettingDialog({required this.currentTarget});
  
  @override
  _TargetSettingDialogState createState() => _TargetSettingDialogState();
}

class _TargetSettingDialogState extends State<_TargetSettingDialog> {
  late final TextEditingController _controller;
  double _sliderValue = 0;
  final double _minTarget = 7000; // ~0.25kg/month
  final double _maxTarget = 28000; // ~1kg/month
  
  @override
  void initState() {
    super.initState();
    _sliderValue = widget.currentTarget;
    _controller = TextEditingController(text: _sliderValue.toStringAsFixed(0));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Monthly Calorie Goal'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Current goal: ${widget.currentTarget.toStringAsFixed(0)} kcal/month',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Monthly Target (kcal)',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              final parsed = double.tryParse(value);
              if (parsed != null && parsed >= _minTarget && parsed <= _maxTarget) {
                setState(() {
                  _sliderValue = parsed;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Weight goal: ~${(_sliderValue / 7700).toStringAsFixed(1)} kg/month',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Slider(
            value: _sliderValue,
            min: _minTarget,
            max: _maxTarget,
            divisions: 20,
            label: _sliderValue.toStringAsFixed(0),
            onChanged: (value) {
              setState(() {
                _sliderValue = value;
                _controller.text = value.toStringAsFixed(0);
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_minTarget.toStringAsFixed(0)} kcal', style: Theme.of(context).textTheme.bodySmall),
              Text('${_maxTarget.toStringAsFixed(0)} kcal', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_sliderValue);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}