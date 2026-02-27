import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../routes/router.dart';
import '../../../design_system/templates/standard_page_layout.dart';
import '../../../design_system/atoms/tonton_button.dart';
import '../../../providers/providers.dart';
import '../../../theme/colors.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  bool get _isLinkingAnonymous => ref.read(isAnonymousProvider);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final authService = ref.read(authServiceProvider);
      final isLinking = _isLinkingAnonymous;
      try {
        await authService.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isLinking ? 'メールアドレスを連携しました！' : 'アカウントを作成しました！',
            ),
          ),
        );
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

  @override
  Widget build(BuildContext context) {
    final isLinking = _isLinkingAnonymous;
    return Scaffold(
      appBar: AppBar(title: Text(isLinking ? 'メール連携' : 'アカウント作成')),
      body: StandardPageLayout(
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isLinking ? 'メールアドレスで連携' : 'TonTonをはじめよう！',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                if (isLinking) ...[
                  const SizedBox(height: 8.0),
                  Text(
                    'データを引き継いだまま\nメールアドレスでログインできるようになります',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: TontonColors.secondaryLabel,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
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
                    if (value.length < 6) {
                      return 'パスワードは6文字以上にしてください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'パスワード（確認）',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'パスワードを再入力してください';
                    }
                    if (value != _passwordController.text) {
                      return 'パスワードが一致しません';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TontonButton.primary(
                        label: isLinking ? 'メールで連携する' : 'アカウント作成',
                        onPressed: _isLoading ? null : _signup,
                      ),
                if (!isLinking) ...[
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('アカウントをお持ちの方'),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => context.go(TontonRoutes.login),
                        child: const Text('ログイン'),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
