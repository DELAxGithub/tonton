import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../utils/icon_mapper.dart';
import '../routes/router.dart';

class MainNavigationBar extends StatelessWidget {
  final String location;
  const MainNavigationBar({super.key, required this.location});

  int _locationToIndex(String loc) {
    if (loc.startsWith(TontonRoutes.savingsTrend)) return 2;
    if (loc.startsWith(TontonRoutes.aiMealCamera)) return 1;
    return 0;
  }

  void _onTap(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(TontonRoutes.home);
        break;
      case 1:
        context.go(TontonRoutes.aiMealCamera);
        break;
      case 2:
        context.go(TontonRoutes.savingsTrend);
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
            label: l10n.tabHome,
          ),
          BottomNavigationBarItem(
            icon: Icon(TontonIcons.camera),
            label: l10n.tabRecord,
          ),
          BottomNavigationBarItem(
            icon: Icon(TontonIcons.graph),
            label: 'グラフ',
          ),
        ],
      ),
    );
  }
}
