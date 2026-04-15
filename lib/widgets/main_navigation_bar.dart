import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/colors.dart';
import '../theme/app_theme.dart' as app_theme;
import '../utils/icon_mapper.dart';
import '../features/meal_logging/meal_entry_actions.dart';

/// Bottom navigation bar matching .pen TabBar design with camera FAB overlay.
/// Uses StatefulNavigationShell.goBranch() for state-preserving tab switches.
class MainNavigationBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainNavigationBar({super.key, required this.navigationShell});

  void _onTap(int index, BuildContext context) {
    // Map visual tab index to branch index:
    // visual 0 → branch 0 (home)
    // visual 1 → branch 1 (progress)
    // visual 2 → spacer (FAB, not tappable)
    // visual 3 → branch 2 (savings)
    // visual 4 → branch 3 (profile)
    final branchIndex = switch (index) {
      0 => 0,
      1 => 1,
      3 => 2,
      4 => 3,
      _ => navigationShell.currentIndex,
    };
    navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }

  int _branchToVisualIndex(int branch) {
    return switch (branch) {
      0 => 0, // home
      1 => 1, // progress
      2 => 3, // savings
      3 => 4, // profile
      _ => 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    final currentVisualIndex = _branchToVisualIndex(navigationShell.currentIndex);

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
                  isSelected: currentVisualIndex == 0,
                  onTap: () => _onTap(0, context),
                ),
                _TabItem(
                  icon: Icons.bar_chart,
                  label: '記録',
                  isSelected: currentVisualIndex == 1,
                  onTap: () => _onTap(1, context),
                ),
                // Spacer for FAB
                const SizedBox(width: 56),
                _TabItem(
                  icon: Icons.savings_outlined,
                  label: '貯金',
                  isSelected: currentVisualIndex == 3,
                  onTap: () => _onTap(3, context),
                ),
                _TabItem(
                  icon: Icons.person_outline,
                  label: '設定',
                  isSelected: currentVisualIndex == 4,
                  onTap: () => _onTap(4, context),
                ),
              ],
            ),
          ),

          // Meal logging FAB — tap for picker modal, long-press for camera
          Positioned(
            top: -20,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => showMealInputOptions(context),
                onLongPress: () => goToMealCamera(context),
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
                    Icons.add,
                    color: Colors.white,
                    size: 28,
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
