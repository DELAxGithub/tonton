import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingCompletionNotifier extends StateNotifier<bool> {
  OnboardingCompletionNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('onboardingCompleted') ?? false;
  }

  Future<void> complete() async {
    state = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingCompleted', true);
  }
}

final onboardingCompletedProvider =
    StateNotifierProvider<OnboardingCompletionNotifier, bool>(
        (ref) => OnboardingCompletionNotifier());
