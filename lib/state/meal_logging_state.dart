import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Simple state notifier to track whether a meal logging flow is active.
class MealLoggingState extends StateNotifier<bool> {
  MealLoggingState() : super(false);

  void start() => state = true;
  void stop() => state = false;
}

/// Provider for the [MealLoggingState].
final mealLoggingStateProvider =
    StateNotifierProvider<MealLoggingState, bool>((ref) {
  return MealLoggingState();
});
