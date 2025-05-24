import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/onboarding_service.dart';
import 'onboarding_start_date_provider.dart';
import 'onboarding_completion_provider.dart';

/// Provides the onboarding service instance.
final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  return OnboardingService(ref.read(onboardingStartDateProvider.notifier));
});

// Re-export the notifier provider for onboarding completion.
// This provider reflects whether onboarding has finished and persists
// the flag in SharedPreferences.
export 'onboarding_completion_provider.dart' show onboardingCompletedProvider;

/// Provides the first launch timestamp if available.
final firstLaunchTimestampProvider = Provider<DateTime?>((ref) => null);
