import 'package:flutter/material.dart';
import '../atoms/tonton_card_base.dart';
import '../atoms/tonton_icon.dart';
import '../atoms/tonton_text.dart';
import '../../theme/tokens.dart';

class DailyStatRing extends StatelessWidget {
  final IconData icon;
  final String label;
  final String currentValue;
  final String? targetValue;
  final double progress;
  final Color? color;

  const DailyStatRing({
    super.key,
    required this.icon,
    required this.label,
    required this.currentValue,
    this.targetValue,
    required this.progress,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final progressColor = color ?? scheme.primary;

    return TontonCardBase(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TontonIcon(icon, size: 24, color: progressColor),
          const SizedBox(height: Spacing.sm),
          SizedBox(
            height: 80,
            width: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress.clamp(0, 1),
                  strokeWidth: 8,
                  backgroundColor: scheme.primaryContainer,
                  color: progressColor,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TontonText(
                      currentValue,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: progressColor,
                            fontWeight: FontWeight.bold,
                          ),
                      align: TextAlign.center,
                    ),
                    if (targetValue != null)
                      TontonText(
                        targetValue!,
                        style: Theme.of(context).textTheme.bodySmall,
                        align: TextAlign.center,
                      ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: Spacing.sm),
          TontonText(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
            align: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
