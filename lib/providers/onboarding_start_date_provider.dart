import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingStartDateNotifier extends StateNotifier<DateTime?> {
  OnboardingStartDateNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final iso = prefs.getString('onboardingStartDate');
    if (iso != null) state = DateTime.tryParse(iso);
  }

  Future<void> setDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('onboardingStartDate', date.toIso8601String());
    state = date;
  }
}

final onboardingStartDateProvider =
    StateNotifierProvider<OnboardingStartDateNotifier, DateTime?>(
        (ref) => OnboardingStartDateNotifier());
