import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../theme/tokens.dart' as tokens;
import '../../theme/colors.dart';
import '../../theme/typography.dart';

/// Apple HIG-compliant button styles
enum TontonButtonStyle {
  /// Primary action button with filled background
  filled,

  /// Secondary action button with gray background
  gray,

  /// Tertiary action button with transparent background
  plain,

  /// Destructive action button
  destructive,
}

/// Apple HIG-compliant button sizes
enum TontonButtonSize {
  /// Small button (28pt height)
  small,

  /// Regular button (34pt height)
  regular,

  /// Large button (44pt height)
  large,
}

/// Apple HIG-compliant button component
///
/// A button that follows Apple's design guidelines with proper
/// sizing, styling, and interaction feedback.
class TontonButton extends StatefulWidget {
  /// Button label text
  final String label;

  /// Optional leading icon
  final IconData? icon;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Button style variant
  final TontonButtonStyle style;

  /// Button size
  final TontonButtonSize size;

  /// Whether the button should expand to fill available width
  final bool isFullWidth;

  /// Loading state
  final bool isLoading;

  /// Custom foreground color
  final Color? foregroundColor;

  /// Custom background color
  final Color? backgroundColor;

  const TontonButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.style = TontonButtonStyle.filled,
    this.size = TontonButtonSize.regular,
    this.isFullWidth = false,
    this.isLoading = false,
    this.foregroundColor,
    this.backgroundColor,
  });

  /// Factory constructor for primary button (backward compatibility)
  factory TontonButton.primary({
    Key? key,
    required String label,
    IconData? icon,
    VoidCallback? onPressed,
    bool isFullWidth = false,
    bool isLoading = false,
  }) {
    return TontonButton(
      key: key,
      label: label,
      icon: icon,
      onPressed: onPressed,
      style: TontonButtonStyle.filled,
      size: TontonButtonSize.regular,
      isFullWidth: isFullWidth,
      isLoading: isLoading,
    );
  }

  /// Factory constructor for secondary button (backward compatibility)
  factory TontonButton.secondary({
    Key? key,
    required String label,
    IconData? icon,
    VoidCallback? onPressed,
    bool isFullWidth = false,
    bool isLoading = false,
  }) {
    return TontonButton(
      key: key,
      label: label,
      icon: icon,
      onPressed: onPressed,
      style: TontonButtonStyle.gray,
      size: TontonButtonSize.regular,
      isFullWidth: isFullWidth,
      isLoading: isLoading,
    );
  }

  /// Factory constructor for text button (backward compatibility)
  factory TontonButton.text({
    Key? key,
    required String label,
    IconData? icon,
    VoidCallback? onPressed,
    bool isFullWidth = false,
    bool isLoading = false,
  }) {
    return TontonButton(
      key: key,
      label: label,
      icon: icon,
      onPressed: onPressed,
      style: TontonButtonStyle.plain,
      size: TontonButtonSize.regular,
      isFullWidth: isFullWidth,
      isLoading: isLoading,
    );
  }

  @override
  State<TontonButton> createState() => _TontonButtonState();
}

