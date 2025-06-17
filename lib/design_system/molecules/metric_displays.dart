import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// A card for displaying a health or nutrition metric
class MetricCard extends StatelessWidget {
  /// The title of the metric
  final String title;

  /// The value of the metric as a string
  final String value;

  /// The icon to display
  final IconData icon;

  /// Optional subtitle or description
  final String? subtitle;

  /// Optional color for the icon and value
  final Color? color;

  /// Optional on tap handler
  final VoidCallback? onTap;

  /// Optional badge to display in the corner
  final Widget? badge;

  /// Constructor for MetricCard
  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.color,
    this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.colorScheme.primary;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TontonRadius.md),
      ),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(TontonSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon and title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(TontonSpacing.xs),
                        decoration: BoxDecoration(
                          color: cardColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(TontonRadius.sm),
                        ),
                        child: Icon(icon, color: cardColor, size: 18),
                      ),
                      const SizedBox(width: TontonSpacing.sm),
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: TontonSpacing.sm),

                  // Value
                  Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cardColor,
                    ),
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
                ],
              ),
            ),

            // Optional badge in top-right corner
            if (badge != null) Positioned(top: 0, right: 0, child: badge!),
          ],
        ),
      ),
    );
  }
}

/// A badge indicating a trend (up/down/stable)
class TrendBadge extends StatelessWidget {
  /// The percentage change
  final double percentChange;

  /// Whether a positive change is good (e.g., for weight, positive is bad)
  final bool positiveIsGood;

  /// Constructor for TrendBadge
  const TrendBadge({
    super.key,
    required this.percentChange,
    this.positiveIsGood = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine if the trend is good or bad based on direction and context
    final bool isGood = positiveIsGood ? percentChange > 0 : percentChange < 0;
    final bool isNeutral = percentChange == 0;

    // Choose color based on goodness
    final Color badgeColor =
        isNeutral
            ? theme.colorScheme.surfaceContainerHighest
            : isGood
            ? TontonColors.success
            : TontonColors.error;

    // Choose icon based on direction
    final IconData trendIcon =
        isNeutral
            ? Icons.drag_handle
            : percentChange > 0
            ? Icons.arrow_upward
            : Icons.arrow_downward;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TontonSpacing.sm,
        vertical: TontonSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(TontonRadius.md),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            trendIcon,
            color: Theme.of(context).colorScheme.onPrimary,
            size: 12,
          ),
          const SizedBox(width: 2),
          Text(
            '${percentChange.abs().toStringAsFixed(1)}%',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
