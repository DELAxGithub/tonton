import 'package:flutter/material.dart';

/// Placeholder widget for missing meal logging UI components.
class MealLoggingPlaceholder extends StatelessWidget {
  final String message;
  const MealLoggingPlaceholder({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(message));
  }
}
