import 'package:flutter/material.dart';

/// Extension that mimics the behavior of Flutter's upcoming `withValues` method.
/// Only the alpha channel is configurable for now, matching uses in this repo.
extension ColorWithValues on Color {
  Color withValues({int? alpha, int? red, int? green, int? blue}) {
    return Color.fromARGB(
      alpha ?? this.alpha,
      red ?? this.red,
      green ?? this.green,
      blue ?? this.blue,
    );
  }
}
