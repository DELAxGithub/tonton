import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../features/meal_logging/providers/meal_records_provider.dart';
import '../../../features/meal_logging/meal_entry_actions.dart';
import '../../../routes/router.dart';
import '../../../theme/colors.dart' as theme_colors;
import '../../../design_system/templates/standard_page_layout.dart';
import '../../../widgets/meal_record_card.dart';
import '../../../design_system/molecules/feedback/empty_state.dart';
import '../../../utils/date_formatter.dart';
import '../../../theme/tokens.dart' as tokens;
import '../../../models/calorie_savings_record.dart';
import '../../../theme/app_theme.dart';
import '../../../core/providers/realtime_calories_provider.dart';

/// Fetches HealthKit burned calories for a specific date.
final _dailyBurnedCaloriesProvider =
    FutureProvider.family<double, DateTime>((ref, date) async {
  final service = ref.watch(dailySummaryServiceProvider);
  final summary = await service.getDailySummary(date);
  return summary.caloriesBurned;
});

class DailyMealsDetailScreen extends ConsumerWidget {
  final DateTime date;

  const DailyMealsDetailScreen({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealRecordsAsync = ref.watch(mealRecordsProvider);
    final burnedAsync = ref.watch(_dailyBurnedCaloriesProvider(date));

    return Scaffold(
      appBar: AppBar(title: Text(DateFormatter.formatLongDate(date))),
      floatingActionButton: GestureDetector(
        onTap: () => showMealInputOptions(context),
        onLongPress: () => goToMealCamera(context),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: theme_colors.TontonColors.pigPink,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Color(0x40FF9AA2),
                offset: Offset(0, 4),
                blurRadius: 16,
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
      body: mealRecordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('エラーが発生しました: $error')),
        data: (mealRecordsState) {
          final meals =
              mealRecordsState.records.where((record) {
                final consumed = record.consumedAt.toLocal();
                return consumed.year == date.year &&
                    consumed.month == date.month &&
                    consumed.day == date.day;
              }).toList();

          final totalCalories = meals.fold<double>(
            0.0,
            (sum, record) => sum + record.calories,
          );

          final burnedCalories = burnedAsync.maybeWhen(
            data: (v) => v,
            orElse: () => 0.0,
          );

          final displayRecord = CalorieSavingsRecord.fromRaw(
            date: date,
            caloriesConsumed: totalCalories,
            caloriesBurned: burnedCalories,
          );

          return StandardPageLayout(
            children: [
              // Summary Card
              _buildSummaryCard(context, displayRecord),
              const SizedBox(height: tokens.Spacing.lg),

              // Meals Section
              Text(
                '食事記録',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                        context.push(TontonRoutes.editMeal, extra: meal);
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
                  Colors.red, // Use red for better visibility
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
