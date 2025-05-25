import 'package:flutter/material.dart';
import '../atoms/tonton_card_base.dart';
import '../atoms/tonton_text.dart';
import '../../theme/tokens.dart';
import '../../utils/color_utils.dart';

class NutrientBarData {
  final String label;
  final double current;
  final double target;
  final Color color;

  const NutrientBarData({
    required this.label,
    required this.current,
    required this.target,
    required this.color,
  });
}

class PfcBarDisplay extends StatelessWidget {
  final String title;
  final List<NutrientBarData> nutrients;

  const PfcBarDisplay({
    super.key,
    required this.title,
    required this.nutrients,
  });

  @override
  Widget build(BuildContext context) {
    return TontonCardBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TontonText(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final nutrient in nutrients)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
                    child: _NutrientBar(nutrient: nutrient),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NutrientBar extends StatelessWidget {
  final NutrientBarData nutrient;

  const _NutrientBar({required this.nutrient});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = nutrient.target > 0
        ? (nutrient.current / nutrient.target).clamp(0.0, 1.0)
        : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TontonText(
          nutrient.label,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: Spacing.xs),
        LinearProgressIndicator(
          value: progress,
          minHeight: 8,
          backgroundColor:
              nutrient.color.withValues(opacity: 0.2),
          color: nutrient.color,
        ),
        const SizedBox(height: Spacing.xs),
        TontonText(
          '${nutrient.current.toStringAsFixed(0)} / ${nutrient.target.toStringAsFixed(0)}g',
          style: theme.textTheme.labelSmall,
        ),
      ],
    );
  }
}
