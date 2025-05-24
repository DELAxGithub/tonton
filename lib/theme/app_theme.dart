import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// TonTon app's color palette
class TontonColors {
  // Primary brand colors
  static const Color primary = Color(0xFF38A3A5);  // Teal
  static const Color secondary = Color(0xFF57CC99); // Green
  static const Color tertiary = Color(0xFF80ED99); // Light Green

  // Accent colors
  static const Color accent1 = Color(0xFFC7F9CC); // Pale Green
  static const Color accent2 = Color(0xFF22577A); // Deep Blue

  // Neutral colors
  static const Color neutral100 = Color(0xFFF8F9FA); // Almost White
  static const Color neutral200 = Color(0xFFE9ECEF);
  static const Color neutral300 = Color(0xFFDEE2E6);
  static const Color neutral400 = Color(0xFFCED4DA);
  static const Color neutral500 = Color(0xFFADB5BD);
  static const Color neutral600 = Color(0xFF6C757D);
  static const Color neutral700 = Color(0xFF495057);
  static const Color neutral800 = Color(0xFF343A40);
  static const Color neutral900 = Color(0xFF212529); // Almost Black

  // Feedback colors
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFDC3545);
  static const Color info = Color(0xFF17A2B8);
}

/// The TonTon app's typography
class TontonTypography {
  // Font family names
  static const String primaryFontFamily = 'Noto Sans JP';
  static const String secondaryFontFamily = 'Roboto';

  // Main text styles
  static const TextStyle displayLarge = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
}

/// Visual density for UI components
class TontonSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// Border radius sizes
class TontonRadius {
  static const double none = 0.0;
  static const double xs = 2.0;
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double xxl = 24.0;
  static const double full = 9999.0;
}

/// Shadow definitions
class TontonShadows {
  static List<BoxShadow> get small => [
    BoxShadow(
        color: Colors.black.withAlpha((0.1 * 255).round()),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get medium => [
    BoxShadow(
        color: Colors.black.withAlpha((0.1 * 255).round()),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get large => [
    BoxShadow(
        color: Colors.black.withAlpha((0.1 * 255).round()),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
}

/// TonTon app theme
class TontonTheme {
  /// Light theme for the app
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: TontonColors.primary,
      brightness: Brightness.light,
      primary: TontonColors.primary,
      onPrimary: Colors.white,
      secondary: TontonColors.secondary,
      onSecondary: Colors.white,
      tertiary: TontonColors.tertiary,
      onTertiary: TontonColors.neutral800,
      error: TontonColors.error,
      onError: Colors.white,
    ),
    fontFamily: TontonTypography.primaryFontFamily,
    textTheme: TextTheme(
      displayLarge: TontonTypography.displayLarge,
      displayMedium: TontonTypography.displayMedium,
      displaySmall: TontonTypography.displaySmall,
      headlineLarge: TontonTypography.headlineLarge,
      headlineMedium: TontonTypography.headlineMedium,
      headlineSmall: TontonTypography.headlineSmall,
      titleLarge: TontonTypography.titleLarge,
      titleMedium: TontonTypography.titleMedium,
      titleSmall: TontonTypography.titleSmall,
      bodyLarge: TontonTypography.bodyLarge,
      bodyMedium: TontonTypography.bodyMedium,
      bodySmall: TontonTypography.bodySmall,
      labelLarge: TontonTypography.labelLarge,
      labelMedium: TontonTypography.labelMedium,
      labelSmall: TontonTypography.labelSmall,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: TontonColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      centerTitle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(TontonRadius.md),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TontonRadius.md),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: TontonColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TontonRadius.md),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: TontonSpacing.md,
          vertical: TontonSpacing.sm,
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: TontonColors.secondary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TontonRadius.full),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: TontonColors.primary,
      unselectedLabelColor: TontonColors.neutral600,
      indicatorColor: TontonColors.primary,
      dividerColor: Colors.transparent,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: TontonColors.primary,
      unselectedItemColor: TontonColors.neutral600,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: TontonColors.neutral100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TontonRadius.md),
        borderSide: BorderSide(color: TontonColors.neutral400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TontonRadius.md),
        borderSide: BorderSide(color: TontonColors.neutral400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TontonRadius.md),
        borderSide: BorderSide(color: TontonColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: TontonSpacing.md,
        vertical: TontonSpacing.sm,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: TontonColors.neutral300,
      thickness: 1,
      space: TontonSpacing.md,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: TontonColors.neutral800,
      contentTextStyle: TontonTypography.bodyMedium.copyWith(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TontonRadius.md),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: TontonColors.neutral200,
        selectedColor: TontonColors.primary.withAlpha((0.2 * 255).round()),
      labelStyle: TontonTypography.bodySmall,
      padding: const EdgeInsets.symmetric(
        horizontal: TontonSpacing.sm,
        vertical: TontonSpacing.xs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TontonRadius.full),
      ),
    ),
  );

