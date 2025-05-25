import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/icon_mapper.dart';

import '../models/meal_record.dart';

/// A widget that displays a meal record as a card
class MealRecordCard extends StatelessWidget {
  /// The meal record to display
  final MealRecord mealRecord;
  
  /// Callback for when the card is tapped
  final VoidCallback? onTap;

  /// Constructor for MealRecordCard
  const MealRecordCard({
    super.key,
    required this.mealRecord,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meal type and time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          TontonIcons.mealTimeIcon(mealRecord.mealTimeType),
                          size: 16,
                          color: theme.colorScheme.onPrimaryContainer,
                          semanticLabel: mealRecord.mealTimeType.displayName,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          mealRecord.mealTimeType.displayName,
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    DateFormat.jm().format(mealRecord.consumedAt),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Meal name
              Text(
                mealRecord.mealName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              // Meal description (if available)
              if (mealRecord.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  mealRecord.description,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              const SizedBox(height: 12),
              const Divider(),
              
              // Nutrition information
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Calories
                  _buildNutritionInfo(
                    context,
                    TontonIcons.energy,
                    '${mealRecord.calories.toStringAsFixed(0)} kcal',
                    theme.colorScheme.primary,
                  ),
                  // Protein
                  _buildNutritionInfo(
                    context,
                    Icons.fitness_center,
                    '${mealRecord.protein.toStringAsFixed(1)} g',
                    Colors.red.shade700,
                    label: 'Protein',
                  ),
                  // Fat
                  _buildNutritionInfo(
                    context,
                    Icons.water_drop,
                    '${mealRecord.fat.toStringAsFixed(1)} g',
                    Colors.amber.shade700,
                    label: 'Fat',
                  ),
                  // Carbs
                  _buildNutritionInfo(
                    context,
                    Icons.grain,
                    '${mealRecord.carbs.toStringAsFixed(1)} g',
                    Colors.green.shade700,
                    label: 'Carbs',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper method to build a nutrition info item
  Widget _buildNutritionInfo(
    BuildContext context,
    IconData icon,
    String value,
    Color color, {
    String? label,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 16,
              semanticLabel: label,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        if (label != null) ...[
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}