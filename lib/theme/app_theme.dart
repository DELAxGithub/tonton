import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'colors.dart' as new_colors;
import 'typography.dart' as new_typography;
import 'tokens.dart' as new_tokens;

/// TonTon app's color palette - Legacy support
/// @deprecated Use colors.dart instead
class TontonColors {
  // Map to new color system for backward compatibility
  static const Color primary = new_colors.TontonColors.pigPink;
  static const Color secondary = new_colors.TontonColors.systemGreen;
  static const Color tertiary = new_colors.TontonColors.systemMint;

  // Accent colors
  static const Color accent1 = Color(0xFFC7F9CC);
  static const Color accent2 = new_colors.TontonColors.systemIndigo;

  // Neutral colors mapped to system grays
  static const Color neutral100 = new_colors.TontonColors.systemGray6;
  static const Color neutral200 = new_colors.TontonColors.systemGray5;
  static const Color neutral300 = new_colors.TontonColors.systemGray4;
  static const Color neutral400 = new_colors.TontonColors.systemGray3;
  static const Color neutral500 = new_colors.TontonColors.systemGray2;
  static const Color neutral600 = new_colors.TontonColors.systemGray;
  static const Color neutral700 = Color(0xFF495057);
  static const Color neutral800 = Color(0xFF343A40);
  static const Color neutral900 = Color(0xFF212529);

  // Feedback colors
  static const Color success = new_colors.TontonColors.systemGreen;
  static const Color warning = new_colors.TontonColors.systemOrange;
  static const Color error = new_colors.TontonColors.systemRed;
  static const Color info = new_colors.TontonColors.systemBlue;

  // Nutrition colors
  static const Color proteinColor = new_colors.TontonColors.proteinColor;
  static const Color carbsColor = new_colors.TontonColors.carbsColor;
  static const Color fatColor = new_colors.TontonColors.fatColor;

  // Semantic colors
  static const Color textPrimary = new_colors.TontonColors.label;
  static const Color textSecondary = new_colors.TontonColors.secondaryLabel;
  static const Color surfaceGrey = new_colors.TontonColors.systemGray6;
  static const Color borderGrey = new_colors.TontonColors.systemGray4;
}

/// The TonTon app's typography - Legacy support
/// @deprecated Use typography.dart instead
class TontonTypography {
  static const String primaryFontFamily = 'Noto Sans JP';
  static const String secondaryFontFamily = 'Roboto';

  // Map to new typography system
  static TextStyle get displayLarge =>
      new_typography.TontonTypography.largeTitle;
  static TextStyle get displayMedium => new_typography.TontonTypography.title1;
  static TextStyle get displaySmall => new_typography.TontonTypography.title2;
  static TextStyle get headlineLarge => new_typography.TontonTypography.title2;
  static TextStyle get headlineMedium => new_typography.TontonTypography.title3;
  static TextStyle get headlineSmall =>
      new_typography.TontonTypography.headline;
  static TextStyle get titleLarge => new_typography.TontonTypography.headline;
  static TextStyle get titleMedium =>
      new_typography.TontonTypography.subheadline;
  static TextStyle get titleSmall => new_typography.TontonTypography.footnote;
  static TextStyle get bodyLarge => new_typography.TontonTypography.body;
  static TextStyle get bodyMedium => new_typography.TontonTypography.callout;
  static TextStyle get bodySmall => new_typography.TontonTypography.footnote;
  static TextStyle get labelLarge => new_typography.TontonTypography.footnote
      .copyWith(fontWeight: FontWeight.w600);
  static TextStyle get labelMedium => new_typography.TontonTypography.caption1;
  static TextStyle get labelSmall => new_typography.TontonTypography.caption2;
}

/// Visual density for UI components - Legacy support
/// @deprecated Use tokens.dart instead
class TontonSpacing {
  static const double xs = new_tokens.Spacing.xxs;
  static const double sm = new_tokens.Spacing.xs;
  static const double md = new_tokens.Spacing.md;
  static const double lg = new_tokens.Spacing.xl;
  static const double xl = new_tokens.Spacing.xxl;
  static const double xxl = new_tokens.Spacing.xxxl;
}

/// Border radius sizes - Legacy support
/// @deprecated Use tokens.dart instead
class TontonRadius {
  static const double none = 0.0;
  static const double xs = 2.0;
  static const double sm = 4.0;
  static const double md = 10.0;
  static const double lg = 13.0;
  static const double xl = 16.0;
  static const double xxl = 20.0;
  static const double full = 9999.0;
}

/// Shadow definitions - Legacy support
/// @deprecated Use tokens.dart instead
class TontonShadows {
  static List<BoxShadow> get small => new_tokens.Elevation.shadowLevel1;
  static List<BoxShadow> get medium => new_tokens.Elevation.shadowLevel2;
  static List<BoxShadow> get large => new_tokens.Elevation.shadowLevel3;
}

