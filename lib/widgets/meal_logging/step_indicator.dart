import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/meal_logging_state.dart';

/// Displays the current step in the AI meal logging flow.
class MealLoggingStepIndicator extends ConsumerWidget {
  const MealLoggingStepIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(mealLoggingStepProvider);
    String label;
    switch (step) {
      case MealLoggingStep.camera:
        label = '写真を撮る';
        break;
      case MealLoggingStep.analyzing:
        label = '解析中';
        break;
      case MealLoggingStep.confirm:
        label = '確認';
        break;
    }
    return Chip(label: Text(label));
  }
}
