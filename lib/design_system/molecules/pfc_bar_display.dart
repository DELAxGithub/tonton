import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart' as app_theme;
import '../../features/progress/providers/auto_pfc_provider.dart';

/// PFC balance bars matching .pen PfcBarItem design
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
    final autoPfc = ref.watch(autoPfcTargetProvider);

    final proteinTarget = autoPfc?.protein ?? 60.0;
    final fatTarget = autoPfc?.fat ?? 70.0;
    final carbTarget = autoPfc?.carbohydrate ?? 250.0;

    if (protein == 0 && fat == 0 && carbs == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PfcBarItem(
          label: 'たんぱく質',
          value: protein,
          target: proteinTarget,
          color: TontonColors.proteinColor,
        ),
        const SizedBox(height: 14),
        _PfcBarItem(
          label: '脂質',
          value: fat,
          target: fatTarget,
          color: TontonColors.fatColor,
        ),
        const SizedBox(height: 14),
        _PfcBarItem(
          label: '炭水化物',
          value: carbs,
          target: carbTarget,
          color: TontonColors.carbsColor,
        ),
      ],
    );
  }
}

class _PfcBarItem extends StatelessWidget {
  final String label;
  final double value;
  final double target;
  final Color color;

  const _PfcBarItem({
    required this.label,
    required this.value,
    required this.target,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (value / target).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row: label left, value right
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: app_theme.TontonColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${value.toStringAsFixed(0)} / ${target.toStringAsFixed(0)}g',
              style: TextStyle(
                color: app_theme.TontonColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Bar track (6px height)
        Container(
          width: double.infinity,
          height: 6,
          decoration: BoxDecoration(
            color: TontonColors.borderSubtle,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
