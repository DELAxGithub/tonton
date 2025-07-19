// Export all providers for convenient imports
// Core providers
export '../core/providers/auth_provider.dart';
export '../core/providers/calorie_savings_provider.dart';
export '../core/providers/health_provider.dart';
export '../core/providers/monthly_progress_provider.dart';
export '../core/providers/onboarding_start_date_provider.dart';
export '../core/providers/realtime_calories_provider.dart';
export '../core/providers/user_weight_provider.dart';

// Feature-specific providers
export '../features/health/providers/last_health_fetch_provider.dart';
export '../features/health/providers/weight_record_provider.dart';
export '../features/health/providers/weight_history_provider.dart';
export '../features/meal_logging/providers/ai_advice_provider.dart';
export '../features/meal_logging/providers/ai_estimation_provider.dart';
export '../features/meal_logging/providers/meal_records_provider.dart';
export '../features/onboarding/providers/onboarding_completion_provider.dart';
export '../features/onboarding/providers/onboarding_providers.dart';
export '../features/profile/providers/user_profile_provider.dart';
export '../features/progress/providers/pfc_balance_provider.dart';
export '../features/progress/providers/selected_period_provider.dart';
export '../features/savings/providers/savings_balance_provider.dart';

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

final dailySummaryDataServiceProvider = Provider<DailySummaryDataService>((
  ref,
) {
  final service = DailySummaryDataService();
  return service;
});
