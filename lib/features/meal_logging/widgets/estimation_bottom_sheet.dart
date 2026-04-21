import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../enums/meal_time_type.dart';
import '../../../models/meal_record.dart';
import '../../../providers/providers.dart';
import '../estimation_preset.dart';
import '../providers/estimation_base_provider.dart';

/// 日別履歴で食事記録が空の日に表示するボトムシート。
/// 少なめ / 普通 / 多め から選ぶと、その日に合成 MealRecord を1件追加する。
class EstimationBottomSheet extends ConsumerWidget {
  final DateTime targetDate;

  const EstimationBottomSheet({super.key, required this.targetDate});

  static Future<void> show(BuildContext context, DateTime date) {
    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => EstimationBottomSheet(targetDate: date),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final base = ref.watch(estimationBaseCaloriesProvider);
    final goals = ref.watch(userGoalsProvider);
    final ratio = goals.pfcRatio;

    final presets = EstimationLevel.values
        .map((level) => buildEstimationPreset(
              level: level,
              baseDailyCalories: base,
              pfcRatio: ratio,
            ))
        .toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${targetDate.month}/${targetDate.day} の食事を推定で埋める',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '直近の記録からざっくり推定します。あとで編集も可能です。',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            ...presets.map(
              (p) => _PresetTile(
                preset: p,
                onSelected: () async {
                  await _applyEstimate(ref, p);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${targetDate.month}/${targetDate.day} を「${p.level.label}」で埋めました',
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _applyEstimate(WidgetRef ref, EstimationPreset preset) async {
    final record = MealRecord(
      mealName: '推定（${preset.level.label}）',
      description: '食事記録がなかった日を自己申告で埋めた推定値。',
      calories: preset.calories,
      protein: preset.protein,
      fat: preset.fat,
      carbs: preset.carbs,
      mealTimeType: MealTimeType.lunch,
      consumedAt: DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        12,
        0,
      ),
    );
    await ref.read(mealRecordsProvider.notifier).addMealRecord(record);
    // Force recalculation of daily summary / savings
    ref.invalidate(dailySummariesProvider);
  }
}

class _PresetTile extends StatelessWidget {
  final EstimationPreset preset;
  final VoidCallback onSelected;

  const _PresetTile({required this.preset, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onSelected,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .outline
                  .withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preset.level.label,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${preset.calories.round()} kcal  |  '
                      'P ${preset.protein.round()}g  '
                      'F ${preset.fat.round()}g  '
                      'C ${preset.carbs.round()}g',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
