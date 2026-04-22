import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../routes/router.dart';
import '../../theme/colors.dart';
import 'providers/meal_entry_target_date_provider.dart';

/// Stores the target date so that the confirm screen can default to it.
/// Pass [targetDate] when invoking from a date-scoped context (e.g. the
/// DailyMealsDetailScreen FAB). Leave null to record for today.
void _setTargetDate(BuildContext context, DateTime? targetDate) {
  final container = ProviderScope.containerOf(context, listen: false);
  container.read(mealEntryTargetDateProvider.notifier).state = targetDate;
}

void showMealInputOptions(BuildContext context, {DateTime? targetDate}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: TontonColors.pigPink.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.photo_camera, color: TontonColors.pigPink),
              ),
              title: const Text('写真で記録'),
              subtitle: const Text('食事を撮影してAIが栄養素を分析'),
              onTap: () {
                Navigator.pop(ctx);
                _setTargetDate(context, targetDate);
                context.go(TontonRoutes.aiMealCamera);
              },
            ),
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: TontonColors.pigPink.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.edit_note, color: TontonColors.pigPink),
              ),
              title: const Text('テキストで記録'),
              subtitle: const Text('料理名を入力してAIが栄養素を推定'),
              onTap: () {
                Navigator.pop(ctx);
                _setTargetDate(context, targetDate);
                context.push(TontonRoutes.textMealInput);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

void goToMealCamera(BuildContext context, {DateTime? targetDate}) {
  _setTargetDate(context, targetDate);
  context.go(TontonRoutes.aiMealCamera);
}
