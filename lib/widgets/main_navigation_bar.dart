import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/colors.dart';
import '../theme/app_theme.dart' as app_theme;
import '../utils/icon_mapper.dart';
import '../routes/router.dart';

/// Bottom navigation bar matching .pen TabBar design with camera FAB overlay
class MainNavigationBar extends StatelessWidget {
  final String location;
  const MainNavigationBar({super.key, required this.location});

  int _locationToIndex(String loc) {
    if (loc.startsWith(TontonRoutes.progress) ||
        loc.startsWith(TontonRoutes.progressAchievements))
      return 1;
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
        // 貯金 tab — navigate to progress for now
        context.go(TontonRoutes.progress);
        break;
      case 3:
        context.go(TontonRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _locationToIndex(location);

    return SizedBox(
      height: 84,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Tab bar background
          Container(
            height: 84,
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: TontonColors.shadowSubtle,
                  offset: Offset(0, -1),
                  blurRadius: 8,
                ),
              ],
            ),
            padding: const EdgeInsets.only(top: 8, bottom: 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _TabItem(
                  icon: TontonIcons.home,
                  label: 'ホーム',
                  isSelected: currentIndex == 0,
                  onTap: () => _onTap(0, context),
                ),
                _TabItem(
                  icon: Icons.bar_chart,
                  label: '記録',
                  isSelected: currentIndex == 1,
                  onTap: () => _onTap(1, context),
                ),
                // Spacer for FAB
                const SizedBox(width: 56),
                _TabItem(
                  icon: Icons.savings_outlined,
                  label: '貯金',
                  isSelected: currentIndex == 2,
                  onTap: () => _onTap(2, context),
                ),
                _TabItem(
                  icon: Icons.person_outline,
                  label: '設定',
                  isSelected: currentIndex == 3,
                  onTap: () => _onTap(3, context),
                ),
              ],
            ),
          ),

          // Camera FAB — overlapping at center top
          Positioned(
            top: -20,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => context.go(TontonRoutes.aiMealCamera),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: TontonColors.pigPink,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x40FF9AA2),
                        offset: Offset(0, 4),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.photo_camera,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isSelected ? TontonColors.pigPink : app_theme.TontonColors.textTertiary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
