import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A card displaying nutrition information summary
class NutritionSummaryCard extends StatelessWidget {
  /// Calories value
  final double calories;
  
  /// Protein value (g)
  final double protein;
  
  /// Fat value (g)
  final double fat;
  
  /// Carbs value (g)
  final double carbs;
  
  /// Optional title for the card
  final String? title;
  
  /// Optional subtitle for the card
  final String? subtitle;

  /// Optional action button
  final Widget? action;
  
  /// Show or hide macronutrient percentages
  final bool showPercentages;
  
  const NutritionSummaryCard({
    super.key,
    required this.calories,
    required this.protein,
    required this.fat, 
    required this.carbs,
    this.title,
    this.subtitle,
    this.action,
    this.showPercentages = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Calculate percentages based on 4-4-9 calorie distribution
    // (4 cal/g for protein, 4 cal/g for carbs, 9 cal/g for fat)
    final totalCaloriesFromMacros = (protein * 4) + (carbs * 4) + (fat * 9);
    
    // Avoid division by zero
    final double proteinPercentage = totalCaloriesFromMacros > 0 
        ? ((protein * 4) / totalCaloriesFromMacros * 100).clamp(0, 100)
        : 0;
    final double carbsPercentage = totalCaloriesFromMacros > 0 
        ? ((carbs * 4) / totalCaloriesFromMacros * 100).clamp(0, 100)
        : 0;
    final double fatPercentage = totalCaloriesFromMacros > 0 
        ? ((fat * 9) / totalCaloriesFromMacros * 100).clamp(0, 100)
        : 0;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: TontonSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(TontonSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and action row
            if (title != null || action != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  if (action != null)
                    action!
                  else
                    const SizedBox.shrink(),
                ],
              ),
              
            // Subtitle if provided
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: TontonSpacing.xs),
                child: Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              
            // Add spacing if we have header content
            if (title != null || subtitle != null || action != null)
              const SizedBox(height: TontonSpacing.md),
            
            // Calories
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  calories.toStringAsFixed(0),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: TontonSpacing.xs),
                Text(
                  'kcal',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: TontonSpacing.md),
            
            // Macronutrient distribution bar
            Container(
              height: 12,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(TontonRadius.full),
              ),
              child: Row(
                children: [
                  // Protein (red)
                  Expanded(
                    flex: proteinPercentage.round(),
                    child: Container(color: Colors.red.shade700),
                  ),
                  // Carbs (blue)
                  Expanded(
                    flex: carbsPercentage.round(),
                    child: Container(color: Colors.blue.shade700),
                  ),
                  // Fat (yellow)
                  Expanded(
                    flex: fatPercentage.round(),
                    child: Container(color: Colors.amber.shade700),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: TontonSpacing.md),
            
            // Macronutrient breakdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Protein
                _buildMacronutrientInfo(
                  context: context,
                  label: 'Protein',
                  value: protein,
                  percentage: showPercentages ? proteinPercentage : null,
                  color: Colors.red.shade700,
                ),
                
                // Carbs
                _buildMacronutrientInfo(
                  context: context,
                  label: 'Carbs',
                  value: carbs,
                  percentage: showPercentages ? carbsPercentage : null,
                  color: Colors.blue.shade700,
                ),
                
                // Fat
                _buildMacronutrientInfo(
                  context: context,
                  label: 'Fat',
                  value: fat,
                  percentage: showPercentages ? fatPercentage : null,
                  color: Colors.amber.shade700,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMacronutrientInfo({
    required BuildContext context,
    required String label,
    required double value,
    double? percentage,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Label with color indicator
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Value
        Text(
          '${value.toStringAsFixed(1)}g',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        // Percentage if provided
        if (percentage != null)
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
            ),
          ),
      ],
    );
  }
}