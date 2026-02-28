import 'package:flutter/material.dart';
import '../../theme/colors.dart';

/// A simple scaffold wrapper that provides a consistent page layout.
/// Used as the shell for StatefulShellRoute — the body is the navigation shell
/// (IndexedStack) which preserves tab state across switches.
class AppShell extends StatelessWidget {
  /// Main content of the page (typically StatefulNavigationShell).
  final Widget body;

  /// Optional bottom navigation bar.
  final Widget? bottomNavigationBar;

  /// Background color for the scaffold.
  final Color? backgroundColor;

  const AppShell({
    super.key,
    required this.body,
    this.bottomNavigationBar,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? TontonColors.bgPrimary,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
