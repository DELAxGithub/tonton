import 'package:flutter/material.dart';
import '../../theme/tokens.dart';

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
      shadowColor: Colors.black.withOpacity(0.1),
      borderRadius: BorderRadius.circular(Radii.md.x),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: child,
      ),
    );
  }
}
