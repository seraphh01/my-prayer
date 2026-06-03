import 'package:flutter/material.dart';
import 'package:my_prayer/backend/schema/enums/enums.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'prayer_text_styles.dart';

class PrayerTextSpan extends StatelessWidget {
  const PrayerTextSpan({
    super.key,
    required this.text,
    required this.type,
    required this.quoteSource,
    required this.showDropCap,
    required this.isPlaying,
    required this.hasPassed,
    required this.isSynced,
    required this.onPressed,
    required this.styles,
  });

  final String text;
  final TextElementType type;
  final String quoteSource;
  final bool showDropCap;
  final bool isPlaying;
  final bool hasPassed;
  final bool isSynced;
  final VoidCallback onPressed;
  final PrayerTextStyles styles;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = styles.bodyStyle(
      isSynced: isSynced,
      isPlaying: isPlaying,
      hasPassed: hasPassed,
      isItalic: type == TextElementType.italicText,
    );

    final firstLetter =
        showDropCap && text.isNotEmpty ? text.substring(0, 1) : null;
    final restOfText =
        showDropCap && text.isNotEmpty ? text.substring(1) : text;

    return Semantics(
      button: isSynced,
      label: text,
      child: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: isSynced ? onPressed : null,
        child: RichText(
          textScaler: MediaQuery.textScalerOf(context),
          textAlign: TextAlign.justify,
          textHeightBehavior:
              const TextHeightBehavior(applyHeightToFirstAscent: false),
          text: TextSpan(
            children: [
              const TextSpan(text: '\u00A0\u00A0\u00A0'),
              if (type == TextElementType.quoteText)
                TextSpan(text: '«', style: bodyStyle),
              if (firstLetter != null && firstLetter.isNotEmpty)
                TextSpan(
                  text: firstLetter,
                  style: styles.firstLetter,
                ),
              TextSpan(
                text: valueOrDefault<String>(
                  restOfText,
                  'Textul va fi adăugat curând.',
                ),
                style: bodyStyle,
              ),
              if (type == TextElementType.quoteText)
                TextSpan(
                  children: [
                    TextSpan(text: '»', style: bodyStyle),
                    TextSpan(text: quoteSource, style: bodyStyle),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
