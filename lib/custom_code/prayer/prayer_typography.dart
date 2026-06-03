import '/app_state.dart';
import '/flutter_flow/flutter_flow_theme.dart';

import 'package:flutter/material.dart';

class PrayerTypography extends InheritedWidget {
  const PrayerTypography({
    super.key,
    required this.fontFamily,
    required this.fontSizeMultiplier,
    required super.child,
  });

  final String fontFamily;
  final double fontSizeMultiplier;

  static PrayerTypography of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<PrayerTypography>();
    assert(scope != null, 'PrayerTypography not found in context');
    return scope!;
  }

  static PrayerTypography? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PrayerTypography>();
  }

  @override
  bool updateShouldNotify(PrayerTypography oldWidget) {
    return fontFamily != oldWidget.fontFamily ||
        fontSizeMultiplier != oldWidget.fontSizeMultiplier;
  }

  /// Applies the prayer font family; optionally scales [fontSize] by multiplier.
  TextStyle style(
    TextStyle base, {
    double? fontSize,
    bool scaleFontSize = true,
    Color? color,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? lineHeight,
  }) {
    final scaledSize = fontSize == null
        ? null
        : (scaleFontSize ? fontSize * fontSizeMultiplier : fontSize);
    return base.override(
      fontFamily: fontFamily,
      fontSize: scaledSize,
      color: color,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      lineHeight: lineHeight,
      useGoogleFonts: fontFamily != 'PlayBall',
    );
  }
}

class PrayerTypographyScope extends StatelessWidget {
  const PrayerTypographyScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: FFAppState(),
      builder: (context, _) {
        final appState = FFAppState();
        return PrayerTypography(
          fontFamily: appState.fontFamily,
          fontSizeMultiplier: appState.fontSizeMultiplier,
          child: child,
        );
      },
    );
  }
}
