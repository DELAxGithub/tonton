import 'package:flutter/material.dart';
import '../atoms/tonton_card_base.dart';
import '../atoms/tonton_icon.dart';
import '../atoms/tonton_text.dart';
import '../../theme/tokens.dart';

class NavigationLinkCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const NavigationLinkCard({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: Radii.mediumBorderRadius,
      child: TontonCardBase(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TontonIcon(icon, size: 32),
            const SizedBox(height: Spacing.xs),
            TontonText(label, align: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
