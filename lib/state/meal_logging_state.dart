import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents the current step in the AI meal logging flow.
enum MealLoggingStep { camera, analyzing, confirm }

/// Simple provider storing the current [MealLoggingStep].
final mealLoggingStepProvider = StateProvider<MealLoggingStep>((ref) {
  return MealLoggingStep.camera;
});