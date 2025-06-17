import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingCompletionNotifier extends StateNotifier<bool> {
  OnboardingCompletionNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool('onboardingCompleted') ?? false;
    state = completed;
  }

  Future<void> complete() async {
    final prefs = await SharedPreferences.getInstance();

    // Set state first to immediately update UI
    state = true;

    // Then persist to SharedPreferences
    await prefs.setBool('onboardingCompleted', true);

    // Also set the UserProfile completion flag key to ensure synchronization
    await prefs.setBool('user_profile_onboarding_completed', true);
  }

  /// Force reload the completion state from SharedPreferences
  Future<void> reload() async {
    await _load();
  }
}

final onboardingCompletedProvider =
    StateNotifierProvider<OnboardingCompletionNotifier, bool>(
      (ref) => OnboardingCompletionNotifier(),
    );
