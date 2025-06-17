import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import '../../theme/colors.dart';

/// Apple HIG-compliant card component
///
/// A card with proper corner radius, elevation, and padding
/// following Apple's design guidelines.
class TontonCardBase extends StatelessWidget {
  /// The content of the card
  final Widget child;

  /// The elevation level (0-4)
  final double elevation;

  /// Custom padding for the card content
  final EdgeInsetsGeometry? padding;

  /// Custom border radius
  final BorderRadius? borderRadius;

  /// Background color override
  final Color? backgroundColor;

  /// Border color and width
  final Color? borderColor;
  final double borderWidth;

  /// Tap callback
  final VoidCallback? onTap;

  const TontonCardBase({
    super.key,
    required this.child,
    this.elevation = Elevation.level1,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Select appropriate shadows based on elevation
    List<BoxShadow> shadows;
    switch (elevation.round()) {
      case 0:
        shadows = Elevation.shadowLevel0;
        break;
      case 1:
        shadows = Elevation.shadowLevel1;
        break;
      case 2:
        shadows = Elevation.shadowLevel2;
        break;
      case 3:
        shadows = Elevation.shadowLevel3;
        break;
      default:
        shadows = Elevation.shadowLevel4;
    }

    Widget card = Container(
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            (isDark
                ? TontonColors.secondarySystemGroupedBackgroundDark
                : TontonColors.secondarySystemGroupedBackground),
        borderRadius: borderRadius ?? Radii.largeBorderRadius,
        boxShadow: shadows,
        border:
            borderWidth > 0
                ? Border.all(
                  color: borderColor ?? TontonColors.separatorColor(context),
                  width: borderWidth,
                )
                : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? Radii.largeBorderRadius,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(Spacing.md),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? Radii.largeBorderRadius,
        child: card,
      );
    }

    return card;
  }
}
