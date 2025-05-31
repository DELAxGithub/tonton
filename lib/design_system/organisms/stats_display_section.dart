import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// A data class representing a statistic to display in the grid
class StatItem {
  /// The title of the statistic
  final String title;
  
  /// The value to display
  final String value;
  
  /// The icon to show
  final IconData icon;
  
  /// Optional subtitle or unit
  final String? subtitle;
  
  /// Optional accent color
  final Color? color;
  
  /// Constructor for StatItem
  const StatItem({
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.color,
  });
}

/// A grid of statistics displayed as cards
class StatsGrid extends StatelessWidget {
  /// The statistics to display
  final List<StatItem> items;
  
  /// The number of columns in the grid (defaults to 2)
  final int crossAxisCount;
  
  /// The spacing between items
  final double spacing;
  
  /// Constructor for StatsGrid
  const StatsGrid({
    super.key,
    required this.items,
    this.crossAxisCount = 2,
    this.spacing = TontonSpacing.md,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 1.5,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildStatCard(context, item);
      },
    );
  }
  
  /// Builds a single stat card
  Widget _buildStatCard(BuildContext context, StatItem item) {
    final theme = Theme.of(context);
    final cardColor = item.color ?? theme.colorScheme.primary;
    
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(TontonSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon and title
            Row(
              children: [
                Icon(
                  item.icon,
                  color: cardColor,
                  size: 16,
                ),
                const SizedBox(width: TontonSpacing.xs),
                Expanded(
                  child: Text(
                    item.title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: TontonSpacing.xs),
            
            // Value and subtitle
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  item.value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cardColor,
                  ),
                ),
                if (item.subtitle != null) ...[
                  const SizedBox(width: TontonSpacing.xs),
                  Text(
                    item.subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}