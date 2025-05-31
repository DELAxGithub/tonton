import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import '../../theme/app_theme.dart';

class TontonCardBase extends StatelessWidget {
  final Widget child;
  final double elevation;

  const TontonCardBase({
    super.key,
    required this.child,
    this.elevation = Elevation.level1,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: elevation,
      shadowColor: TontonColors.neutral900.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(Radii.md.x),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: child,
      ),
    );
  }
}
