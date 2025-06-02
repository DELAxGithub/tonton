import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../providers/providers.dart';
import 'meal_record_card.dart';
import '../theme/tokens.dart' as tokens;
import '../theme/typography.dart' as typography;
import '../design_system/molecules/feedback/empty_state.dart';

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
        Text(
          l10n?.todaysMeals ?? "Today's Meals",
          style: typography.TontonTypography.headline,
        ),
        const SizedBox(height: tokens.Spacing.sm),
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
                  // 削除確認ダイアログを表示
                  return await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
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
                },
                onDismissed: (direction) async {
                  // 削除処理
                  await ref.read(mealRecordsProvider.notifier).deleteMealRecord(meal.id);
                  
                  // SnackBarで通知
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${meal.mealName}を削除しました'),
                        action: SnackBarAction(
                          label: '元に戻す',
                          onPressed: () {
                            // TODO: 削除の取り消し機能を実装
                          },
                        ),
                      ),
                    );
                  }
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                child: MealRecordCard(
                  mealRecord: meal,
                  onTap: () {
                    // TODO: 編集画面への遷移を実装
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('編集機能は準備中です'),
                      ),
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
