import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // For AuthState and User
import '../../services/auth_service.dart';

// Provider for AuthService instance
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// StreamProvider for authentication state changes
// This directly exposes the Supabase AuthState stream
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Provider for the current user
// This depends on authStateChangesProvider to rebuild when auth state changes
final currentUserProvider = Provider<User?>((ref) {
  // Listen to the authStateChangesProvider. When it emits a new AuthState,
  // this provider will re-evaluate and return the current user.
  // This is a common pattern to get the User object reactively.
  final authState = ref.watch(authStateChangesProvider);
  return authState
      .value
      ?.session
      ?.user; // Access user from session within AuthState
});

// A more specific provider that just tells if a user is logged in or not,
// which can be useful for quick boolean checks in the UI.
final isLoggedInProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

// Provider to check if the current user is anonymous
final isAnonymousProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isAnonymous ?? false;
});
