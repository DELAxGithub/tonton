import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../atoms/tonton_card_base.dart';
import '../../theme/tokens.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../utils/icon_mapper.dart';
import '../../providers/providers.dart';

/// A widget that displays three horizontal cards showing calorie summary
/// - Consumed calories (green)
/// - Burned calories (orange)
/// - Net savings (pink)
class CalorieSummaryRow extends ConsumerWidget {
  const CalorieSummaryRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get today's meal records to calculate consumed calories
    final todayMeals = ref.watch(todaysMealRecordsProvider);
    final consumedCalories = todayMeals.fold<double>(
      0,
      (sum, meal) => sum + meal.calories,
    );

    // Get burned calories from realtime summary
    final realtimeSummaryAsync = ref.watch(realtimeDailySummaryProvider);
    final burnedCalories = realtimeSummaryAsync.maybeWhen(
      data: (summary) => summary.caloriesBurned,
      orElse: () => 0.0,
    );

    // Calculate net savings (burned - consumed)
    final netSavings = burnedCalories - consumedCalories;

    return Row(
      children: [
        // Consumed Calories Card
        Expanded(
          child: _CalorieCard(
            icon: TontonIcons.food,
            iconColor: TontonColors.systemGreen,
            title: '摂取',
            value: consumedCalories.toStringAsFixed(0),
            unit: 'kcal',
          ),
        ),
        const SizedBox(width: Spacing.sm),

        // Burned Calories Card
        Expanded(
          child: _CalorieCard(
            icon: TontonIcons.workout,
            iconColor: TontonColors.systemOrange,
            title: '消費',
            value: burnedCalories.toStringAsFixed(0),
            unit: 'kcal',
          ),
        ),
        const SizedBox(width: Spacing.sm),

        // Net Savings Card
        Expanded(
          child: _CalorieCard(
            icon: TontonIcons.piggybank,
            iconColor: TontonColors.pigPink,
            title: '貯金',
            value: netSavings.toStringAsFixed(0),
            unit: 'kcal',
            isHighlighted: true,
          ),
        ),
      ],
    );
  }
}

/// Individual calorie card widget
class _CalorieCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String unit;
  final bool isHighlighted;

  const _CalorieCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.unit,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TontonCardBase(
      elevation: Elevation.level1,
      padding: const EdgeInsets.all(Spacing.sm),
      backgroundColor:
          isHighlighted ? TontonColors.pigPink.withValues(alpha: 0.1) : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon and Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: IconSize.small, color: iconColor),
              const SizedBox(width: Spacing.xxs),
              Text(
                title,
                style: TontonTypography.caption1.copyWith(
                  color: TontonColors.secondaryLabelColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),

          // Value
          Text(
            value,
            style: TontonTypography.title3.copyWith(
              fontWeight: FontWeight.bold,
              color:
                  isHighlighted ? iconColor : TontonColors.labelColor(context),
            ),
          ),

          // Unit
          Text(
            unit,
            style: TontonTypography.caption2.copyWith(
              color: TontonColors.tertiaryLabelColor(context),
            ),
          ),
        ],
      ),
    );
  }
}
