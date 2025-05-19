import 'package:flutter/material.dart';

import '../models/ai_advice_response.dart';

/// Card widget to display AI meal advice details.
class AiAdviceDisplay extends StatelessWidget {
  final AiAdviceResponse advice;
  const AiAdviceDisplay({super.key, required this.advice});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              advice.adviceMessage,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 8),
            if (advice.calorieGoalMetOrExceeded)
              Text(
                  '残りのカロリー: ${advice.remainingCaloriesForLastMeal?.toStringAsFixed(0) ?? 'N/A'} kcal')
            else if (advice.menuSuggestion != null) ...[
              Text(
                '提案メニュー: ${advice.menuSuggestion!.menuName}',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text('説明: ${advice.menuSuggestion!.description}'),
              const SizedBox(height: 8),
              Text(
                '推定栄養価:',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'カロリー: ${advice.menuSuggestion!.estimatedNutrition.calories.toStringAsFixed(0)} kcal'),
                    Text(
                        'タンパク質: ${advice.menuSuggestion!.estimatedNutrition.protein.toStringAsFixed(1)} g'),
                    Text(
                        '脂質: ${advice.menuSuggestion!.estimatedNutrition.fat.toStringAsFixed(1)} g'),
                    Text(
                        '炭水化物: ${advice.menuSuggestion!.estimatedNutrition.carbohydrates.toStringAsFixed(1)} g'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'おすすめ理由:',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Text(advice.menuSuggestion!.recommendationReason),
              const SizedBox(height: 8),
              Text(
                '計算された最後の食事の目標:',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              if (advice.calculatedTargetPfcForLastMeal != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '許容カロリー: ${advice.remainingCaloriesForLastMeal?.toStringAsFixed(0) ?? 'N/A'} kcal'),
                      Text(
                          '目標タンパク質: ${advice.calculatedTargetPfcForLastMeal!.protein.toStringAsFixed(1)} g'),
                      Text(
                          '目標脂質: ${advice.calculatedTargetPfcForLastMeal!.fat.toStringAsFixed(1)} g'),
                      Text(
                          '目標炭水化物: ${advice.calculatedTargetPfcForLastMeal!.carbohydrate.toStringAsFixed(1)} g'),
                    ],
                  ),
                ),
            ] else
              const Text('具体的なメニュー提案はありませんでした。'),
          ],
        ),
      ),
    );
  }
}
