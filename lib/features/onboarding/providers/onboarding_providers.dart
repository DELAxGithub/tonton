// 1. All import directives first
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/onboarding_service.dart'; // Assuming this path is correct
import '../../../services/health_service.dart';
import '../../../core/providers/onboarding_start_date_provider.dart'; // Assuming this path is correct

// 2. All export directives next
// It seems you want to re-export onboardingCompletedProvider.
// Make sure this export is only here ONCE after resolving conflicts.
export 'onboarding_completion_provider.dart' show onboardingCompletedProvider;

// 3. THEN, all other declarations (providers, functions, classes, etc.)
/// Provides the onboarding service instance.
final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  final startNotifier = ref.read(onboardingStartDateProvider.notifier);
  final healthService = HealthService();
  return OnboardingService(startNotifier, healthService);
});

/// Provides the first launch timestamp if available.
/// NOTE: This provider is currently hardcoded to always return null.
/// If this is intended as a placeholder, that's fine. If it's supposed
/// to actually provide a timestamp, its implementation will need to be updated
/// (e.g., by reading from OnboardingService or SharedPreferences).
/// Provides the persisted first launch timestamp from [OnboardingService].
///
/// Returns `null` if the app has not persisted a timestamp yet. The value is
/// loaded asynchronously from `SharedPreferences` via [OnboardingService].
final firstLaunchTimestampProvider = FutureProvider<DateTime?>((ref) async {
  final onboardingService = ref.watch(onboardingServiceProvider);
  return onboardingService.getFirstLaunch();
});

// Any other providers or declarations for this file would follow here.
