import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:tonton/main.dart';
import 'package:tonton/features/onboarding/onboarding_screen.dart';
import 'package:tonton/screens/home_screen.dart';
import 'package:tonton/routes/router.dart';
import 'package:tonton/providers/onboarding_completion_provider.dart';

class TestOnboardingCompletionNotifier extends OnboardingCompletionNotifier {
  TestOnboardingCompletionNotifier(bool value) : super() {
    state = value;
  }
}

void main() {
  GoRouter createTestRouter(Ref ref) {
    final completed = ref.watch(onboardingCompletedProvider);
    return GoRouter(
      initialLocation: completed ? TontonRoutes.home : TontonRoutes.onboardingIntro,
      routes: [
        GoRoute(
          path: TontonRoutes.home,
          builder: (_, __) => const HomeScreen(),
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
          onboardingCompletedProvider.overrideWith(
            (ref) => TestOnboardingCompletionNotifier(false)
                as OnboardingCompletionNotifier,
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
          onboardingCompletedProvider.overrideWith(
            (ref) => TestOnboardingCompletionNotifier(true)
                as OnboardingCompletionNotifier,
          ),
          routerProvider.overrideWith((ref) => createTestRouter(ref)),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
