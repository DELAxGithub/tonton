import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/onboarding_service.dart';
import 'onboarding_start_date_provider.dart';

/// Provides the onboarding service instance.
final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  return OnboardingService(ref.read(onboardingStartDateProvider.notifier));
});

/// Provides the persisted onboarding completion status.
final onboardingCompletedProvider = Provider<bool>((ref) => throw UnimplementedError());

/// Provides the first launch timestamp if available.
final firstLaunchTimestampProvider = Provider<DateTime?>((ref) => null);
