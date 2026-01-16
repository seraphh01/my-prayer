// ignore_for_file: overridden_fields, annotate_overrides

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

  static FlutterFlowTheme of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? DarkModeTheme()
        : LightModeTheme();
  }

  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color primary;
  late Color secondary;
  late Color tertiary;
  late Color alternate;
  late Color primaryText;
  late Color secondaryText;
  late Color primaryBackground;
  late Color secondaryBackground;
  late Color accent1;
  late Color accent2;
  late Color accent3;
  late Color accent4;
  late Color success;
  late Color warning;
  late Color error;
  late Color info;

  @Deprecated('Use displaySmallFamily instead')
  String get title1Family => displaySmallFamily;
  @Deprecated('Use displaySmall instead')
  TextStyle get title1 => typography.displaySmall;
  @Deprecated('Use headlineMediumFamily instead')
  String get title2Family => typography.headlineMediumFamily;
  @Deprecated('Use headlineMedium instead')
  TextStyle get title2 => typography.headlineMedium;
  @Deprecated('Use headlineSmallFamily instead')
  String get title3Family => typography.headlineSmallFamily;
  @Deprecated('Use headlineSmall instead')
  TextStyle get title3 => typography.headlineSmall;
  @Deprecated('Use titleMediumFamily instead')
  String get subtitle1Family => typography.titleMediumFamily;
  @Deprecated('Use titleMedium instead')
  TextStyle get subtitle1 => typography.titleMedium;
  @Deprecated('Use titleSmallFamily instead')
  String get subtitle2Family => typography.titleSmallFamily;
  @Deprecated('Use titleSmall instead')
  TextStyle get subtitle2 => typography.titleSmall;
  @Deprecated('Use bodyMediumFamily instead')
  String get bodyText1Family => typography.bodyMediumFamily;
  @Deprecated('Use bodyMedium instead')
  TextStyle get bodyText1 => typography.bodyMedium;
  @Deprecated('Use bodySmallFamily instead')
  String get bodyText2Family => typography.bodySmallFamily;
  @Deprecated('Use bodySmall instead')
  TextStyle get bodyText2 => typography.bodySmall;

  String get displayLargeFamily => typography.displayLargeFamily;
  TextStyle get displayLarge => typography.displayLarge;
  String get displayMediumFamily => typography.displayMediumFamily;
  TextStyle get displayMedium => typography.displayMedium;
  String get displaySmallFamily => typography.displaySmallFamily;
  TextStyle get displaySmall => typography.displaySmall;
  String get headlineLargeFamily => typography.headlineLargeFamily;
  TextStyle get headlineLarge => typography.headlineLarge;
  String get headlineMediumFamily => typography.headlineMediumFamily;
  TextStyle get headlineMedium => typography.headlineMedium;
  String get headlineSmallFamily => typography.headlineSmallFamily;
  TextStyle get headlineSmall => typography.headlineSmall;
  String get titleLargeFamily => typography.titleLargeFamily;
  TextStyle get titleLarge => typography.titleLarge;
  String get titleMediumFamily => typography.titleMediumFamily;
  TextStyle get titleMedium => typography.titleMedium;
  String get titleSmallFamily => typography.titleSmallFamily;
  TextStyle get titleSmall => typography.titleSmall;
  String get labelLargeFamily => typography.labelLargeFamily;
  TextStyle get labelLarge => typography.labelLarge;
  String get labelMediumFamily => typography.labelMediumFamily;
  TextStyle get labelMedium => typography.labelMedium;
  String get labelSmallFamily => typography.labelSmallFamily;
  TextStyle get labelSmall => typography.labelSmall;
  String get bodyLargeFamily => typography.bodyLargeFamily;
  TextStyle get bodyLarge => typography.bodyLarge;
  String get bodyMediumFamily => typography.bodyMediumFamily;
  TextStyle get bodyMedium => typography.bodyMedium;
  String get bodySmallFamily => typography.bodySmallFamily;
  TextStyle get bodySmall => typography.bodySmall;

  Typography get typography => ThemeTypography(this);
}

