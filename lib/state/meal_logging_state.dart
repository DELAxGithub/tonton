import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Simple enum representing the current step in the AI meal logging flow.
enum MealLoggingStep { camera, analyzing, confirm }

/// State notifier tracking the current step.
class MealLoggingStateNotifier extends StateNotifier<MealLoggingStep> {
  MealLoggingStateNotifier() : super(MealLoggingStep.camera);

  void toAnalyzing() => state = MealLoggingStep.analyzing;
  void toConfirm() => state = MealLoggingStep.confirm;
  void reset() => state = MealLoggingStep.camera;
}

/// Provider exposing the current [MealLoggingStep].
final mealLoggingStepProvider =
    StateNotifierProvider<MealLoggingStateNotifier, MealLoggingStep>(
        (ref) => MealLoggingStateNotifier());
