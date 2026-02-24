import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/atoms/tonton_button.dart';
import '../../../design_system/templates/standard_page_layout.dart';
import '../../../routes/router.dart';
import '../../../providers/providers.dart';
import '../../../theme/colors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final authService = ref.read(authServiceProvider);
      try {
        await authService.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (!mounted) return;
        // Router redirect will handle onboarding check
        context.go(TontonRoutes.home);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e.toString().replaceFirst('Exception: ', ''),
              ),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInAsGuest() async {
    setState(() => _isLoading = true);
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInAnonymously();
      if (!mounted) return;
      context.go(TontonRoutes.home);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceFirst('Exception: ', ''),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showPasswordResetDialog() async {
    final resetEmailController = TextEditingController(text: _emailController.text);
    bool isResetting = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('パスワードをリセット'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('登録したメールアドレスを入力してください。パスワードリセット用の手順を送信します。'),
              const SizedBox(height: 16),
              TextField(
                controller: resetEmailController,
                decoration: const InputDecoration(
                  labelText: 'メールアドレス',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isResetting ? null : () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: isResetting
                  ? null
                  : () async {
                      final email = resetEmailController.text.trim();
                      if (email.isEmpty || !email.contains('@')) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('正しいメールアドレスを入力してください')),
                        );
                        return;
                      }

                      setState(() => isResetting = true);
                      try {
                        await ref.read(authServiceProvider).resetPassword(email);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('パスワードリセットの案内メールを送信しました。')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString().replaceFirst('Exception: ', '')),
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() => isResetting = false);
                        }
                      }
                    },
              child: isResetting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('送信する'),
            ),
          ],
        ),
      ),
    );
    resetEmailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ログイン')),
      body: StandardPageLayout(
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'おかえりなさい！',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32.0),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'メールアドレス',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'メールアドレスを入力してください';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return '正しいメールアドレスを入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'パスワード',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'パスワードを入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TontonButton.primary(
                        label: 'ログイン',
                        onPressed: _login,
                      ),
                const SizedBox(height: 16.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading ? null : _showPasswordResetDialog,
                    child: Text(
                      'パスワードを忘れた方',
                      style: TextStyle(
                        color: TontonColors.secondaryLabel,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('アカウントをお持ちでない方'),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => context.go(TontonRoutes.signup),
                      child: const Text('アカウント作成'),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Center(
                  child: TextButton(
                    onPressed: _isLoading ? null : _signInAsGuest,
                    child: Text(
                      'ゲストではじめる',
                      style: TextStyle(
                        color: TontonColors.secondaryLabel,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
