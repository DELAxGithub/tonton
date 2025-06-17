import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// A labeled linear progress bar with customizable appearance
class LabeledProgressBar extends StatelessWidget {
  /// The progress value (0.0 to 1.0)
  final double value;

  /// Label to display above the progress bar
  final String label;

  /// Optional subtitle to display
  final String? subtitle;

  /// Whether to show the percentage value
  final bool showPercentage;

  /// Optional custom color for the progress bar
  final Color? progressColor;

  /// Optional custom color for the background
  final Color? backgroundColor;

  /// Height of the progress bar
  final double height;

  /// Constructor
  const LabeledProgressBar({
    super.key,
    required this.value,
    required this.label,
    this.subtitle,
    this.showPercentage = true,
    this.progressColor,
    this.backgroundColor,
    this.height = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = progressColor ?? theme.colorScheme.primary;
    final bgColor =
        backgroundColor ??
        theme.colorScheme.primaryContainer.withValues(alpha: 0.3);

    // Calculate percentage for display
    final percentage = (value * 100).clamp(0, 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label and percentage row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.titleSmall),
            if (showPercentage)
              Text(
                '$percentage%',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
          ],
        ),

        // Optional subtitle
        if (subtitle != null) ...[
          const SizedBox(height: TontonSpacing.xs),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],

        // Progress bar
        const SizedBox(height: TontonSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(TontonRadius.full),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: bgColor,
            color: color,
            minHeight: height,
          ),
        ),
      ],
    );
  }
}

/// A circular progress indicator with a label
class LabeledCircularProgress extends StatelessWidget {
  /// The progress value (0.0 to 1.0)
  final double value;

  /// Label to display inside the circle
  final String label;

  /// Optional subtitle to display below the circle
  final String? subtitle;

  /// Size of the circular progress indicator
  final double size;

  /// Thickness of the progress indicator stroke
  final double strokeWidth;

  /// Optional custom color for the progress
  final Color? progressColor;

  /// Optional custom color for the background
  final Color? backgroundColor;

  /// Constructor
  const LabeledCircularProgress({
    super.key,
    required this.value,
    required this.label,
    this.subtitle,
    this.size = 100.0,
    this.strokeWidth = 8.0,
    this.progressColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = progressColor ?? theme.colorScheme.primary;
    final bgColor =
        backgroundColor ??
        theme.colorScheme.primaryContainer.withValues(alpha: 0.3);

    // Calculate percentage for display
    final percentage = (value * 100).clamp(0, 100).toInt();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Circular progress with centered label
        SizedBox(
          height: size,
          width: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Progress indicator
              CircularProgressIndicator(
                value: value,
                backgroundColor: bgColor,
                color: color,
                strokeWidth: strokeWidth,
              ),

              // Centered label
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$percentage%',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(label, style: theme.textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),

        // Optional subtitle
        if (subtitle != null) ...[
          const SizedBox(height: TontonSpacing.sm),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
