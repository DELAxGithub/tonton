import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// A consistent section header with optional action button
class SectionHeader extends StatelessWidget {
  /// The title text to display
  final String title;
  
  /// Optional subtitle text to display
  final String? subtitle;
  
  /// Optional icon to display before the title
  final IconData? icon;
  
  /// Optional action widget (usually a button) to display on the right
  final Widget? action;
  
  /// Constructor for SectionHeader
  const SectionHeader({
    super.key, 
    required this.title,
    this.subtitle,
    this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and action row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title with optional icon
            Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: TontonSpacing.sm),
                ],
                Text(
                  title,
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
            
            // Optional action button
            if (action != null)
              action!,
          ],
        ),
        
        // Optional subtitle
        if (subtitle != null) ...[
          const SizedBox(height: TontonSpacing.xs),
          Text(
            subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}