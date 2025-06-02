import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../atoms/tonton_card_base.dart';
import '../atoms/tonton_text.dart';
import '../molecules/pfc_pie_chart.dart';
import '../molecules/feedback/empty_state.dart';
import '../../theme/tokens.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../utils/icon_mapper.dart';
import '../../providers/providers.dart';

/// A widget that displays PFC balance with a pie chart and detailed values
class PfcBalanceCard extends ConsumerWidget {
  const PfcBalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get today's meal records to calculate PFC
    final todayMeals = ref.watch(todaysMealRecordsProvider);
    
    // Calculate total PFC values
    final protein = todayMeals.fold<double>(0, (sum, meal) => sum + meal.protein);
    final fat = todayMeals.fold<double>(0, (sum, meal) => sum + meal.fat);
    final carbs = todayMeals.fold<double>(0, (sum, meal) => sum + meal.carbs);
    
    // Check if there are any meals recorded
    final hasMeals = todayMeals.isNotEmpty;
    
    return TontonCardBase(
      elevation: Elevation.level1,
      padding: const EdgeInsets.all(Spacing.md),
      child: hasMeals
          ? SizedBox(
              height: 100,
              child: Row(
                children: [
                  // Left side - Pie Chart (flex: 1)
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: PfcPieChart(
                          protein: protein,
                          fat: fat,
                          carbs: carbs,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: Spacing.md),
                  
                  // Right side - Nutrition Details (flex: 2)
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Title
                        Text(
                          '今日のPFCバランス',
                          style: TontonTypography.footnote.copyWith(
                            color: TontonColors.secondaryLabelColor(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: Spacing.xs),
                        
                        // Nutrition values
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _NutritionValue(
                              label: 'P',
                              value: protein,
                              color: TontonColors.proteinColor,
                            ),
                            _NutritionValue(
                              label: 'F',
                              value: fat,
                              color: TontonColors.fatColor,
                            ),
                            _NutritionValue(
                              label: 'C',
                              value: carbs,
                              color: TontonColors.carbsColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.restaurant_outlined,
                      size: IconSize.medium,
                      color: TontonColors.tertiaryLabelColor(context),
                    ),
                    const SizedBox(width: Spacing.sm),
                    Text(
                      '食事を記録してPFCバランスを確認',
                      style: TontonTypography.footnote.copyWith(
                        color: TontonColors.secondaryLabelColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

/// Individual nutrition value display widget
class _NutritionValue extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _NutritionValue({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Color indicator and label
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: Spacing.xxs),
            Text(
              label,
              style: TontonTypography.caption2.copyWith(
                color: TontonColors.secondaryLabelColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.xxs),
        
        // Value
        Text(
          '${value.toStringAsFixed(1)}g',
          style: TontonTypography.footnote.copyWith(
            fontWeight: FontWeight.bold,
            color: TontonColors.labelColor(context),
          ),
        ),
      ],
    );
  }
}