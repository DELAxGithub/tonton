import 'package:flutter/material.dart';

/// 固定トークン（HEX マスター）
class TontonColors {
  static const pigPink     = Color(0xFFF7B6B9); // Primary / Seed
  static const mintGreen   = Color(0xFFAEE6C4); // Secondary A
  static const skyBlue     = Color(0xFFB7E8F0); // Secondary B
  static const creamYellow = Color(0xFFFFF0C9); // Accent
  static const offWhite    = Color(0xFFFFF8F4); // Background
  static const softGreen   = Color(0xFF65C18C); // Success
  static const softRed     = Color(0xFFF47D7C); // Error
  static const softOrange  = Color(0xFFF7C06B); // Warning
  static const darkBrown   = Color(0xFF4A3A36); // Text Primary
  static const warmGray    = Color(0xFF7C6F68); // Text Secondary
  static const lightGray   = Color(0xFFC9BFB8); // Border / Disabled
  static const surface     = Color(0xFFFFFFFF); // Default surface
}

/// Material 3 ColorScheme
final tontonLightScheme = ColorScheme.fromSeed(
  seedColor: TontonColors.pigPink,
  brightness: Brightness.light,
  surface:    TontonColors.offWhite,
  error:      TontonColors.softRed,
);

/// 拡張カラー（semantic / brand 固有）
extension TontonSemanticColors on ColorScheme {
  Color get success  => TontonColors.softGreen;
  Color get warning  => TontonColors.softOrange;
  Color get accent   => TontonColors.creamYellow;
  Color get surface2 => TontonColors.surface; // optional second surface
}
