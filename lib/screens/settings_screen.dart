import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../design_system/templates/standard_page_layout.dart';
import '../design_system/atoms/tonton_button.dart';
import '../providers/auth_provider.dart';
import '../utils/icon_mapper.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: StandardPageLayout(
        children: [
          ListTile(
            leading: Icon(TontonIcons.profile),
            title: const Text('プロフィール編集'),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('準備中です')), // TODO
            ),
          ),
          ListTile(
            leading: Icon(TontonIcons.info),
            title: const Text('アプリ情報'),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('準備中です')), // TODO
            ),
          ),
          const SizedBox(height: 24),
          TontonButton.secondary(
            label: 'ログアウト',
            leading: TontonIcons.arrow,
            onPressed: () async {
              await authService.signOut();
            },
          ),
        ],
      ),
    );
  }
}
