import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';

class AboutPageWidget extends StatelessWidget {
  const AboutPageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
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
          'Cine suntem',
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
              text:
                  'Această aplicație este un proiect al Congregației Surorilor Maicii Domnului, care își are sediul Casei Generale în Cluj-Napoca, România.',
              style: bodyStyle,
            ),
            _Paragraph(
              text:
                  'Congregația Surorilor Maicii Domnului (CMD) a fost întemeiată la Blaj, în 2 februarie 1921, de Mitropolitul Dr. Vasile Suciu, și așezată sub ocrotirea Preasfintei Fecioare Maria. De la începuturi, viața Surorilor s-a fundamentat pe rugăciune, muncă și slujirea aproapelui.',
              style: bodyStyle,
            ),
            _Paragraph(
              text:
                  'Spiritualitatea CMD își are izvorul în Cuvântul lui Dumnezeu, în viața liturgică a Bisericii și în exemplul Preasfintei Fecioare Maria.',
              style: bodyStyle,
            ),
            _Paragraph(
              text:
                  'Rugăciunea liturgică, celebrată în tradiția bizantină, se află în centrul vieții comunităților CMD și dă ritm fiecărei zile. Prin această aplicație, Surorile împărtășesc o parte din comoara spirituală moștenită în cei peste 100 de ani de existență celor care vor să descopere sau să aprofundeze rugăciunile și cântările greco-catolice.',
              style: bodyStyle,
            ),
            _Paragraph(
              text:
                  'Aplicația cuprinde rugăciuni pentru diferitele momente ale zilei, precum și cântări care însoțesc anul liturgic și însuflețesc evlavia credincioșilor. Ea poate să fie un ajutor pentru rugăciunea personală și familială și, totodată, o cale de apropiere de frumusețea și profunzimea spiritualității bizantine.',
              style: bodyStyle,
            ),
            _Paragraph(
              text:
                  'La Mănăstirea Maicii Domnului – Sanctuar Arhiepiscopal Major din Cluj-Napoca, Surorile se roagă pentru intențiile încredințate lor, primesc și însoțesc persoanele care caută un cuvânt de lumină și slujesc viața liturgică a Bisericii.',
              style: bodyStyle,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28.0),
              child: Divider(color: theme.secondaryBackground),
            ),
            Text(
              'Rugăciune către Maica Domnului',
              style: theme.titleMedium.override(
                fontFamily: 'Merriweather',
                color: theme.primary,
                letterSpacing: 0.0,
              ),
            ),
            const SizedBox(height: 12.0),
            Text(
              'Preasfântă Fecioară Maria, Maica lui Dumnezeu, păstrează-ne sub ocrotirea ta. Călăuzește-ne pașii către Fiul tău, Isus Cristos, și dobândește-ne o inimă curată, pace sufletească și statornicie în rugăciune. Amin.',
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
