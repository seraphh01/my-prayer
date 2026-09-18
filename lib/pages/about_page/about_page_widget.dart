import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/l10n/generated/app_localizations.dart';

class AboutPageWidget extends StatelessWidget {
  const AboutPageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final bodyStyle = theme.bodyMedium.override(
      fontFamily: 'Inter',
      color: theme.primaryText,
      letterSpacing: 0.0,
      lineHeight: 1.55,
    );

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primary,
        iconTheme: IconThemeData(color: theme.alternate),
        title: Text(
          l10n.aboutPageTitle,
          style: theme.titleLarge.override(
            fontFamily: 'Merriweather',
            color: theme.alternate,
            letterSpacing: 0.0,
          ),
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 32.0),
          children: [
            _Paragraph(
              text: l10n.aboutParagraph1,
              style: bodyStyle,
            ),
            _Paragraph(
              text: l10n.aboutParagraph2,
              style: bodyStyle,
            ),
            _Paragraph(
              text: l10n.aboutParagraph3,
              style: bodyStyle,
            ),
            _Paragraph(
              text: l10n.aboutParagraph4,
              style: bodyStyle,
            ),
            _Paragraph(
              text: l10n.aboutParagraph5,
              style: bodyStyle,
            ),
            _Paragraph(
              text: l10n.aboutParagraph6,
              style: bodyStyle,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28.0),
              child: Divider(color: theme.secondaryBackground),
            ),
            Text(
              l10n.aboutPrayerTitle,
              style: theme.titleMedium.override(
                fontFamily: 'Merriweather',
                color: theme.primary,
                letterSpacing: 0.0,
              ),
            ),
            const SizedBox(height: 12.0),
            Text(
              l10n.aboutPrayerText,
              style: bodyStyle,
            ),
          ],
        ),
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  const _Paragraph({required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0),
      child: Text(text, style: style),
    );
  }
}