class LightModeTheme extends FlutterFlowTheme {
  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color primary = const Color(0xFF790822);
  late Color secondary = const Color(0xFFE45D55);
  late Color tertiary = const Color(0xFFE88C77);
  late Color alternate = const Color(0xFFFFE5AD);
  late Color primaryText = const Color(0xFF1D1D1D);
  late Color secondaryText = const Color.fromARGB(255, 36, 36, 36);
  late Color primaryBackground = const Color(0xFFFFE5AD);
  late Color secondaryBackground = const Color(0xFFC6AA84);
  late Color accent1 = const Color(0xFFFF8A80);
  late Color accent2 = const Color(0xFFD9B295);
  late Color accent3 = const Color(0xFFFF4500);
  late Color accent4 = const Color(0xFFFFD700);
  late Color success = const Color(0xFF4CAF50);
  late Color warning = const Color(0xFFFF9800);
  late Color error = const Color(0xFFFF0000);
  late Color info = const Color(0xFF2196F3);
}

abstract class Typography {
  String get displayLargeFamily;
  TextStyle get displayLarge;
  String get displayMediumFamily;
  TextStyle get displayMedium;
  String get displaySmallFamily;
  TextStyle get displaySmall;
  String get headlineLargeFamily;
  TextStyle get headlineLarge;
  String get headlineMediumFamily;
  TextStyle get headlineMedium;
  String get headlineSmallFamily;
  TextStyle get headlineSmall;
  String get titleLargeFamily;
  TextStyle get titleLarge;
  String get titleMediumFamily;
  TextStyle get titleMedium;
  String get titleSmallFamily;
  TextStyle get titleSmall;
  String get labelLargeFamily;
  TextStyle get labelLarge;
  String get labelMediumFamily;
  TextStyle get labelMedium;
  String get labelSmallFamily;
  TextStyle get labelSmall;
  String get bodyLargeFamily;
  TextStyle get bodyLarge;
  String get bodyMediumFamily;
  TextStyle get bodyMedium;
  String get bodySmallFamily;
  TextStyle get bodySmall;
}

class ThemeTypography extends Typography {
  ThemeTypography(this.theme);

  final FlutterFlowTheme theme;

