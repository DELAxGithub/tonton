import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../models/meal_record.dart';
import '../../../features/meal_logging/providers/meal_records_provider.dart';
import '../../../design_system/templates/standard_page_layout.dart';
import '../../../widgets/meal_record_card.dart';
import '../../../design_system/molecules/feedback/empty_state.dart';
import '../../../utils/date_formatter.dart';
import '../../../theme/tokens.dart' as tokens;
import '../../../models/calorie_savings_record.dart';
import '../../../theme/app_theme.dart';

class DailyMealsDetailScreen extends ConsumerWidget {
  final DateTime date;
  final CalorieSavingsRecord? savingsRecord;

  const DailyMealsDetailScreen({
    super.key,
    required this.date,
    this.savingsRecord,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealRecordsAsync = ref.watch(mealRecordsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormatter.formatLongDate(date)),
      ),
      body: mealRecordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('エラーが発生しました: $error'),
        ),
        data: (mealRecordsState) {
          final meals = ref.read(mealRecordsProvider.notifier).getMealRecordsForDate(date);
          
          return StandardPageLayout(
            children: [
              // Summary Card
              if (savingsRecord != null) ...[
                _buildSummaryCard(context, savingsRecord!),
                const SizedBox(height: tokens.Spacing.lg),
              ],
              
              // Meals Section
              Text(
                '食事記録',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: tokens.Spacing.sm),
              
              if (meals.isEmpty)
                EmptyState(
                  title: 'この日の食事記録はありません',
                  message: '食事が記録されていません',
                  icon: Icons.restaurant,
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: meals.length,
                  itemBuilder: (context, index) {
                    final meal = meals[index];
                    return MealRecordCard(
                      mealRecord: meal,
                      onTap: () {
                        // TODO: Implement edit functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('編集機能は準備中です'),
                          ),
                        );
                      },
                    );
                  },
                ),
              
              const SizedBox(height: 80), // Bottom padding
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildSummaryCard(BuildContext context, CalorieSavingsRecord record) {
    final isPositive = record.dailyBalance > 0;
    
    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'この日のサマリー',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMetric(
                  context,
                  '摂取カロリー',
                  '${record.caloriesConsumed.toStringAsFixed(0)} kcal',
                  Icons.restaurant,
                  TontonColors.primary,
                ),
                _buildMetric(
                  context,
                  '消費カロリー',
                  '${record.caloriesBurned.toStringAsFixed(0)} kcal',
                  Icons.local_fire_department,
                  TontonColors.warning,
                ),
                _buildMetric(
                  context,
                  '収支',
                  '${isPositive ? "+" : ""}${record.dailyBalance.toStringAsFixed(0)} kcal',
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  isPositive ? TontonColors.success : TontonColors.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMetric(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}