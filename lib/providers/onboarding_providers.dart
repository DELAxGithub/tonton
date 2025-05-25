// 1. All import directives first
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/onboarding_service.dart'; // Assuming this path is correct
import 'onboarding_start_date_provider.dart'; // Assuming this path is correct
import 'onboarding_completion_provider.dart'; // Assuming this path is correct

// 2. All export directives next
// It seems you want to re-export onboardingCompletedProvider.
// Make sure this export is only here ONCE after resolving conflicts.
export 'onboarding_completion_provider.dart' show onboardingCompletedProvider;

// 3. THEN, all other declarations (providers, functions, classes, etc.)
/// Provides the onboarding service instance.
final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  // Ensure onboardingStartDateProvider.notifier is what you intend to read here
  // Typically, you'd read the provider itself, not just the notifier, unless
  // OnboardingService specifically needs the Notifier instance.
  // If OnboardingService needs the Notifier to call methods on it, this is fine.
  return OnboardingService(ref.read(onboardingStartDateProvider.notifier));
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