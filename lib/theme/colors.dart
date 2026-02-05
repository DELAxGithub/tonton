import 'package:flutter/material.dart';

/// Apple HIG-compliant color system for Tonton
///
/// This class provides system colors, semantic colors, and brand colors
/// following Apple's Human Interface Guidelines.
class TontonColors {
  // Private constructor to prevent instantiation
  TontonColors._();

  // ===== Brand Colors =====
  /// Tonton's signature pig pink color - Refined for Premium Look
  static const Color pigPink = Color(0xFFFF9AA2); // More vibrant/warm pink

  /// Darker variant of pig pink for emphasis
  static const Color pigPinkDark = Color(0xFFE0576A);

  /// Light variant of pig pink for subtle backgrounds
  static const Color pigPinkLight = Color(0xFFFFD4D8);

  /// Premium Gradient for primary actions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF9AA2), Color(0xFFFFB7B2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ===== Design Token Colors =====
  /// Warm primary background
  static const Color bgPrimary = Color(0xFFFFF8F6);

  /// Muted warm background
  static const Color bgMuted = Color(0xFFFFF0EE);

  /// Subtle shadow color (8% opacity warm black)
  static const Color shadowSubtle = Color(0x081A1918);

  /// Subtle border color
  static const Color borderSubtle = Color(0xFFF0E8E6);

  /// Strong border color
  static const Color borderStrong = Color(0xFFD1D0CD);

  // ===== System Colors (Light Mode) =====
  static const Color systemRed = Color(0xFFFF3B30);
  static const Color systemOrange = Color(0xFFFF9500);
  static const Color systemYellow = Color(0xFFFFCC00);
  static const Color systemGreen = Color(0xFF34C759);
  static const Color systemMint = Color(0xFF00C7BE);
  static const Color systemTeal = Color(0xFF30B0C7);
  static const Color systemCyan = Color(0xFF32ADE6);
  static const Color systemBlue = Color(0xFF007AFF);
  static const Color systemIndigo = Color(0xFF5856D6);
  static const Color systemPurple = Color(0xFFAF52DE);
  static const Color systemPink = Color(0xFFFF2D55);
  static const Color systemBrown = Color(0xFFA2845E);

  // ===== System Grays =====
  static const Color systemGray = Color(0xFF8E8E93);
  static const Color systemGray2 = Color(0xFFAEAEB2);
  static const Color systemGray3 = Color(0xFFC7C7CC);
  static const Color systemGray4 = Color(0xFFD1D1D6);
  static const Color systemGray5 = Color(0xFFE5E5EA);
  static const Color systemGray6 = Color(0xFFF2F2F7);

  // ===== Semantic Colors (Light Mode) =====
  static const Color label = Color(0xFF000000);
  static const Color secondaryLabel = Color(0x993C3C43);
  static const Color tertiaryLabel = Color(0x4D3C3C43);
  static const Color quaternaryLabel = Color(0x2E3C3C43);

  static const Color fill = Color(0x1F787880);
  static const Color secondaryFill = Color(0x29787880);
  static const Color tertiaryFill = Color(0x0F767680);
  static const Color quaternaryFill = Color(0x0A747480);

  static const Color separator = Color(0x493C3C43);
  static const Color opaqueSeparator = Color(0xFFC6C6C8);

  // ===== Background Colors (Light Mode) =====
  static const Color systemBackground = Color(0xFFFFFFFF);
  static const Color secondarySystemBackground = Color(0xFFF2F2F7);
  static const Color tertiarySystemBackground = Color(0xFFFFFFFF);

  static const Color systemGroupedBackground = Color(0xFFF2F2F7);
  static const Color secondarySystemGroupedBackground = Color(0xFFFFFFFF);
  static const Color tertiarySystemGroupedBackground = Color(0xFFF2F2F7);

  // ===== Dark Mode Colors =====
  static const Color labelDark = Color(0xFFFFFFFF);
  static const Color secondaryLabelDark = Color(0x99EBEBF5);
  static const Color tertiaryLabelDark = Color(0x4DEBEBF5);
  static const Color quaternaryLabelDark = Color(0x2EEBEBF5);

  static const Color fillDark = Color(0x5C787880);
  static const Color secondaryFillDark = Color(0x52787880);
  static const Color tertiaryFillDark = Color(0x3D767680);
  static const Color quaternaryFillDark = Color(0x2E747480);

  static const Color separatorDark = Color(0x99545458);
  static const Color opaqueSeparatorDark = Color(0xFF38383A);

