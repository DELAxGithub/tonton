import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import 'package:tonton/main.dart';
import 'package:tonton/features/onboarding/onboarding_screen.dart';
import 'package:tonton/screens/home_screen_new.dart';
import 'package:tonton/routes/router.dart';
import 'package:tonton/providers/onboarding_providers.dart';

class TestOnboardingCompletionNotifier extends StateNotifier<bool> {
  TestOnboardingCompletionNotifier(bool value) : super(value);
}

void main() {
  GoRouter createTestRouter(Ref ref) {
    final completed = ref.watch(onboardingCompletedProvider);
    return GoRouter(
      initialLocation: completed ? TontonRoutes.home : TontonRoutes.onboardingIntro,
      routes: [
        GoRoute(
          path: TontonRoutes.home,
          builder: (_, __) => const HomeScreenNew(),
        ),
        GoRoute(
          path: TontonRoutes.onboardingIntro,
          builder: (_, __) => const OnboardingScreen(),
        ),
      ],
    );
  }

  testWidgets('shows onboarding on first launch', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingCompletedProvider.overrideWithProvider(
            StateNotifierProvider<TestOnboardingCompletionNotifier, bool>(
              (ref) => TestOnboardingCompletionNotifier(false),
            ),
          ),
          routerProvider.overrideWith((ref) => createTestRouter(ref)),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(OnboardingScreen), findsOneWidget);
  });

  testWidgets('shows home after onboarding complete', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingCompletedProvider.overrideWithProvider(
            StateNotifierProvider<TestOnboardingCompletionNotifier, bool>(
              (ref) => TestOnboardingCompletionNotifier(true),
            ),
          ),
          routerProvider.overrideWith((ref) => createTestRouter(ref)),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(HomeScreenNew), findsOneWidget);
  });
}
