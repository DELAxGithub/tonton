// Export all providers for convenient imports
export 'meal_records_provider.dart';
export 'ai_advice_provider.dart';
export 'savings_balance_provider.dart';
export 'onboarding_start_date_provider.dart';
export 'onboarding_providers.dart';
export 'pfc_balance_provider.dart';
export 'realtime_calories_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/meal_data_service.dart';
import '../services/daily_summary_data_service.dart';

// Provider for MealDataService
// This service should be initialized, perhaps in main.dart or via a FutureProvider if async init is complex.
// For simplicity, assuming MealDataService.init() is called during app startup (e.g. in main.dart after _initHive).
// Or, the service itself handles lazy initialization.
/// Provides the shared [mealDataService] instance.
final mealDataServiceProvider = Provider<MealDataService>((ref) {
  return mealDataService;
});

final dailySummaryDataServiceProvider = Provider<DailySummaryDataService>((ref) {
  final service = DailySummaryDataService();
  return service;
});
