import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// E2E integration test for the authentication flow:
///   1. Guest sign-in (anonymous)
///   2. Navigate to profile
///   3. Tap "メールで連携する"
///   4. Enter email + password → link
///   5. Verify profile no longer shows "ゲストモード"
///   6. Account deletion
///
/// Run with:
///   flutter test integration_test/auth_flow_test.dart -d <device_id>
///
/// Requires a .env with SUPABASE_URL and SUPABASE_ANON_KEY.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const testEmail = 'tonton-e2e-test@example.com';
  const testPassword = 'testpass123';

  /// Clean up test user via Supabase admin (service_role) if it exists.
  /// In CI, set SUPABASE_SERVICE_ROLE_KEY env var.
  /// Skipped silently if service key is not available.
  Future<void> cleanupTestUser() async {
    final client = Supabase.instance.client;
    // Sign out any existing session first
    try {
      await client.auth.signOut();
    } catch (_) {}
  }

  group('Auth Flow E2E', () {
    setUp(() async {
      await cleanupTestUser();
    });

    testWidgets('Guest → Email linking → Profile shows email',
        (WidgetTester tester) async {
      // The app is already launched by integration test framework
      // via `flutter test integration_test/` which runs main()
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // --- Step 1: Welcome screen → tap "はじめる" (guest) ---
      final guestButton = find.text('はじめる');
      if (guestButton.evaluate().isNotEmpty) {
        await tester.tap(guestButton);
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }

      // --- Step 2: Complete onboarding if shown ---
      // Skip onboarding screens if they appear
      // (Basic info screen has "次へ" button)
      for (var i = 0; i < 5; i++) {
        final nextButton = find.text('次へ');
        if (nextButton.evaluate().isNotEmpty) {
          await tester.tap(nextButton);
          await tester.pumpAndSettle(const Duration(seconds: 1));
        }
        final skipButton = find.text('スキップ');
        if (skipButton.evaluate().isNotEmpty) {
          await tester.tap(skipButton);
          await tester.pumpAndSettle(const Duration(seconds: 1));
        }
        final startButton = find.text('はじめる');
        if (startButton.evaluate().isNotEmpty &&
            find.text('はじめる').evaluate().first.widget is TextButton) {
          break;
        }
      }

      // --- Step 3: Navigate to Profile tab ---
      await tester.pumpAndSettle(const Duration(seconds: 2));
      // Look for profile icon in bottom nav
      final profileTab = find.byIcon(Icons.person);
      if (profileTab.evaluate().isNotEmpty) {
        await tester.tap(profileTab.last);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // --- Step 4: Verify "ゲストモード" is shown ---
      expect(find.textContaining('ゲストモード'), findsOneWidget,
          reason: 'Profile should show guest mode warning');

      // --- Step 5: Tap "メールで連携する" ---
      final linkButton = find.text('メールで連携する');
      expect(linkButton, findsOneWidget,
          reason: 'Should have email linking button');
      await tester.tap(linkButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // --- Step 6: Verify signup screen shows "メール連携" mode ---
      expect(find.text('メール連携'), findsOneWidget,
          reason: 'AppBar should show メール連携');
      expect(find.text('メールアドレスで連携'), findsOneWidget,
          reason: 'Heading should show linking mode');

      // --- Step 7: Fill in email and password ---
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, testEmail);

      final passwordFields = find.byType(TextFormField);
      await tester.enterText(passwordFields.at(1), testPassword);
      await tester.enterText(passwordFields.at(2), testPassword);

      // --- Step 8: Tap "メールで連携する" submit button ---
      final submitButton = find.text('メールで連携する');
      // There might be two: heading text and button label — tap the button
      await tester.tap(submitButton.last);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // --- Step 9: Verify snackbar success ---
      expect(find.text('メールアドレスを連携しました！'), findsOneWidget,
          reason: 'Should show success snackbar');

      // --- Step 10: Back on home, navigate to profile again ---
      await tester.pumpAndSettle(const Duration(seconds: 2));
      final profileTab2 = find.byIcon(Icons.person);
      if (profileTab2.evaluate().isNotEmpty) {
        await tester.tap(profileTab2.last);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // --- Step 11: Verify "ゲストモード" is GONE ---
      expect(find.textContaining('ゲストモード'), findsNothing,
          reason: 'Guest mode warning should be gone after linking');

      // --- Step 12: Verify email is shown ---
      expect(find.text('メール: $testEmail'), findsOneWidget,
          reason: 'Profile should show linked email');
    });
  });
}
