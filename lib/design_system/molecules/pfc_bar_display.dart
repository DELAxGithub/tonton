import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../atoms/tonton_card_base.dart';
import '../atoms/tonton_text.dart';
import '../../theme/tokens.dart';
import '../../providers/pfc_balance_provider.dart';
import '../../routes/router.dart';

class PfcBarDisplay extends ConsumerWidget {
  final double protein;
  final double fat;
  final double carbs;
  final String title;
  final VoidCallback? onTap;

  const PfcBarDisplay({
    super.key,
    required this.title,
    required this.protein,
    required this.fat,
    required this.carbs,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(userGoalsProvider);

    final proteinTarget = goals.proteinGoalGrams ?? 60;
    final base = proteinTarget / goals.pfcRatio.protein;
    final fatTarget = base * goals.pfcRatio.fat;
    final carbTarget = base * goals.pfcRatio.carbohydrate;

    final sections = [
      PieChartSectionData(
        value: protein,
        color: Theme.of(context).colorScheme.primary,
        title: 'P',
        radius: 30,
        titleStyle: Theme.of(context).textTheme.labelSmall,
      ),
      PieChartSectionData(
        value: fat,
        color: Theme.of(context).colorScheme.secondary,
        title: 'F',
        radius: 30,
        titleStyle: Theme.of(context).textTheme.labelSmall,
      ),
      PieChartSectionData(
        value: carbs,
        color: Theme.of(context).colorScheme.tertiary,
        title: 'C',
        radius: 30,
        titleStyle: Theme.of(context).textTheme.labelSmall,
      ),
    ];

    return InkWell(
      onTap: onTap ?? () => context.push(TontonRoutes.aiMealCamera),
      borderRadius: BorderRadius.circular(Radii.md.x),
      child: TontonCardBase(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TontonText(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: Spacing.sm),
            Row(
              children: [
                PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 18,
                  ),
                  swapAnimationDuration: Duration(milliseconds: 300),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TontonText(
                        'P ${protein.toStringAsFixed(0)} / ${proteinTarget.toStringAsFixed(0)} g',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      TontonText(
                        'F ${fat.toStringAsFixed(0)} / ${fatTarget.toStringAsFixed(0)} g',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      TontonText(
                        'C ${carbs.toStringAsFixed(0)} / ${carbTarget.toStringAsFixed(0)} g',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