  String get displayLargeFamily => 'Merriweather';
  TextStyle get displayLarge => GoogleFonts.getFont('Merriweather',
      color: theme.primaryText,
      fontWeight: FontWeight.w600,
      fontSize: 64.0,
      locale: const Locale('rou', 'RO'));
  String get displayMediumFamily => 'Merriweather';
  TextStyle get displayMedium => GoogleFonts.getFont('Merriweather',
      color: theme.primaryText,
      fontWeight: FontWeight.w600,
      fontSize: 44.0,
      locale: const Locale('rou', 'RO'));
  String get displaySmallFamily => 'Merriweather';
  TextStyle get displaySmall => GoogleFonts.getFont('Merriweather',
      color: theme.primaryText,
      fontWeight: FontWeight.w600,
      fontSize: 36.0,
      locale: const Locale('rou', 'RO'));
  String get headlineLargeFamily => 'Merriweather';
  TextStyle get headlineLarge => GoogleFonts.getFont('Merriweather',
      color: theme.primaryText,
      fontWeight: FontWeight.w600,
      fontSize: 32.0,
      locale: const Locale('rou', 'RO'));
  String get headlineMediumFamily => 'Merriweather';
  TextStyle get headlineMedium => GoogleFonts.getFont('Merriweather',
      color: theme.primaryText,
      fontWeight: FontWeight.w600,
      fontSize: 28.0,
      locale: const Locale('rou', 'RO'));
  String get headlineSmallFamily => 'Merriweather';
  TextStyle get headlineSmall => GoogleFonts.getFont('Merriweather',
      color: theme.primaryText,
      fontWeight: FontWeight.w600,
      fontSize: 24.0,
      locale: const Locale('rou', 'RO'));
  String get titleLargeFamily => 'Merriweather';
  TextStyle get titleLarge => GoogleFonts.getFont('Merriweather',
      color: theme.primaryText,
      fontWeight: FontWeight.w600,
      fontSize: 20.0,
      locale: const Locale('rou', 'RO'));
  String get titleMediumFamily => 'Merriweather';
  TextStyle get titleMedium => GoogleFonts.getFont('Merriweather',
      color: theme.primaryText,
      fontWeight: FontWeight.w600,
      fontSize: 18.0,
      locale: const Locale('rou', 'RO'));
  String get titleSmallFamily => 'Merriweather';
  TextStyle get titleSmall => GoogleFonts.getFont('Merriweather',
      color: theme.primaryText,
      fontWeight: FontWeight.w600,
      fontSize: 16.0,
      locale: const Locale('rou', 'RO'));
  String get labelLargeFamily => 'Inter';
  TextStyle get labelLarge => GoogleFonts.getFont(
        'Inter',
        color: theme.secondaryText,
        fontWeight: FontWeight.normal,
        fontSize: 16.0,
      );
  String get labelMediumFamily => 'Inter';
  TextStyle get labelMedium => GoogleFonts.getFont(
        'Inter',
        color: theme.secondaryText,
        fontWeight: FontWeight.normal,
        fontSize: 14.0,
      );
  String get labelSmallFamily => 'Inter';
  TextStyle get labelSmall => GoogleFonts.getFont(
        'Inter',
        color: theme.secondaryText,
        fontWeight: FontWeight.normal,
        fontSize: 12.0,
      );
  String get bodyLargeFamily => 'Inter';
  TextStyle get bodyLarge => GoogleFonts.getFont(
        'Inter',
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 16.0,
      );
  String get bodyMediumFamily => 'Inter';
  TextStyle get bodyMedium => GoogleFonts.getFont(
        'Inter',
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 14.0,
      );
  String get bodySmallFamily => 'Inter';
  TextStyle get bodySmall => GoogleFonts.getFont(
        'Inter',
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 12.0,
      );
}

class DarkModeTheme extends FlutterFlowTheme {
  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color primary = const Color(0xFF790822);
  late Color secondary = const Color(0xFFE45D55);
  late Color tertiary = const Color(0xFFE88C77);
  late Color alternate = const Color(0xFFFFE5AD);
  late Color primaryText = const Color(0xFFFFE5AD);
  late Color secondaryText = const Color.fromARGB(255, 220, 189, 146);
  late Color primaryBackground = const Color(0xFF121212);
  late Color secondaryBackground = const Color(0xFF1D1D1D);
  late Color accent1 = const Color(0xFFFF8A80);
  late Color accent2 = const Color(0xFFFFA726);
  late Color accent3 = const Color(0xFFFFC107);
  late Color accent4 = const Color(0xFFFF5722);
  late Color success = const Color(0xFF81C784);
  late Color warning = const Color(0xFFFFB74D);
  late Color error = const Color(0xFFE57373);
  late Color info = const Color(0xFF64B5F6);
}

extension TextStyleHelper on TextStyle {
  TextStyle override({
    String? fontFamily,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    FontStyle? fontStyle,
    bool useGoogleFonts = true,
    TextDecoration? decoration,
    double? lineHeight,
    List<Shadow>? shadows,
  }) =>
      useGoogleFonts
          ? GoogleFonts.getFont(
              fontFamily!,
              color: color ?? this.color,
              fontSize: fontSize ?? this.fontSize,
              letterSpacing: letterSpacing ?? this.letterSpacing,
              fontWeight: fontWeight ?? this.fontWeight,
              fontStyle: fontStyle ?? this.fontStyle,
              decoration: decoration,
              height: lineHeight,
              shadows: shadows,
            )
          : copyWith(
              fontFamily: fontFamily,
              color: color,
              fontSize: fontSize,
              letterSpacing: letterSpacing,
              fontWeight: fontWeight,
              fontStyle: fontStyle,
              decoration: decoration,
              height: lineHeight,
              shadows: shadows,
            );
}
