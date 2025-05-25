// Export all providers for convenient imports
export 'meal_records_provider.dart';
export 'ai_advice_provider.dart';
export 'savings_balance_provider.dart';
export 'onboarding_start_date_provider.dart';
export 'onboarding_providers.dart';
export 'pfc_balance_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/meal_data_service.dart';

// Provider for MealDataService
// This service should be initialized, perhaps in main.dart or via a FutureProvider if async init is complex.
// For simplicity, assuming MealDataService.init() is called during app startup (e.g. in main.dart after _initHive).
// Or, the service itself handles lazy initialization.
final mealDataServiceProvider = Provider<MealDataService>((ref) {
  // If MealDataService was a singleton or had a complex async init,
  // you might use a StateNotifierProvider or FutureProvider.
  // For now, a simple Provider returning a new instance, assuming its init() is called elsewhere or it lazy loads.
  // Let's assume its init() needs to be called. We can't await here directly in a simple Provider.
  // A better approach might be a FutureProvider or initializing it in main and providing the instance.
  // For now, we'll create it and expect init to be called.
  final service = MealDataService();
  // It's better to ensure init is called. One way is to make the provider a FutureProvider
  // or ensure MealDataService handles its initialization robustly if init() isn't called before use.
  // The current MealDataService.init() tries to get an open box or open it, which is reasonable.
  return service;
});
