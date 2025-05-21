import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../utils/icon_mapper.dart';
import '../routes/router.dart';

class MainNavigationBar extends StatelessWidget {
  final String location;
  const MainNavigationBar({super.key, required this.location});

  int _locationToIndex(String loc) {
    if (loc.startsWith(TontonRoutes.activity)) return 1;
    if (loc.startsWith(TontonRoutes.meals)) return 2;
    if (loc.startsWith(TontonRoutes.insights)) return 3;
    return 0;
  }

  void _onTap(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(TontonRoutes.home);
        break;
      case 1:
        context.go(TontonRoutes.activity);
        break;
      case 2:
        context.go(TontonRoutes.meals);
        break;
      case 3:
        context.go(TontonRoutes.insights);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentIndex = _locationToIndex(location);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (index) => _onTap(index, context),
      items: [
        BottomNavigationBarItem(
          icon: Icon(TontonIcons.home),
          label: l10n.tabHome,
        ),
        BottomNavigationBarItem(
          icon: Icon(TontonIcons.activity),
          label: l10n.tabActivity,
        ),
        BottomNavigationBarItem(
          icon: Icon(TontonIcons.food),
          label: l10n.tabMeals,
        ),
        BottomNavigationBarItem(
          icon: Icon(TontonIcons.insights),
          label: l10n.tabInsights,
        ),
      ],
    );
  }
}
