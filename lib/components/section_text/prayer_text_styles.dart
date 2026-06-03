import 'package:flutter/material.dart';

import '/custom_code/prayer/prayer_typography.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class PrayerTextStyles {
  PrayerTextStyles._({
    required this.firstLetter,
    required this.bodyPlaying,
    required this.bodyIdle,
    required this.bodyPassed,
  });

  final TextStyle firstLetter;
  final TextStyle bodyPlaying;
  final TextStyle bodyIdle;
  final TextStyle bodyPassed;

  factory PrayerTextStyles.of(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final typography = PrayerTypography.of(context);
    final fontMultiplier = typography.fontSizeMultiplier;
    final fontFamily = typography.fontFamily;
    final bodySize = 18.0 * fontMultiplier;

    TextStyle bodyBase({FontWeight? weight, Color? color}) {
      return theme.bodyMedium.override(
        fontFamily: fontFamily,
        fontSize: bodySize,
        fontWeight: weight ?? FontWeight.w400,
        lineHeight: 1.2,
        color: color ?? theme.primaryText,
      );
    }

    final playingShadows = [
      Shadow(
        blurRadius: 1,
        color: theme.secondaryText,
        offset: const Offset(-0.5, 0),
      ),
      Shadow(
        blurRadius: 0.6,
        color: theme.secondaryText,
        offset: const Offset(-0.3, 0),
      ),
      Shadow(
        blurRadius: 0.6,
        color: theme.secondaryText,
        offset: const Offset(0.3, 0),
      ),
      Shadow(
        blurRadius: 0.6,
        color: theme.secondaryText,
        offset: const Offset(0, -0.1),
      ),
      Shadow(
        blurRadius: 0.6,
        color: theme.secondaryText,
        offset: const Offset(0, 0.1),
      ),
    ];

    return PrayerTextStyles._(
      firstLetter: theme.headlineLarge.override(
        fontFamily: 'PlayBall',
        color: theme.secondary,
        fontSize: 32.0 * fontMultiplier,
        letterSpacing: 2,
        useGoogleFonts: false,
        lineHeight: 0.4,
      ),
      bodyPlaying: bodyBase(weight: FontWeight.w500).copyWith(
        shadows: playingShadows,
      ),
      bodyIdle: bodyBase(),
      bodyPassed: bodyBase(
        weight: FontWeight.w200,
        color: theme.secondaryText,
      ),
    );
  }

  TextStyle bodyStyle({
    required bool isSynced,
    required bool isPlaying,
    required bool hasPassed,
    required bool isItalic,
  }) {
    TextStyle style;
    if (!isSynced || isPlaying || !hasPassed) {
      style = isPlaying ? bodyPlaying : bodyIdle;
    } else {
      style = bodyPassed;
    }
    if (isItalic) {
      style = style.copyWith(fontStyle: FontStyle.italic);
    }
    return style;
  }
}

class SectionTitleStyles {
  SectionTitleStyles._({
    required this.active,
    required this.inactive,
  });

  final TextStyle active;
  final TextStyle inactive;

  factory SectionTitleStyles.of(BuildContext context, {required bool italic}) {
    final theme = FlutterFlowTheme.of(context);
    final typography = PrayerTypography.of(context);
    final fontMultiplier = typography.fontSizeMultiplier;
    final fontFamily = typography.fontFamily;
    final fontStyle = italic ? FontStyle.italic : FontStyle.normal;

    return SectionTitleStyles._(
      active: theme.titleSmall.override(
        fontFamily: fontFamily,
        fontStyle: fontStyle,
        color: theme.secondary,
        fontSize: fontMultiplier * 18,
        letterSpacing: 0.0,
        shadows: [
          Shadow(
            color: theme.secondary,
            offset: Offset.zero,
            blurRadius: 0.5,
          ),
        ],
      ),
      inactive: theme.titleMedium.override(
        fontFamily: fontFamily,
        fontStyle: fontStyle,
        color: theme.secondary,
        fontSize: fontMultiplier * 18,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