/// TonTon app theme using new Apple HIG design system
class TontonTheme {
  /// Light theme for the app
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: new_colors.TontonColors.lightColorScheme(),
    textTheme: new_typography.TontonTypography.textTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: new_colors.TontonColors.systemBackground,
      foregroundColor: new_colors.TontonColors.label,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      centerTitle: true,
      titleTextStyle: new_typography.TontonTypography.navigationTitle.copyWith(
        color: new_colors.TontonColors.label,
      ),
      iconTheme: const IconThemeData(color: new_colors.TontonColors.label),
    ),
    scaffoldBackgroundColor: new_colors.TontonColors.systemGroupedBackground,
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: new_tokens.Radii.largeBorderRadius,
      ),
      color: new_colors.TontonColors.secondarySystemGroupedBackground,
      clipBehavior: Clip.antiAlias,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: new_colors.TontonColors.pigPink,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: new_tokens.Radii.mediumBorderRadius,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: new_tokens.Spacing.md,
          vertical: new_tokens.Spacing.sm,
        ),
        minimumSize: Size(0, new_tokens.MinSize.button),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: new_colors.TontonColors.pigPink,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: new_tokens.Radii.mediumBorderRadius,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: new_tokens.Spacing.md,
          vertical: new_tokens.Spacing.sm,
        ),
        minimumSize: Size(0, new_tokens.MinSize.button),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: new_colors.TontonColors.pigPink,
        padding: EdgeInsets.symmetric(
          horizontal: new_tokens.Spacing.md,
          vertical: new_tokens.Spacing.sm,
        ),
        minimumSize: Size(0, new_tokens.MinSize.button),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: new_colors.TontonColors.pigPink,
      foregroundColor: Colors.white,
      elevation: new_tokens.Elevation.level3,
      shape: RoundedRectangleBorder(
        borderRadius: new_tokens.Radii.fullBorderRadius,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: new_colors.TontonColors.secondarySystemBackground,
      selectedItemColor: new_colors.TontonColors.pigPink,
      unselectedItemColor: new_colors.TontonColors.systemGray,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: new_colors.TontonColors.secondarySystemBackground,
      indicatorColor: new_colors.TontonColors.pigPink.withValues(alpha: 0.2),
      labelTextStyle: WidgetStateProperty.all(
        new_typography.TontonTypography.tabLabel,
      ),
      iconTheme: WidgetStateProperty.all(
        const IconThemeData(size: new_tokens.IconSize.medium),
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: new_colors.TontonColors.pigPink,
      unselectedLabelColor: new_colors.TontonColors.systemGray,
      indicatorColor: new_colors.TontonColors.pigPink,
      dividerColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: new_colors.TontonColors.tertiarySystemBackground,
      border: OutlineInputBorder(
        borderRadius: new_tokens.Radii.mediumBorderRadius,
        borderSide: const BorderSide(color: new_colors.TontonColors.separator),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: new_tokens.Radii.mediumBorderRadius,
        borderSide: const BorderSide(color: new_colors.TontonColors.separator),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: new_tokens.Radii.mediumBorderRadius,
        borderSide: const BorderSide(
          color: new_colors.TontonColors.pigPink,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: new_tokens.Radii.mediumBorderRadius,
        borderSide: const BorderSide(color: new_colors.TontonColors.systemRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: new_tokens.Radii.mediumBorderRadius,
        borderSide: const BorderSide(
          color: new_colors.TontonColors.systemRed,
          width: 2,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: new_tokens.Spacing.md,
        vertical: new_tokens.Spacing.sm,
      ),
      hintStyle: new_typography.TontonTypography.body.copyWith(
        color: new_colors.TontonColors.tertiaryLabel,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: new_colors.TontonColors.separator,
      thickness: 0.5,
      space: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: new_colors.TontonColors.systemGray,
      contentTextStyle: new_typography.TontonTypography.footnote.copyWith(
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: new_tokens.Radii.mediumBorderRadius,
      ),
      behavior: SnackBarBehavior.floating,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: new_colors.TontonColors.systemGray5,
      selectedColor: new_colors.TontonColors.pigPink.withValues(alpha: 0.2),
      labelStyle: new_typography.TontonTypography.footnote,
      padding: EdgeInsets.symmetric(
        horizontal: new_tokens.Spacing.sm,
        vertical: new_tokens.Spacing.xxs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: new_tokens.Radii.fullBorderRadius,
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return new_colors.TontonColors.pigPink;
          }
          return new_colors.TontonColors.systemGray5;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return new_colors.TontonColors.label;
        }),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: new_tokens.Radii.mediumBorderRadius,
          ),
        ),
      ),
    ),
    cupertinoOverrideTheme: const CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: new_colors.TontonColors.pigPink,
      primaryContrastingColor: Colors.white,
      scaffoldBackgroundColor: new_colors.TontonColors.systemGroupedBackground,
    ),
  );

  /// Dark theme for the app
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: new_colors.TontonColors.darkColorScheme(),
    textTheme: new_typography.TontonTypography.textTheme().apply(
      bodyColor: new_colors.TontonColors.labelDark,
      displayColor: new_colors.TontonColors.labelDark,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: new_colors.TontonColors.systemBackgroundDark,
      foregroundColor: new_colors.TontonColors.labelDark,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      centerTitle: true,
      titleTextStyle: new_typography.TontonTypography.navigationTitle.copyWith(
        color: new_colors.TontonColors.labelDark,
      ),
      iconTheme: const IconThemeData(color: new_colors.TontonColors.labelDark),
    ),
    scaffoldBackgroundColor:
        new_colors.TontonColors.systemGroupedBackgroundDark,
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: new_tokens.Radii.largeBorderRadius,
      ),
      color: new_colors.TontonColors.secondarySystemGroupedBackgroundDark,
      clipBehavior: Clip.antiAlias,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: new_colors.TontonColors.pigPink,
        foregroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: new_tokens.Radii.mediumBorderRadius,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: new_tokens.Spacing.md,
          vertical: new_tokens.Spacing.sm,
        ),
        minimumSize: Size(0, new_tokens.MinSize.button),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: new_colors.TontonColors.pigPink,
        foregroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: new_tokens.Radii.mediumBorderRadius,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: new_tokens.Spacing.md,
          vertical: new_tokens.Spacing.sm,
        ),
        minimumSize: Size(0, new_tokens.MinSize.button),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: new_colors.TontonColors.pigPink,
        padding: EdgeInsets.symmetric(
          horizontal: new_tokens.Spacing.md,
          vertical: new_tokens.Spacing.sm,
        ),
        minimumSize: Size(0, new_tokens.MinSize.button),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: new_colors.TontonColors.pigPink,
      foregroundColor: Colors.black,
      elevation: new_tokens.Elevation.level3,
      shape: RoundedRectangleBorder(
        borderRadius: new_tokens.Radii.fullBorderRadius,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: new_colors.TontonColors.secondarySystemBackgroundDark,
      selectedItemColor: new_colors.TontonColors.pigPink,
      unselectedItemColor: new_colors.TontonColors.systemGray,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: new_colors.TontonColors.secondarySystemBackgroundDark,
      indicatorColor: new_colors.TontonColors.pigPink.withValues(alpha: 0.3),
      labelTextStyle: WidgetStateProperty.all(
        new_typography.TontonTypography.tabLabel,
      ),
      iconTheme: WidgetStateProperty.all(
        const IconThemeData(size: new_tokens.IconSize.medium),
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: new_colors.TontonColors.pigPink,
      unselectedLabelColor: new_colors.TontonColors.systemGray,
      indicatorColor: new_colors.TontonColors.pigPink,
      dividerColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: new_colors.TontonColors.tertiarySystemBackgroundDark,
      border: OutlineInputBorder(
        borderRadius: new_tokens.Radii.mediumBorderRadius,
        borderSide: const BorderSide(
          color: new_colors.TontonColors.separatorDark,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: new_tokens.Radii.mediumBorderRadius,
        borderSide: const BorderSide(
          color: new_colors.TontonColors.separatorDark,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: new_tokens.Radii.mediumBorderRadius,
        borderSide: const BorderSide(
          color: new_colors.TontonColors.pigPink,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: new_tokens.Radii.mediumBorderRadius,
        borderSide: const BorderSide(color: new_colors.TontonColors.systemPink),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: new_tokens.Radii.mediumBorderRadius,
        borderSide: const BorderSide(
          color: new_colors.TontonColors.systemPink,
          width: 2,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: new_tokens.Spacing.md,
        vertical: new_tokens.Spacing.sm,
      ),
      hintStyle: new_typography.TontonTypography.body.copyWith(
        color: new_colors.TontonColors.tertiaryLabelDark,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: new_colors.TontonColors.separatorDark,
      thickness: 0.5,
      space: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: new_colors.TontonColors.systemGray,
      contentTextStyle: new_typography.TontonTypography.footnote.copyWith(
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: new_tokens.Radii.mediumBorderRadius,
      ),
      behavior: SnackBarBehavior.floating,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: new_colors.TontonColors.systemGray.withValues(
        alpha: 0.24,
      ),
      selectedColor: new_colors.TontonColors.pigPink.withValues(alpha: 0.3),
      labelStyle: new_typography.TontonTypography.footnote,
      padding: EdgeInsets.symmetric(
        horizontal: new_tokens.Spacing.sm,
        vertical: new_tokens.Spacing.xxs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: new_tokens.Radii.fullBorderRadius,
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return new_colors.TontonColors.pigPink;
          }
          return new_colors.TontonColors.systemGray.withValues(alpha: 0.24);
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.black;
          }
          return new_colors.TontonColors.labelDark;
        }),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: new_tokens.Radii.mediumBorderRadius,
          ),
        ),
      ),
    ),
    cupertinoOverrideTheme: const CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: new_colors.TontonColors.pigPink,
      primaryContrastingColor: Colors.black,
      scaffoldBackgroundColor:
          new_colors.TontonColors.systemGroupedBackgroundDark,
    ),
  );
}
