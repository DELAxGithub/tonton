import 'package:shared_preferences/shared_preferences.dart';

import '../providers/onboarding_start_date_provider.dart';

/// Handles persistence of onboarding status and first launch timestamp.
class OnboardingService {
  OnboardingService(this._startDateNotifier);

  final OnboardingStartDateNotifier _startDateNotifier;

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

  /// Initializes first launch and start date if this is the first app run.
  Future<void> ensureInitialized() async {
    final firstLaunch = await getFirstLaunch();
    if (firstLaunch == null) {
      final now = DateTime.now();
      await setFirstLaunch(now);
      await _startDateNotifier.setDate(now);
    } else if (_startDateNotifier.state == null) {
      // Auto-detect start date based on first launch if not set
      await _startDateNotifier.setDate(firstLaunch);
    }
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
