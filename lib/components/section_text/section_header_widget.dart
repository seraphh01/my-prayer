import 'package:flutter/material.dart';

import '/backend/schema/structs/index.dart';
import '/custom_code/prayer/prayer_typography.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class SectionHeaderWidget extends StatelessWidget {
  const SectionHeaderWidget({
    super.key,
    required this.section,
  });

  final PrayerSectionStruct section;

  @override
  Widget build(BuildContext context) {
    if (!section.showTitle && !section.showSubtitle) {
      return const SizedBox.shrink();
    }

    final typography = PrayerTypography.of(context);
    final fontMultiplier = typography.fontSizeMultiplier;
    final fontFamily = typography.fontFamily;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 16.0, 12.0, 8.0),
      child: Column(
        spacing: 8.0,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (section.showTitle)
            Text(
              section.title,
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).titleMedium.override(
                    fontFamily: fontFamily,
                    fontSize: 18.0 * fontMultiplier,
                    letterSpacing: 0.0,
                  ),
            ),
          if (section.showSubtitle && section.subtitle.isNotEmpty)
            Text(
              section.subtitle,
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).labelMedium.override(
                    fontFamily: fontFamily,
                    fontSize: 16 * fontMultiplier,
                    letterSpacing: 0.0,
                    fontStyle: FontStyle.italic,
                  ),
            ),
        ],
      ),
    );
  }
}
