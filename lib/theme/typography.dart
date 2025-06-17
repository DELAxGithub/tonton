import 'package:flutter/material.dart';
import 'dart:io' show Platform;

/// Apple HIG-compliant typography system for Tonton
///
/// This class provides text styles following Apple's Human Interface Guidelines
/// with proper font families for iOS/macOS and fallbacks for other platforms.
class TontonTypography {
  // Private constructor to prevent instantiation
  TontonTypography._();

  /// Get platform-appropriate font family
  static String get _fontFamily {
    if (Platform.isIOS || Platform.isMacOS) {
      return '.SF Pro Display';
    }
    return 'Roboto'; // Android/Web fallback
  }

  /// Get platform-appropriate Japanese font family
  static String get _japaneseFontFamily {
    if (Platform.isIOS || Platform.isMacOS) {
      return 'Hiragino Sans';
    }
    return 'Noto Sans JP';
  }

  /// Font families list with Japanese support
  static List<String> get _fontFamilyFallback => [
    _fontFamily,
    _japaneseFontFamily,
    'NotoSansJP', // Asset font fallback
  ];

  // ===== Apple HIG Text Styles =====

  /// Large Title - Used for prominent titles
  /// Size: 34pt, Weight: Regular (400)
  static TextStyle largeTitle = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 34,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.41,
    height: 1.21,
  );

  /// Title 1 - Used for major section titles
  /// Size: 28pt, Weight: Regular (400)
  static TextStyle title1 = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 28,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.36,
    height: 1.21,
  );

  /// Title 2 - Used for subsection titles
  /// Size: 22pt, Weight: Regular (400)
  static TextStyle title2 = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 22,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.35,
    height: 1.27,
  );

  /// Title 3 - Used for smaller titles
  /// Size: 20pt, Weight: Regular (400)
  static TextStyle title3 = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.38,
    height: 1.25,
  );

  /// Headline - Used for emphasis
  /// Size: 17pt, Weight: Semibold (600)
  static TextStyle headline = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
    height: 1.29,
  );

  /// Body - Used for body text
  /// Size: 17pt, Weight: Regular (400)
  static TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.41,
    height: 1.29,
  );

  /// Callout - Used for callout text
  /// Size: 16pt, Weight: Regular (400)
  static TextStyle callout = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.32,
    height: 1.31,
  );

  /// Subheadline - Used for subheadings
  /// Size: 15pt, Weight: Regular (400)
  static TextStyle subheadline = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.24,
    height: 1.33,
  );

  /// Footnote - Used for footnotes
  /// Size: 13pt, Weight: Regular (400)
  static TextStyle footnote = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.08,
    height: 1.38,
  );

  /// Caption 1 - Used for standard captions
  /// Size: 12pt, Weight: Regular (400)
  static TextStyle caption1 = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.33,
  );

  /// Caption 2 - Used for smaller captions
  /// Size: 11pt, Weight: Regular (400)
  static TextStyle caption2 = TextStyle(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.06,
    height: 1.18,
  );

  // ===== Weight Variations =====

  /// Returns a TextStyle with specified weight
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Common weight variations
  static TextStyle thin(TextStyle style) => withWeight(style, FontWeight.w100);
  static TextStyle light(TextStyle style) => withWeight(style, FontWeight.w300);
  static TextStyle regular(TextStyle style) =>
      withWeight(style, FontWeight.w400);
  static TextStyle medium(TextStyle style) =>
      withWeight(style, FontWeight.w500);
  static TextStyle semibold(TextStyle style) =>
      withWeight(style, FontWeight.w600);
  static TextStyle bold(TextStyle style) => withWeight(style, FontWeight.w700);
  static TextStyle heavy(TextStyle style) => withWeight(style, FontWeight.w900);

  // ===== TextTheme Factory =====

  /// Creates a complete TextTheme following Apple HIG
  static TextTheme textTheme() {
    return TextTheme(
      // Display styles (largest text)
      displayLarge: largeTitle,
      displayMedium: title1,
      displaySmall: title2,

      // Headline styles
      headlineLarge: title1,
      headlineMedium: title2,
      headlineSmall: title3,

      // Title styles
      titleLarge: title2,
      titleMedium: title3,
      titleSmall: headline,

      // Body styles
      bodyLarge: body,
      bodyMedium: callout,
      bodySmall: footnote,

      // Label styles
      labelLarge: headline,
      labelMedium: subheadline,
      labelSmall: caption1,
    );
  }

  // ===== Semantic Text Styles =====

  /// Navigation bar title
  static TextStyle get navigationTitle => headline;

  /// Tab bar label
  static TextStyle get tabLabel => caption1;

  /// Button text
  static TextStyle get button => body.copyWith(fontWeight: FontWeight.w600);

  /// Text field input
  static TextStyle get textField => body;

  /// Text field placeholder
  static TextStyle get placeholder =>
      body.copyWith(fontWeight: FontWeight.w400);

  /// List item title
  static TextStyle get listTitle => body;

  /// List item subtitle
  static TextStyle get listSubtitle => subheadline;

  /// Section header
  static TextStyle get sectionHeader =>
      footnote.copyWith(fontWeight: FontWeight.w600);

  /// Card title
  static TextStyle get cardTitle => headline;

  /// Card subtitle
  static TextStyle get cardSubtitle => subheadline;

  /// Metric value (large numbers)
  static TextStyle get metricValue =>
      title1.copyWith(fontWeight: FontWeight.w600);

  /// Metric label
  static TextStyle get metricLabel => caption1;
}

/// Extension to easily apply text styles to Text widgets
extension TextStyleExtension on Text {
  Text withStyle(TextStyle style) {
    return Text(
      data!,
      key: key,
      style: style.merge(this.style),
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }
}
