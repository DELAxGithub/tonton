import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import '../../utils/color_utils.dart';

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
      shadowColor: Colors.black.withValues(alpha: (0.1 * 255).round()),
      borderRadius: BorderRadius.circular(Radii.md.x),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: child,
      ),
    );
  }
}
