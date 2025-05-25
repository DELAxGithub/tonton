import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/daily_summary_data_service.dart';
import 'providers.dart';

class OnboardingStartDateNotifier extends StateNotifier<DateTime?> {
  OnboardingStartDateNotifier(this._summaryService) : super(null) {
    _load();
  }

  final DailySummaryDataService _summaryService;

  /// Exposes the current start date value.
  DateTime? get current => state;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final iso = prefs.getString('onboardingStartDate');
    if (iso != null) state = DateTime.tryParse(iso);
  }

  Future<void> setDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('onboardingStartDate', date.toIso8601String());
    state = date;
    // Clear cached summaries so they refresh for the new start date
    await _summaryService.clearAll();
  }
}

final onboardingStartDateProvider =
    StateNotifierProvider<OnboardingStartDateNotifier, DateTime?>(
  (ref) {
    final dataService = ref.read(dailySummaryDataServiceProvider);
    return OnboardingStartDateNotifier(dataService);
  },
);
