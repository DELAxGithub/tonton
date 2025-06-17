import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/templates/standard_page_layout.dart';
import '../../../design_system/atoms/tonton_button.dart';
import '../../../providers/providers.dart';
import '../../../utils/icon_mapper.dart';
import 'package:go_router/go_router.dart';
import '../../../routes/router.dart';

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
        ],
      ),
    );
  }
}
