import 'package:flutter/material.dart';

class TontonIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;

  const TontonIcon(
    this.icon, {
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) => Icon(
        icon,
        size: size,
        color: color ?? Theme.of(context).colorScheme.primary,
      );
}
