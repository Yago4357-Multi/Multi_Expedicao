import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kThemeModeKey = '__theme_mode__';
SharedPreferences? _prefs;

abstract class FlutterFlowTheme {
  static Future initialize() async =>
      _prefs = await SharedPreferences.getInstance();

  static ThemeMode get themeMode {
    final darkMode = _prefs?.getBool(kThemeModeKey);
    return darkMode == null
        ? ThemeMode.system
        : darkMode
            ? ThemeMode.dark
            : ThemeMode.light;
  }

  static void saveThemeMode(ThemeMode mode) => mode == ThemeMode.system
      ? _prefs?.remove(kThemeModeKey)
      : _prefs?.setBool(kThemeModeKey, mode == ThemeMode.dark);

  static FlutterFlowTheme of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? DarkModeTheme()
          : LightModeTheme();

  late Color alternate;
  late Color primaryBackground;
  late Color secondaryBackground;
  late Color primaryText;
  late Color secondaryText;
  late Color accent1;
  late Color error;
  late Color success;
  late Color warning;
  late Color info;
  late Color primary;
  late Color accent2;
  late Color accent3;
  late Color accent4;
  late Color secondary;
  late Color tertiary;

  TextStyle get displaySmall => GoogleFonts.getFont(
        'Readex Pro',
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 32,
      );

  TextStyle get titleLarge => GoogleFonts.getFont(
        'Readex Pro',
        color: primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 22,
      );

  TextStyle get titleSmall => GoogleFonts.getFont(
        'Inter',
        color: info,
        fontWeight: FontWeight.w500,
        fontSize: 16,
      );

  TextStyle get headlineLarge => GoogleFonts.getFont(
        'Readex Pro',
        color: primaryText,
        fontWeight: FontWeight.w400,
        fontSize: 22,
      );

  TextStyle get headlineMedium => GoogleFonts.getFont(
        'Readex Pro',
        color: primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 22,
      );

  TextStyle get headlineSmall => GoogleFonts.getFont(
        'Readex Pro',
        color: primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 20,
      );

  TextStyle get labelLarge => GoogleFonts.getFont(
        'Inter',
        color: secondaryText,
        fontWeight: FontWeight.w500,
        fontSize: 16,
      );

  TextStyle get labelSmall => GoogleFonts.getFont(
        'Inter',
        color: secondaryText,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      );

  TextStyle get bodyLarge => GoogleFonts.getFont(
        'Inter',
        color: primaryText,
        fontWeight: FontWeight.w400,
        fontSize: 16,
      );

  TextStyle get bodyMedium => GoogleFonts.getFont(
        'Inter',
        color: primaryText,
        fontWeight: FontWeight.w400,
        fontSize: 14,
      );

  TextStyle get bodySmall => GoogleFonts.getFont(
        'Inter',
        color: primaryText,
        fontWeight: FontWeight.w400,
        fontSize: 12,
      );

  TextStyle get labelMedium => GoogleFonts.getFont(
        'Inter',
        color: secondaryText,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      );
}

class LightModeTheme extends FlutterFlowTheme {
  late Color primary = const Color(0xFF007000); // Primary
  late Color secondary = const Color(0xFF39D2C0); // Secondary
  late Color tertiary = const Color(0xFFEE8B60); // Tertiary
  late Color alternate = const Color(0xFFE0E3E7); // Alternate
  late Color primaryBackground = const Color(0xFFF1F4F8); // Primary Background
  late Color secondaryBackground =
      const Color(0xFFFFFFFF); // Secondary Background
  late Color primaryText = const Color(0xFF14181B); // Primary Text
  late Color secondaryText = const Color(0xFF57636C); // Secondary Text

  // Semantic Colors
  late Color success = const Color(0xFF249689); // Success
  late Color error = const Color(0xFFFF5963); // Error
  late Color warning = const Color(0xFFF9CF58); // Warning
  late Color info = const Color(0xFFFFFFFF); // Info

  // Accent Colors
  late Color accent1 = const Color(0xFF4C4B39); // Accent 1
  late Color accent2 = const Color(0x4D39D2C0); // Accent 2
  late Color accent3 = const Color(0x4DEE8B60); // Accent 3
  late Color accent4 = const Color(0xCCFFFFFF); // Accent 4
}

class DarkModeTheme extends FlutterFlowTheme {
  late Color primary = const Color(0xFF4B39EF); // Primary
  late Color secondary = const Color(0xFF39D2C0); // Secondary
  late Color tertiary = const Color(0xFFEE8B60); // Tertiary
  late Color alternate = const Color(0xFF262D34); // Alternate
  late Color primaryBackground = const Color(0xFF1D2428); // Primary Background
  late Color secondaryBackground =
      const Color(0xFF14181B); // Secondary Background
  late Color primaryText = const Color(0xFFFFFFFF); // Primary Text
  late Color secondaryText = const Color(0xFF95A1AC); // Secondary Text

  // Semantic Colors
  late Color success = const Color(0xFF249689); // Success
  late Color error = const Color(0xFFFF5963); // Error
  late Color warning = const Color(0xFFF9CF58); // Warning
  late Color info = const Color(0xFFFFFFFF); // Info

  // Accent Colors
  late Color accent1 = const Color(0xFF4C4B39); // Accent 1
  late Color accent2 = const Color(0x4D39D2C0); // Accent 2
  late Color accent3 = const Color(0x4DEE8B60); // Accent 3
  late Color accent4 = const Color(0xB2262d34); // Accent 4
}

extension TextStyleHelper on TextStyle {
  TextStyle override({
    String? fontFamily,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    bool useGoogleFonts = true,
    TextDecoration? decoration,
    double? lineHeight,
    double? letterSpacing,
  }) =>
      useGoogleFonts
          ? GoogleFonts.getFont(
              fontFamily!,
              color: color ?? this.color,
              fontSize: fontSize ?? this.fontSize,
              fontWeight: fontWeight ?? this.fontWeight,
              fontStyle: fontStyle ?? this.fontStyle,
              decoration: decoration,
              height: lineHeight,
              letterSpacing: letterSpacing,
            )
          : copyWith(
              fontFamily: fontFamily,
              color: color,
              fontSize: fontSize,
              fontWeight: fontWeight,
              fontStyle: fontStyle,
              decoration: decoration,
              height: lineHeight,
            );
}
