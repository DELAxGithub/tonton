import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../enums/meal_time_type.dart';
import '../../../models/meal_record.dart';
import '../../../providers/providers.dart';
import '../estimation_preset.dart';
import '../providers/recent_intake_average_provider.dart';

/// 食事記録ゼロの日に「食べてない方 / いつも通り / 食べすぎた」の3択で推定値を埋めるシート。
///
/// 基準値の優先順位:
///   1. 過去14日の摂取平均（[recentIntakeAverageProvider]）
///   2. プロフィール由来の目標摂取値 = TDEE − 日次赤字目標
///   3. ハードコードのデフォルト 1800 kcal
class EstimationBottomSheet extends ConsumerWidget {
  final DateTime targetDate;

  const EstimationBottomSheet({
    super.key,
    required this.targetDate,
  });

  static Future<void> show(
    BuildContext context, {
    required DateTime date,
  }) {
    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => EstimationBottomSheet(targetDate: date),
    );
  }

  static const double _hardcodedFallbackKcal = 1800;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(userGoalsProvider);
    final ratio = goals.pfcRatio;
    final recentAvg = ref.watch(recentIntakeAverageProvider);

    final tdee = goals.estimatedTdee;
    final profileTarget =
        tdee != null ? tdee - goals.dailyDeficitGoalKcal : null;

    final baselineKcal =
        recentAvg ?? profileTarget ?? _hardcodedFallbackKcal;
    final source = recentAvg != null
        ? _BaselineSource.recentAverage
        : profileTarget != null
            ? _BaselineSource.profileTarget
            : _BaselineSource.fallback;

    final presets = EstimationLevel.values
        .map((level) => buildEstimationPreset(
              level: level,
              baselineKcal: baselineKcal,
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
              source.captionFor(baselineKcal),
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

enum _BaselineSource { recentAverage, profileTarget, fallback }

extension on _BaselineSource {
  String captionFor(double kcal) {
    final rounded = kcal.round();
    switch (this) {
      case _BaselineSource.recentAverage:
        return '直近14日の摂取平均 ${rounded} kcal を「いつも通り」として推定します。';
      case _BaselineSource.profileTarget:
        return '過去の記録が少ないため、プロフィールの目標摂取 ${rounded} kcal を基準にします。';
      case _BaselineSource.fallback:
        return '過去の記録もプロフィールも未設定のため、暫定 ${rounded} kcal を基準にします。';
    }
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
