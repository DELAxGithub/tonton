import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider_pkg;
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../design_system/templates/standard_page_layout.dart';
import '../../../design_system/atoms/tonton_button.dart';
import '../../../providers/providers.dart';
import '../providers/onboarding_providers.dart';
import '../../../routes/router.dart';

class HealthKitScreen extends ConsumerWidget {
  const HealthKitScreen({super.key});

  Future<void> _requestPermissions(BuildContext context) async {
    // Request HealthKit permissions via existing provider
    final health = provider_pkg.Provider.of<HealthProvider>(
      context,
      listen: false,
    );
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
      await ref
          .read(onboardingStartDateProvider.notifier)
          .setDate(DateTime.now());
    }

    if (context.mounted) {
      context.go(TontonRoutes.home);
    }
  }

  Future<void> _skipForNow(BuildContext context, WidgetRef ref) async {
    final service = ref.read(onboardingServiceProvider);
    await service.completeOnboarding();
    // Update reactive onboarding completion state
    await ref.read(onboardingCompletedProvider.notifier).complete();

    // Save default start date if not set
    if (ref.read(onboardingStartDateProvider) == null) {
      await ref
          .read(onboardingStartDateProvider.notifier)
          .setDate(DateTime.now());
    }

    if (context.mounted) {
      context.go(TontonRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: StandardPageLayout(
          children: [
            const SizedBox(height: 40),
            // プログレスインジケーター
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // アイコン
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite,
                size: 60,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 32),

            Text('ヘルスケアと連携', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Text(
              'ヘルスケアアプリと連携することで、\n毎日の活動量を自動で記録できます',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // 連携のメリット
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text('歩数や運動の消費カロリーを自動計測'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text('体重の変化を記録'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text('より正確なカロリー貯金の計算'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: TontonButton.primary(
                label: '連携する',
                onPressed: () => _complete(context, ref),
              ),
            ),
            const SizedBox(height: 16),

            TextButton(
              onPressed: () => _skipForNow(context, ref),
              child: Text(
                '今はしない',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
