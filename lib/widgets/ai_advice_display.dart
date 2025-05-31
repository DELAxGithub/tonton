import 'package:flutter/material.dart';
import '../models/ai_advice_response.dart';
import '../theme/app_theme.dart';
import '../utils/icon_mapper.dart';
import 'nutrition_summary_card.dart';

/// A visually enhanced display for AI meal advice
class AiAdviceDisplay extends StatelessWidget {
  /// The advice data to display
  final AiAdviceResponse advice;
  
  /// Constructor
  const AiAdviceDisplay({super.key, required this.advice});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TontonRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header with AI icon
          Container(
            padding: const EdgeInsets.all(TontonSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer
                  .withValues(alpha: 0.7),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(TontonRadius.lg),
                topRight: Radius.circular(TontonRadius.lg),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(TontonSpacing.xs),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(TontonRadius.md),
                  ),
                  child: Icon(
                    TontonIcons.ai,
                    color: theme.colorScheme.onPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: TontonSpacing.sm),
                Text(
                  'AI Nutritional Advice',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Card content
          Padding(
            padding: const EdgeInsets.all(TontonSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main advice message
                Container(
                  padding: const EdgeInsets.all(TontonSpacing.md),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(TontonRadius.md),
                    boxShadow: TontonShadows.small,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: TontonSpacing.sm),
                      Expanded(
                        child: Text(
                          advice.adviceMessage,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: TontonSpacing.md),
                
                // Remaining calorie goal (if met or exceeded)
                if (advice.calorieGoalMetOrExceeded)
                  _buildInfoItem(
                    context: context,
                    icon: TontonIcons.energy,
                    title: 'Daily Calorie Goal',
                    content: 'Your daily calorie goal has been reached or exceeded! 🎉',
                  )
                // Menu suggestion (if available)
                else if (advice.menuSuggestion != null)
                  _buildMenuSuggestion(context, advice)
                // No menu suggestion
                else
                  _buildInfoItem(
                    context: context,
                    icon: Icons.no_meals,
                    title: 'No Menu Suggestion',
                    content: 'Based on your meals today, a specific menu suggestion is not available.',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Builds the menu suggestion section of the advice display
  Widget _buildMenuSuggestion(BuildContext context, AiAdviceResponse advice) {
    final theme = Theme.of(context);
    final menuSuggestion = advice.menuSuggestion!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Menu suggestion title
        _buildInfoItem(
          context: context,
          icon: TontonIcons.food,
          title: 'Suggested Meal',
          content: menuSuggestion.menuName,
          isHighlighted: true,
        ),
        const SizedBox(height: TontonSpacing.sm),
        
        // Menu description
        Padding(
          padding: const EdgeInsets.only(left: TontonSpacing.xl),
          child: Text(
            menuSuggestion.description,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: TontonSpacing.md),
        
        // Nutrition card for the suggested meal
        NutritionSummaryCard(
            title: 'Estimated Nutrition',
            calories: menuSuggestion.estimatedNutrition.calories,
            protein: menuSuggestion.estimatedNutrition.protein,
            fat: menuSuggestion.estimatedNutrition.fat,
            carbs: menuSuggestion.estimatedNutrition.carbohydrates,
            showPercentages: true,
        ),
        const SizedBox(height: TontonSpacing.md),
        
        // Recommendation reason
        _buildInfoItem(
          context: context,
          icon: Icons.thumb_up_outlined,
          title: 'Why We Recommend This',
          content: menuSuggestion.recommendationReason,
        ),
        
        // Target PFC breakdown (if available)
        if (advice.calculatedTargetPfcForLastMeal != null) ...[
          const SizedBox(height: TontonSpacing.md),
          _buildInfoItem(
            context: context,
            icon: Icons.assignment_outlined,
            title: 'Nutritional Targets',
            content: 'These are your optimal targets for your next meal to balance your daily intake.',
          ),
          const SizedBox(height: TontonSpacing.sm),
          
          // Target values in a grid
          Padding(
            padding: const EdgeInsets.only(left: TontonSpacing.xl),
            child: Wrap(
              spacing: TontonSpacing.md,
              runSpacing: TontonSpacing.xs,
              children: [
                _buildNutrientChip(
                  context: context,
                  label: 'Calories',
                  value: '${advice.remainingCaloriesForLastMeal?.toStringAsFixed(0) ?? "N/A"} kcal',
                  color: theme.colorScheme.primary,
                ),
                _buildNutrientChip(
                  context: context,
                  label: 'Protein',
                  value: '${advice.calculatedTargetPfcForLastMeal!.protein.toStringAsFixed(1)} g',
                  color: Colors.red.shade700,
                ),
                _buildNutrientChip(
                  context: context,
                  label: 'Fat',
                  value: '${advice.calculatedTargetPfcForLastMeal!.fat.toStringAsFixed(1)} g',
                  color: Colors.amber.shade700,
                ),
                _buildNutrientChip(
                  context: context,
                  label: 'Carbs',
                  value: '${advice.calculatedTargetPfcForLastMeal!.carbohydrate.toStringAsFixed(1)} g',
                  color: Colors.blue.shade700,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
  
  /// Helper to build information items with an icon and title
  Widget _buildInfoItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String content,
    bool isHighlighted = false,
  }) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(TontonSpacing.xs),
          decoration: BoxDecoration(
            color: isHighlighted
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(TontonRadius.sm),
          ),
          child: Icon(
            icon,
            color: isHighlighted
                ? theme.colorScheme.onPrimary 
                : theme.colorScheme.onSurfaceVariant,
            size: 18,
          ),
        ),
        const SizedBox(width: TontonSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isHighlighted
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: TontonSpacing.xs),
              Text(
                content,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  /// Build a chip to display nutrient information
  Widget _buildNutrientChip({
    required BuildContext context,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TontonSpacing.sm,
        vertical: TontonSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(TontonRadius.md),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}