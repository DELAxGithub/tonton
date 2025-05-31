import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider_pkg;
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../design_system/templates/standard_page_layout.dart';
import '../../../design_system/atoms/tonton_button.dart';
import '../../../providers/onboarding_start_date_provider.dart';
import '../../../providers/onboarding_providers.dart';
import '../../../providers/health_provider.dart';
import '../../../routes/router.dart';

/// Simple onboarding screen requesting permissions on first launch.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  Future<void> _requestPermissions(BuildContext context) async {
    // Request HealthKit permissions via existing provider
    final health = provider_pkg.Provider.of<HealthProvider>(context, listen: false);
    await health.requestPermissions();

    // Attempt to trigger camera permission by opening and immediately disposing image picker
    try {
      final picker = ImagePicker();
      await picker.pickImage(source: ImageSource.camera);
    } catch (_) {
      // Ignore any errors or cancellations
    }
  }

  Future<void> _complete(BuildContext context, WidgetRef ref) async {
    await _requestPermissions(context);

    final service = ref.read(onboardingServiceProvider);
    await service.completeOnboarding();
    // Update reactive onboarding completion state
    await ref.read(onboardingCompletedProvider.notifier).complete();

    // Save default start date if not set
    if (ref.read(onboardingStartDateProvider) == null) {
      await ref.read(onboardingStartDateProvider.notifier).setDate(DateTime.now());
    }

    if (context.mounted) {
      context.go(TontonRoutes.onboardingStartDate);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('ようこそ')),
      body: StandardPageLayout(
        children: [
          const Text('TonTonへようこそ！\nヘルスケアデータとカメラへのアクセス許可が必要です。'),
          const SizedBox(height: 24),
          TontonButton.primary(
            label: '許可してはじめる',
            onPressed: () => _complete(context, ref),
          ),
        ],
      ),
    );
  }
}
