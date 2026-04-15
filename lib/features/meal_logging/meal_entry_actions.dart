import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../routes/router.dart';
import '../../theme/colors.dart';

void showMealInputOptions(BuildContext context) {
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
                context.push(TontonRoutes.textMealInput);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

void goToMealCamera(BuildContext context) {
  context.go(TontonRoutes.aiMealCamera);
}