  /// Dark theme for the app
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: TontonColors.primary,
      brightness: Brightness.dark,
      primary: TontonColors.primary,
      onPrimary: Colors.white,
      secondary: TontonColors.secondary,
      onSecondary: Colors.white,
      tertiary: TontonColors.tertiary,
      onTertiary: TontonColors.neutral800,
      error: TontonColors.error,
      onError: Colors.white,
    ),
    fontFamily: TontonTypography.primaryFontFamily,
    textTheme: TextTheme(
      displayLarge: TontonTypography.displayLarge,
      displayMedium: TontonTypography.displayMedium,
      displaySmall: TontonTypography.displaySmall,
      headlineLarge: TontonTypography.headlineLarge,
      headlineMedium: TontonTypography.headlineMedium,
      headlineSmall: TontonTypography.headlineSmall,
      titleLarge: TontonTypography.titleLarge,
      titleMedium: TontonTypography.titleMedium,
      titleSmall: TontonTypography.titleSmall,
      bodyLarge: TontonTypography.bodyLarge,
      bodyMedium: TontonTypography.bodyMedium,
      bodySmall: TontonTypography.bodySmall,
      labelLarge: TontonTypography.labelLarge,
      labelMedium: TontonTypography.labelMedium,
      labelSmall: TontonTypography.labelSmall,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: TontonColors.neutral900,
      foregroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      centerTitle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(TontonRadius.md),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TontonRadius.md),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: TontonColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TontonRadius.md),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: TontonSpacing.md,
          vertical: TontonSpacing.sm,
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: TontonColors.secondary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TontonRadius.full),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: TontonColors.primary,
      unselectedLabelColor: TontonColors.neutral400,
      indicatorColor: TontonColors.primary,
      dividerColor: Colors.transparent,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: TontonColors.neutral900,
      selectedItemColor: TontonColors.primary,
      unselectedItemColor: TontonColors.neutral400,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: TontonColors.neutral800,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TontonRadius.md),
        borderSide: BorderSide(color: TontonColors.neutral600),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TontonRadius.md),
        borderSide: BorderSide(color: TontonColors.neutral600),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TontonRadius.md),
        borderSide: BorderSide(color: TontonColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: TontonSpacing.md,
        vertical: TontonSpacing.sm,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: TontonColors.neutral700,
      thickness: 1,
      space: TontonSpacing.md,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: TontonColors.neutral800,
      contentTextStyle: TontonTypography.bodyMedium.copyWith(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TontonRadius.md),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: TontonColors.neutral700,
        selectedColor: TontonColors.primary.withAlpha((0.3 * 255).round()),
      labelStyle: TontonTypography.bodySmall,
      padding: const EdgeInsets.symmetric(
        horizontal: TontonSpacing.sm,
        vertical: TontonSpacing.xs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TontonRadius.full),
      ),
    ),
  );
}