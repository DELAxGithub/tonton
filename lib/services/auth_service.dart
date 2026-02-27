import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Sign up with email and password
  // If the current user is anonymous, links email+password to the existing account
  // via updateUser (preserving user ID and data). Otherwise creates a new account.
  Future<void> signUp({required String email, required String password}) async {
    try {
      final currentUser = _supabase.auth.currentUser;

      if (currentUser?.isAnonymous == true) {
        // Anonymous → email linking
        developer.log(
          'Linking anonymous user ${currentUser!.id} to email: $email',
          name: 'TonTon.AuthService',
        );
        final UserResponse res = await _supabase.auth.updateUser(
          UserAttributes(
            email: email,
            password: password,
          ),
        );
        if (res.user == null) {
          developer.log(
            'Anonymous linking failed: No user returned.',
            name: 'TonTon.AuthService.Error',
          );
          throw Exception('アカウント連携に失敗しました。');
        }
        // Refresh session to get a new JWT with is_anonymous: false
        await _supabase.auth.refreshSession();
        developer.log(
          'Anonymous user linked successfully: ${res.user!.id}, isAnonymous: ${_supabase.auth.currentUser?.isAnonymous}',
          name: 'TonTon.AuthService',
        );
      } else {
        // Normal sign up for non-anonymous (or no session)
        developer.log(
          'Attempting to sign up user: $email',
          name: 'TonTon.AuthService',
        );
        final AuthResponse res = await _supabase.auth.signUp(
          email: email,
          password: password,
        );
        if (res.user == null) {
          developer.log(
            'Sign up failed: No user returned, but no Supabase error.',
            name: 'TonTon.AuthService.Error',
          );
          throw Exception('アカウント作成に失敗しました。');
        }
        developer.log(
          'Sign up successful for user: ${res.user!.id}',
          name: 'TonTon.AuthService',
        );
      }
    } on AuthException catch (e) {
      developer.log(
        'Supabase AuthException during sign up: ${e.message}',
        name: 'TonTon.AuthService.Error',
        error: e,
      );
      throw Exception('アカウント作成に失敗しました: ${e.message}');
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected error during sign up: $e',
        name: 'TonTon.AuthService.Exception',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('アカウント作成に失敗しました。');
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
        throw Exception('ログインに失敗しました。');
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
      if (e.message.toLowerCase().contains('invalid login credentials')) {
        throw Exception('メールアドレスまたはパスワードが正しくありません。');
      }
      throw Exception('ログインに失敗しました: ${e.message}');
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected error during sign in: $e',
        name: 'TonTon.AuthService.Exception',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('ログインに失敗しました。');
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
      throw Exception('ログアウトに失敗しました: ${e.message}');
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected error during sign out: $e',
        name: 'TonTon.AuthService.Exception',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('ログアウトに失敗しました。');
    }
  }

  // Stream of authentication state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Returns true if the current user is an anonymous user.
  /// Checks email as fallback since Supabase may not flip is_anonymous after linking.
  bool get isAnonymous {
    final user = currentUser;
    if (user == null) return false;
    if (user.email != null && user.email!.isNotEmpty) return false;
    return user.isAnonymous;
  }

  /// Sign in anonymously - creates a new anonymous user
  Future<void> signInAnonymously() async {
    try {
      developer.log(
        'Attempting anonymous sign in',
        name: 'TonTon.AuthService',
      );
      final AuthResponse res = await _supabase.auth.signInAnonymously();
      if (res.user == null) {
        developer.log(
          'Anonymous sign in failed: No user returned',
          name: 'TonTon.AuthService.Error',
        );
        throw Exception('ゲストモードの開始に失敗しました。');
      }
      developer.log(
        'Anonymous sign in successful: ${res.user!.id}',
        name: 'TonTon.AuthService',
      );
    } on AuthException catch (e) {
      developer.log(
        'AuthException during anonymous sign in: ${e.message}',
        name: 'TonTon.AuthService.Error',
        error: e,
      );
      throw Exception('ゲストモードの開始に失敗しました: ${e.message}');
    } catch (e, stackTrace) {
      developer.log(
        'Error during anonymous sign in: $e',
        name: 'TonTon.AuthService.Exception',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      developer.log(
        'Attempting to delete account',
        name: 'TonTon.AuthService',
      );
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('ログインしていません。');
      }

      // Edge Function または DB内の RPC ('delete_user') を呼び出してユーザーを削除する
      // ※Supabaseクライアントから自分自身を削除するには、通常セキュリティ・ディファイナーのRPCかEdge Functionが必要です。
      await _supabase.rpc('delete_user');
      
      // 削除後、ログアウト処理を行う
      await signOut();
      
      developer.log(
        'Account deleted successfully',
        name: 'TonTon.AuthService',
      );
    } on AuthException catch (e) {
      developer.log(
        'AuthException during account deletion: ${e.message}',
        name: 'TonTon.AuthService.Error',
        error: e,
      );
      throw Exception('アカウント削除に失敗しました: ${e.message}');
    } catch (e, stackTrace) {
      developer.log(
        'Error during account deletion: $e',
        name: 'TonTon.AuthService.Exception',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('アカウント削除に失敗しました。');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      developer.log(
        'Attempting to send password reset email',
        name: 'TonTon.AuthService',
      );
      await _supabase.auth.resetPasswordForEmail(email);
      developer.log(
        'Password reset email sent to $email',
        name: 'TonTon.AuthService',
      );
    } on AuthException catch (e) {
      developer.log(
        'AuthException during password reset: ${e.message}',
        name: 'TonTon.AuthService.Error',
        error: e,
      );
      throw Exception('パスワードリセットメールの送信に失敗しました: ${e.message}');
    } catch (e, stackTrace) {
      developer.log(
        'Error during password reset: $e',
        name: 'TonTon.AuthService.Exception',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('パスワードリセットメールの送信に失敗しました。');
    }
  }
}
