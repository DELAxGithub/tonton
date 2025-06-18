import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Sign up with email and password
  Future<void> signUp({required String email, required String password}) async {
    try {
      developer.log(
        'Attempting to sign up user: $email',
        name: 'TonTon.AuthService',
      );
      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
        // emailRedirectTo: 'io.supabase.flutterquickstart://login-callback/', // Optional: For email confirmation deep link
      );
      if (res.user == null) {
        developer.log(
          'Sign up failed: No user returned, but no Supabase error.',
          name: 'TonTon.AuthService.Error',
        );
        throw Exception('Sign up failed: An unknown error occurred.');
      }
      // Note: If email confirmation is enabled in Supabase, res.user will exist but session might be null until confirmed.
      developer.log(
        'Sign up successful for user: ${res.user!.id}',
        name: 'TonTon.AuthService',
      );
    } on AuthException catch (e) {
      developer.log(
        'Supabase AuthException during sign up: ${e.message}',
        name: 'TonTon.AuthService.Error',
        error: e,
      );
      throw Exception('Sign up failed: ${e.message}');
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected error during sign up: $e',
        name: 'TonTon.AuthService.Exception',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Sign up failed: An unexpected error occurred.');
    }
  }

  // Sign in with email and password
  Future<void> signIn({required String email, required String password}) async {
    try {
      developer.log(
        'Attempting to sign in user: $email',
        name: 'TonTon.AuthService',
      );
      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (res.user == null) {
        developer.log(
          'Sign in failed: No user returned, but no Supabase error.',
          name: 'TonTon.AuthService.Error',
        );
        throw Exception('Sign in failed: An unknown error occurred.');
      }
      developer.log(
        'Sign in successful for user: ${res.user!.id}',
        name: 'TonTon.AuthService',
      );
    } on AuthException catch (e) {
      developer.log(
        'Supabase AuthException during sign in: ${e.message}',
        name: 'TonTon.AuthService.Error',
        error: e,
      );
      // Provide more specific error messages based on common Supabase errors
      if (e.message.toLowerCase().contains('invalid login credentials')) {
        throw Exception('Invalid email or password.');
      }
      throw Exception('Sign in failed: ${e.message}');
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected error during sign in: $e',
        name: 'TonTon.AuthService.Exception',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Sign in failed: An unexpected error occurred.');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      developer.log(
        'Attempting to sign out current user.',
        name: 'TonTon.AuthService',
      );
      await _supabase.auth.signOut();
      developer.log('Sign out successful.', name: 'TonTon.AuthService');
    } on AuthException catch (e) {
      developer.log(
        'Supabase AuthException during sign out: ${e.message}',
        name: 'TonTon.AuthService.Error',
        error: e,
      );
      throw Exception('Sign out failed: ${e.message}');
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected error during sign out: $e',
        name: 'TonTon.AuthService.Exception',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Sign out failed: An unexpected error occurred.');
    }
  }

  // Stream of authentication state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      final userId = currentUser?.id;
      if (userId == null) {
        throw Exception('No user logged in');
      }

      developer.log(
        'Attempting to delete account for user: $userId',
        name: 'TonTon.AuthService',
      );

      // Delete user data from all related tables
      // First delete from child tables (foreign key constraints)
      await _supabase.from('weight_goals').delete().eq('user_id', userId);
      await _supabase.from('measurement_entries').delete().eq('user_id', userId);
      await _supabase.from('profiles').delete().eq('id', userId);
      
      // Sign out the user after deleting their data
      // Note: Complete auth user deletion requires server-side admin privileges
      // For now, we delete all user data and sign them out
      await _supabase.auth.signOut();

      developer.log(
        'Account data deletion and sign out successful for user: $userId',
        name: 'TonTon.AuthService',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error during account deletion: $e',
        name: 'TonTon.AuthService.Exception',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Account deletion failed: $e');
    }
  }
}
