import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/templates/standard_page_layout.dart';
import '../../../design_system/atoms/tonton_button.dart';
import '../../../providers/providers.dart';
import '../../../utils/icon_mapper.dart';
import 'package:go_router/go_router.dart';
import '../../../routes/router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _showDeleteAccountDialog(BuildContext context, WidgetRef ref) async {
    final authService = ref.read(authServiceProvider);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('アカウント削除の確認'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('本当にアカウントを削除しますか？'),
              SizedBox(height: 16),
              Text(
                'この操作は取り消すことができません。',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                '• すべての体重データが削除されます\n'
                '• すべての目標設定が削除されます\n'
                '• プロフィール情報が削除されます',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('削除する'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        await authService.deleteAccount();
        
        // The deletion will automatically sign out the user
        // and the auth state change will redirect to login
      } catch (e) {
        // Hide loading indicator
        if (context.mounted) {
          Navigator.of(context).pop();
          
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('アカウントの削除に失敗しました: $e'),
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
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: StandardPageLayout(
        children: [
          ListTile(
            leading: Icon(TontonIcons.profile),
            title: const Text('プロフィール'),
            onTap: () => context.push(TontonRoutes.profile),
          ),
          const SizedBox(height: 24),
          TontonButton.secondary(
            label: 'ログアウト',
            icon: TontonIcons.arrow,
            onPressed: () async {
              await authService.signOut();
            },
          ),
          const SizedBox(height: 16),
          TontonButton(
            label: 'アカウント削除',
            icon: CupertinoIcons.delete,
            onPressed: () => _showDeleteAccountDialog(context, ref),
            style: TontonButtonStyle.destructive,
          ),
        ],
      ),
    );
  }
}
