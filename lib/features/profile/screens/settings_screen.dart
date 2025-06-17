import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../design_system/templates/standard_page_layout.dart';
import '../../../design_system/atoms/tonton_button.dart';
import '../../../providers/providers.dart';
import '../../../utils/icon_mapper.dart';
import 'package:go_router/go_router.dart';
import '../../../routes/router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/meal_data_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _openPrivacyPolicy() async {
    final url = Uri.parse('https://delaxgithub.github.io/tonton/privacy-policy');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // Fallback for development/testing
      if (await canLaunchUrl(Uri.parse('mailto:info@delax.co.jp'))) {
        await launchUrl(Uri.parse('mailto:info@delax.co.jp?subject=プライバシーポリシーについて'));
      }
    }
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccount),
        content: Text(l10n.deleteAccountConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.deleteAccount),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Clear local data first
        final mealDataService = ref.read(mealDataServiceProvider);
        await mealDataService.clearAllData();

        // Delete Supabase account
        final authService = ref.read(authServiceProvider);
        await authService.deleteAccount();

        if (context.mounted) {
          // Navigate to login screen
          context.go(TontonRoutes.login);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('アカウントが削除されました'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('アカウント削除に失敗しました: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: StandardPageLayout(
        children: [
          ListTile(
            leading: Icon(TontonIcons.profile),
            title: const Text('プロフィール'),
            onTap: () => context.push(TontonRoutes.profile),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.privacyPolicy),
            trailing: const Icon(Icons.open_in_new),
            onTap: _openPrivacyPolicy,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: Text(l10n.deleteAccount),
            titleTextStyle: const TextStyle(color: Colors.red),
            onTap: () => _deleteAccount(context, ref),
          ),
          const SizedBox(height: 24),
          TontonButton.secondary(
            label: 'ログアウト',
            icon: TontonIcons.arrow,
            onPressed: () async {
              await authService.signOut();
            },
          ),
        ],
      ),
    );
  }
}
