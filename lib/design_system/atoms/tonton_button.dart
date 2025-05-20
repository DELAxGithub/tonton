import 'package:flutter/material.dart';
import '../../theme/tokens.dart';

enum TontonButtonVariant { primary, secondary, text }

class TontonButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final TontonButtonVariant variant;
  final IconData? leading;

  const TontonButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.leading,
  }) : variant = TontonButtonVariant.primary;

  const TontonButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.leading,
  }) : variant = TontonButtonVariant.secondary;

  const TontonButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.leading,
  }) : variant = TontonButtonVariant.text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const minSize = Size.fromHeight(48);

    ButtonStyle style;
    switch (variant) {
      case TontonButtonVariant.primary:
        style = ElevatedButton.styleFrom(
          minimumSize: minSize,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.md.x),
          ),
        );
        break;
      case TontonButtonVariant.secondary:
        style = OutlinedButton.styleFrom(
          minimumSize: minSize,
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.md.x),
          ),
        );
        break;
      case TontonButtonVariant.text:
        style = TextButton.styleFrom(
          minimumSize: minSize,
          foregroundColor: scheme.primary,
        );
        break;
    }

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading != null) Icon(leading, size: 20),
        if (leading != null) const SizedBox(width: Spacing.xs),
        Text(label),
      ],
    );

    switch (variant) {
      case TontonButtonVariant.primary:
        return ElevatedButton(onPressed: onPressed, style: style, child: child);
      case TontonButtonVariant.secondary:
        return OutlinedButton(onPressed: onPressed, style: style, child: child);
      case TontonButtonVariant.text:
        return TextButton(onPressed: onPressed, style: style, child: child);
    }
  }
}