class _TontonButtonState extends State<TontonButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Determine button height based on size
    double height;
    double fontSize;
    EdgeInsetsGeometry padding;

    switch (widget.size) {
      case TontonButtonSize.small:
        height = tokens.MinSize.compactButton;
        fontSize = 15;
        padding = const EdgeInsets.symmetric(horizontal: tokens.Spacing.sm);
        break;
      case TontonButtonSize.regular:
        height = tokens.MinSize.button;
        fontSize = 17;
        padding = const EdgeInsets.symmetric(horizontal: tokens.Spacing.md);
        break;
      case TontonButtonSize.large:
        height = tokens.MinSize.largeButton;
        fontSize = 17;
        padding = const EdgeInsets.symmetric(horizontal: tokens.Spacing.lg);
        break;
    }

    // Determine colors based on style
    Color backgroundColor;
    Color foregroundColor;
    Color disabledBackgroundColor;
    Color disabledForegroundColor;

    switch (widget.style) {
      case TontonButtonStyle.filled:
        backgroundColor = widget.backgroundColor ?? theme.colorScheme.primary;
        foregroundColor = widget.foregroundColor ?? theme.colorScheme.onPrimary;
        disabledBackgroundColor = TontonColors.systemGray3;
        disabledForegroundColor = TontonColors.systemGray;
        break;

      case TontonButtonStyle.gray:
        backgroundColor =
            widget.backgroundColor ??
            (isDark
                ? TontonColors.systemGray5.withValues(alpha: 0.24)
                : TontonColors.systemGray5);
        foregroundColor =
            widget.foregroundColor ?? TontonColors.labelColor(context);
        disabledBackgroundColor = backgroundColor.withValues(alpha: 0.5);
        disabledForegroundColor = TontonColors.tertiaryLabelColor(context);
        break;

      case TontonButtonStyle.plain:
        backgroundColor = widget.backgroundColor ?? Colors.transparent;
        foregroundColor = widget.foregroundColor ?? theme.colorScheme.primary;
        disabledBackgroundColor = Colors.transparent;
        disabledForegroundColor = TontonColors.tertiaryLabelColor(context);
        break;

      case TontonButtonStyle.destructive:
        backgroundColor = widget.backgroundColor ?? TontonColors.systemRed;
        foregroundColor = widget.foregroundColor ?? Colors.white;
        disabledBackgroundColor = TontonColors.systemGray3;
        disabledForegroundColor = TontonColors.systemGray;
        break;
    }

    // Apply pressed state opacity
    if (_isPressed && widget.onPressed != null) {
      backgroundColor = backgroundColor.withValues(alpha: 0.8);
    }

    // Apply disabled state
    final isDisabled = widget.onPressed == null || widget.isLoading;
    if (isDisabled) {
      backgroundColor = disabledBackgroundColor;
      foregroundColor = disabledForegroundColor;
    }

    // Build button content
    Widget content = Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading)
          SizedBox(
            width: fontSize,
            height: fontSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        else if (widget.icon != null) ...[
          Icon(widget.icon, size: fontSize + 2, color: foregroundColor),
          const SizedBox(width: tokens.Spacing.xs),
        ],
        if (!widget.isLoading)
          Text(
            widget.label,
            style: TontonTypography.body.copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: foregroundColor,
            ),
          ),
      ],
    );

    return GestureDetector(
      onTapDown: isDisabled ? null : _handleTapDown,
      onTapUp: isDisabled ? null : _handleTapUp,
      onTapCancel: isDisabled ? null : _handleTapCancel,
      onTap: isDisabled ? null : widget.onPressed,
      child: AnimatedContainer(
        duration: tokens.Durations.fast,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: tokens.Radii.mediumBorderRadius,
          border:
              widget.style == TontonButtonStyle.plain && !isDark
                  ? Border.all(
                    color: foregroundColor.withValues(alpha: 0.2),
                    width: 1,
                  )
                  : null,
        ),
        child: content,
      ),
    );
  }
}

/// Convenience widget for icon-only buttons
class TontonIconButton extends StatelessWidget {
  /// Icon to display
  final IconData icon;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Icon color
  final Color? color;

  /// Icon size
  final double? size;

  /// Background style
  final bool hasBackground;

  /// Tooltip
  final String? tooltip;

  const TontonIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size,
    this.hasBackground = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = color ?? theme.colorScheme.primary;
    final iconSize = size ?? tokens.IconSize.medium;

    Widget button = Material(
      color:
          hasBackground ? TontonColors.fillColor(context) : Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: tokens.MinSize.tapTarget,
          height: tokens.MinSize.tapTarget,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color:
                onPressed != null
                    ? iconColor
                    : TontonColors.tertiaryLabelColor(context),
            size: iconSize,
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}
