import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../atoms/tonton_card_base.dart';
import '../atoms/tonton_text.dart';
import '../../theme/tokens.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../routes/router.dart';
import '../../features/progress/providers/auto_pfc_provider.dart';

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
    // 自動計算されたPFC目標値を取得
    final autoPfc = ref.watch(autoPfcTargetProvider);
    
    // デフォルト値（プロフィール未設定時）
    final proteinTarget = autoPfc?.protein ?? 60.0;
    final fatTarget = autoPfc?.fat ?? 70.0;
    final carbTarget = autoPfc?.carbohydrate ?? 250.0;

    final proteinProgress = (protein / proteinTarget).clamp(0.0, 1.0);
    final fatProgress = (fat / fatTarget).clamp(0.0, 1.0);
    final carbProgress = (carbs / carbTarget).clamp(0.0, 1.0);

    if (protein == 0 && fat == 0 && carbs == 0) {
      return TontonCardBase(
        child: TontonText(
          'データがありません',
          style: Theme.of(context).textTheme.bodyMedium,
          align: TextAlign.center,
        ),
      );
    }

    return InkWell(
      onTap: onTap ?? () => context.push(TontonRoutes.aiMealCamera),
      borderRadius: Radii.mediumBorderRadius,
      child: TontonCardBase(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TontonText(
              title,
              style: TontonTypography.headline,
            ),
            const SizedBox(height: Spacing.sm),
            _BarWithLabel(
              label: 'P',
              value: protein,
              target: proteinTarget,
              progress: proteinProgress,
              color: TontonColors.proteinColor,
            ),
            const SizedBox(height: Spacing.sm),
            _BarWithLabel(
              label: 'F',
              value: fat,
              target: fatTarget,
              progress: fatProgress,
              color: TontonColors.fatColor,
            ),
            const SizedBox(height: Spacing.sm),
            _BarWithLabel(
              label: 'C',
              value: carbs,
              target: carbTarget,
              progress: carbProgress,
              color: TontonColors.carbsColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _BarWithLabel extends StatelessWidget {
  final String label;
  final double value;
  final double target;
  final double progress;
  final Color color;

  const _BarWithLabel({
    required this.label,
    required this.value,
    required this.target,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TontonText(
          '$label ${value.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} g',
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          minHeight: 8,
          color: color,
          backgroundColor: color.withValues(alpha: 0.2),
        ),
      ],
    );
  }
}
