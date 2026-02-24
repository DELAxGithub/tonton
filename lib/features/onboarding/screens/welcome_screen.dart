import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/providers.dart';
import '../../../routes/router.dart';
import '../../../theme/colors.dart';
import '../../../utils/icon_mapper.dart';

/// Welcome screen shown on first launch or when no session exists.
/// Offers guest mode and email login options.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool _isLoading = false;

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
    return Scaffold(
      backgroundColor: TontonColors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Mascot icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: TontonColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: TontonColors.pigPink.withValues(alpha: 0.3),
                      offset: const Offset(0, 8),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: Icon(
                  TontonIcons.pigface,
                  size: 56,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // App name
              Text(
                'TonTon',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: TontonColors.label,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),

              // Tagline
              Text(
                'かしこく食べて、\nたのしく貯める。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: TontonColors.secondaryLabel,
                  height: 1.4,
                ),
              ),

              const Spacer(flex: 3),

              // Guest mode button (primary)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signInAsGuest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TontonColors.pigPink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('はじめる'),
                ),
              ),
              const SizedBox(height: 24),

              // Email login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'アカウントをお持ちの方',
                    style: TextStyle(
                      fontSize: 15,
                      color: TontonColors.secondaryLabel,
                    ),
                  ),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => context.go(TontonRoutes.login),
                    child: Text(
                      'ログイン',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: TontonColors.pigPink,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
