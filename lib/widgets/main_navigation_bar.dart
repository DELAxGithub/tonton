import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../utils/icon_mapper.dart';
import '../routes/router.dart';
import 'ai_advice_modal.dart';

class MainNavigationBar extends StatelessWidget {
  final String location;
  const MainNavigationBar({super.key, required this.location});

  int _locationToIndex(String loc) {
    if (loc.startsWith(TontonRoutes.progress) ||
        loc.startsWith(TontonRoutes.progressAchievements))
      return 1;
    // AIコーチはモーダル表示なので、ルートとしては存在しない
    if (loc.startsWith(TontonRoutes.profile)) return 3;
    return 0;
  }

  void _onTap(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(TontonRoutes.home);
        break;
      case 1:
        context.go(TontonRoutes.progress);
        break;
      case 2:
        // AIアドバイスモーダルを表示
        showAIAdviceModal(context);
        break;
      case 3:
        context.go(TontonRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentIndex = _locationToIndex(location);

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => _onTap(index, context),
        items: [
          BottomNavigationBarItem(
            icon: Icon(TontonIcons.home),
            label: l10n?.tabHome ?? 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'ヒストリー',
          ),
          BottomNavigationBarItem(icon: Icon(TontonIcons.ai), label: 'AIコーチ'),
          BottomNavigationBarItem(
            icon: Icon(TontonIcons.settings),
            label: 'プロフィール',
          ),
        ],
      ),
    );
  }
}
