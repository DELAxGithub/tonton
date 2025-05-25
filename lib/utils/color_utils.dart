import 'package:flutter/material.dart';

/// Extension that mimics the behavior of Flutter's upcoming `withValues` method.
/// Only the alpha channel is configurable for now, matching uses in this repo.
extension ColorWithValues on Color {
  Color withValues({double? opacity, int? red, int? green, int? blue}) {
    return Color.fromARGB(
      opacity != null ? (opacity * 255).round() : this.alpha,
      red ?? this.red,
      green ?? this.green,
      blue ?? this.blue,
    );
  }
}
