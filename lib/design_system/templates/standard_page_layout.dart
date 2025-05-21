import 'package:flutter/material.dart';
import '../../theme/tokens.dart';

/// Basic scrollable page layout with consistent padding.
class StandardPageLayout extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  const StandardPageLayout({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.all(Spacing.md),
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
