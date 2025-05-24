import 'package:shared_preferences/shared_preferences.dart';

/// Handles persistence of onboarding status and first launch timestamp.
class OnboardingService {
  static const String _firstLaunchKey = 'firstLaunchTimestamp';
  static const String _completedKey = 'onboardingCompleted';

  Future<DateTime?> getFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final iso = prefs.getString(_firstLaunchKey);
    return iso != null ? DateTime.tryParse(iso) : null;
  }

  Future<void> setFirstLaunch(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_firstLaunchKey, date.toIso8601String());
  }

  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_completedKey) ?? false;
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_firstLaunchKey)) {
      await prefs.setString(_firstLaunchKey, DateTime.now().toIso8601String());
    }
    await prefs.setBool(_completedKey, true);
  }
}
