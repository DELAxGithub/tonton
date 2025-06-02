import 'package:flutter/material.dart';

/// Apple HIG-compliant design tokens for Tonton
/// 
/// This file contains spacing, radius, shadow, and other design tokens
/// following Apple's Human Interface Guidelines.

/// Standard spacing values following Apple HIG
/// Based on 4pt grid system
class Spacing {
  // Private constructor to prevent instantiation
  Spacing._();
  
  /// 4pt - Minimum spacing
  static const double xxs = 4.0;
  
  /// 8pt - Compact spacing
  static const double xs = 8.0;
  
  /// 12pt - Small spacing
  static const double sm = 12.0;
  
  /// 16pt - Medium spacing (default)
  static const double md = 16.0;
  
  /// 20pt - Medium-large spacing
  static const double lg = 20.0;
  
  /// 24pt - Large spacing
  static const double xl = 24.0;
  
  /// 32pt - Extra large spacing
  static const double xxl = 32.0;
  
  /// 48pt - Maximum spacing
  static const double xxxl = 48.0;
}

/// Corner radius values following Apple HIG
class Radii {
  // Private constructor to prevent instantiation
  Radii._();
  
  /// 6pt - Small radius (buttons, chips)
  static const Radius small = Radius.circular(6);
  
  /// 10pt - Medium radius (cards, dialogs)
  static const Radius medium = Radius.circular(10);
  
  /// 13pt - Large radius (cards, sheets)
  static const Radius large = Radius.circular(13);
  
  /// 20pt - Extra large radius (modals)
  static const Radius extraLarge = Radius.circular(20);
  
  /// Full radius for circular elements
  static const Radius full = Radius.circular(999);
  
  // BorderRadius helpers
  static const BorderRadius smallBorderRadius = BorderRadius.all(small);
  static const BorderRadius mediumBorderRadius = BorderRadius.all(medium);
  static const BorderRadius largeBorderRadius = BorderRadius.all(large);
  static const BorderRadius extraLargeBorderRadius = BorderRadius.all(extraLarge);
  static const BorderRadius fullBorderRadius = BorderRadius.all(full);
}

/// Shadow/Elevation values following Apple HIG
/// Apple uses subtle shadows compared to Material Design
class Elevation {
  // Private constructor to prevent instantiation
  Elevation._();
  
  /// No elevation
  static const double level0 = 0.0;
  
  /// Subtle elevation (1pt)
  static const double level1 = 1.0;
  
  /// Light elevation (2pt)
  static const double level2 = 2.0;
  
  /// Medium elevation (4pt)
  static const double level3 = 4.0;
  
  /// High elevation (8pt)
  static const double level4 = 8.0;
  
  /// Shadow definitions
  static List<BoxShadow> shadowLevel0 = [];
  
  static List<BoxShadow> shadowLevel1 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      offset: const Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> shadowLevel2 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      offset: const Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> shadowLevel3 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      offset: const Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> shadowLevel4 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.10),
      offset: const Offset(0, 8),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];
}

/// Animation durations following Apple HIG
class Durations {
  // Private constructor to prevent instantiation
  Durations._();
  
  /// 150ms - Fast animations
  static const Duration fast = Duration(milliseconds: 150);
  
  /// 250ms - Normal animations
  static const Duration normal = Duration(milliseconds: 250);
  
  /// 350ms - Slow animations
  static const Duration slow = Duration(milliseconds: 350);
  
  /// 500ms - Very slow animations
  static const Duration verySlow = Duration(milliseconds: 500);
}

/// Minimum interactive sizes following Apple HIG
class MinSize {
  // Private constructor to prevent instantiation
  MinSize._();
  
  /// 44pt - Minimum tap target size
  static const double tapTarget = 44.0;
  
  /// 28pt - Minimum button height for compact areas
  static const double compactButton = 28.0;
  
  /// 34pt - Standard button height
  static const double button = 34.0;
  
  /// 44pt - Large button height
  static const double largeButton = 44.0;
}

/// Icon sizes following Apple HIG
class IconSize {
  // Private constructor to prevent instantiation
  IconSize._();
  
  /// 16pt - Small icons
  static const double small = 16.0;
  
  /// 20pt - Medium icons
  static const double medium = 20.0;
  
  /// 24pt - Large icons
  static const double large = 24.0;
  
  /// 28pt - Extra large icons
  static const double extraLarge = 28.0;
}

// Legacy aliases for backward compatibility
@Deprecated('Use Radii.smallBorderRadius instead')
const sm = Radii.small;

@Deprecated('Use Radii.mediumBorderRadius instead')
const md = Radii.medium;

@Deprecated('Use Radii.largeBorderRadius instead')
const lg = Radii.large;

@Deprecated('Use Radii.fullBorderRadius instead')
const full = Radii.full;