  static const Color systemBackgroundDark = Color(0xFF000000);
  static const Color secondarySystemBackgroundDark = Color(0xFF1C1C1E);
  static const Color tertiarySystemBackgroundDark = Color(0xFF2C2C2E);

  static const Color systemGroupedBackgroundDark = Color(0xFF000000);
  static const Color secondarySystemGroupedBackgroundDark = Color(0xFF1C1C1E);
  static const Color tertiarySystemGroupedBackgroundDark = Color(0xFF2C2C2E);

  // ===== Nutrition Colors =====
  static const Color proteinColor = systemRed;
  static const Color fatColor = systemYellow;
  static const Color carbsColor = systemBlue;

  // ===== Status Colors =====
  static const Color success = systemGreen;
  static const Color warning = systemOrange;
  static const Color error = systemRed;
  static const Color info = systemBlue;

  // ===== ColorScheme Factory Methods =====
  static ColorScheme lightColorScheme() {
    return const ColorScheme.light(
      primary: pigPink,
      onPrimary: Colors.white,
      primaryContainer: pigPink,
      onPrimaryContainer: Colors.white,

      secondary: systemBlue,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFE5F3FF),
      onSecondaryContainer: systemBlue,

      tertiary: systemGreen,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFE5F5E9),
      onTertiaryContainer: systemGreen,

      error: systemRed,
      onError: Colors.white,
      errorContainer: Color(0xFFFFEBEB),
      onErrorContainer: systemRed,

      surface: systemBackground,
      onSurface: label,
      surfaceContainerHighest: secondarySystemBackground,
      onSurfaceVariant: secondaryLabel,

      outline: separator,
      outlineVariant: systemGray5,

      scrim: Colors.black12,
      inverseSurface: label,
      onInverseSurface: systemBackground,
      inversePrimary: pigPinkDark,

      shadow: Colors.black26,
    );
  }

  static ColorScheme darkColorScheme() {
    return const ColorScheme.dark(
      primary: pigPink,
      onPrimary: Colors.black,
      primaryContainer: pigPinkDark,
      onPrimaryContainer: Colors.white,

      secondary: systemCyan,
      onSecondary: Colors.black,
      secondaryContainer: Color(0xFF004A77),
      onSecondaryContainer: systemCyan,

      tertiary: systemGreen,
      onTertiary: Colors.black,
      tertiaryContainer: Color(0xFF003A2E),
      onTertiaryContainer: systemGreen,

      error: systemPink,
      onError: Colors.black,
      errorContainer: Color(0xFF93000A),
      onErrorContainer: systemPink,

      surface: systemBackgroundDark,
      onSurface: labelDark,
      surfaceContainerHighest: secondarySystemBackgroundDark,
      onSurfaceVariant: secondaryLabelDark,

      outline: separatorDark,
      outlineVariant: Color(0xFF43474E),

      scrim: Colors.black87,
      inverseSurface: labelDark,
      onInverseSurface: systemBackgroundDark,
      inversePrimary: pigPink,

      shadow: Colors.black87,
    );
  }

  // ===== Helper Methods =====
  /// Returns appropriate label color based on brightness
  static Color labelColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? labelDark : label;
  }

  /// Returns appropriate secondary label color based on brightness
  static Color secondaryLabelColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? secondaryLabelDark
        : secondaryLabel;
  }

  /// Returns appropriate tertiary label color based on brightness
  static Color tertiaryLabelColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? tertiaryLabelDark
        : tertiaryLabel;
  }

  /// Returns appropriate quaternary label color based on brightness
  static Color quaternaryLabelColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? quaternaryLabelDark
        : quaternaryLabel;
  }

  /// Returns appropriate background color based on brightness
  static Color backgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? systemBackgroundDark
        : systemBackground;
  }

  /// Returns appropriate secondary background color based on brightness
  static Color secondaryBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? secondarySystemBackgroundDark
        : secondarySystemBackground;
  }

  /// Returns appropriate grouped background color based on brightness
  static Color groupedBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? systemGroupedBackgroundDark
        : systemGroupedBackground;
  }

  /// Returns appropriate separator color based on brightness
  static Color separatorColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? separatorDark
        : separator;
  }

  /// Returns appropriate fill color based on brightness
  static Color fillColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? fillDark : fill;
  }
}

// Legacy compatibility aliases
@Deprecated('Use TontonColors.label instead')
const Color textPrimary = TontonColors.label;

@Deprecated('Use TontonColors.secondaryLabel instead')
const Color textSecondary = TontonColors.secondaryLabel;

@Deprecated('Use TontonColors.systemGray instead')
const Color neutral500 = TontonColors.systemGray;
