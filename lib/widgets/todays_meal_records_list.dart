import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../providers/providers.dart';
import '../routes/router.dart';
import 'meal_record_card.dart';
import '../design_system/molecules/feedback/empty_state.dart';
import '../features/progress/providers/meal_score_provider.dart';

/// Displays a list of today's meal records using [todaysMealRecordsProvider].
class TodaysMealRecordsList extends ConsumerWidget {
  const TodaysMealRecordsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = ref.watch(todaysMealRecordsProvider);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (meals.isEmpty)
          EmptyState(
            title: l10n?.noMealsRecorded ?? '食事の記録がありません',
            message: '右下の+ボタンから食事を記録しましょう',
            icon: Icons.add_circle_outline,
            isCompact: true,
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: meals.length,
            itemBuilder: (context, index) {
              final meal = meals[index];
              return Dismissible(
                key: Key(meal.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('削除の確認'),
                          content: Text('${meal.mealName}を削除しますか？'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('キャンセル'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text(
                                '削除',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                  );
                  if (confirmed == true) {
                    await ref
                        .read(mealRecordsProvider.notifier)
                        .deleteMealRecord(meal.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${meal.mealName}を削除しました'),
                          action: SnackBarAction(
                            label: '元に戻す',
                            onPressed: () async {
                              await ref
                                  .read(mealRecordsProvider.notifier)
                                  .addMealRecord(meal);
                            },
                          ),
                        ),
                      );
                    }
                    return true;
                  }
                  return false;
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Consumer(
                  builder: (context, ref, _) {
                    final score = ref.watch(mealScoreProvider(meal));
                    return MealRecordCard(
                      mealRecord: meal,
                      scoreGrade: score?.grade,
                      onTap: () {
                        context.push(TontonRoutes.editMeal, extra: meal);
                      },
                    );
                  },
                ),
              );
            },
          ),
      ],
    );
  }
}
