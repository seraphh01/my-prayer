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
            Text.rich(
              TextSpan(
                style: bodyStyle,
                children: const [
                  TextSpan(text: 'Această aplicație este un proiect al '),
                  TextSpan(
                    text: 'Congregației Surorilor Maicii Domnului (CMD)',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text:
                        ' din Cluj-Napoca, născut din dorința de a face mai accesibile rugăciunea, cântarea și bogăția spirituală a tradiției ',
                  ),
                  TextSpan(
                    text: 'Bisericii Române Unite cu Roma, Greco-Catolică',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
            ),
            _Paragraph(
              text:
                  'Congregația Surorilor Maicii Domnului a fost întemeiată la 2 februarie 1921, la Blaj, de Mitropolitul Dr. Vasile Suciu, sub ocrotirea Preasfintei Fecioare Maria. Încă de la început, viața Surorilor a fost întemeiată pe rugăciune, muncă și slujirea aproapelui.',
              style: bodyStyle,
            ),
            _Paragraph(
              text:
                  'Spiritualitatea Congregației se inspiră din Cuvântul lui Dumnezeu, din exemplul Preasfintei Fecioare Maria și din viața liturgică a Bisericii Greco-Catolice. Rugăciunea liturgică, celebrată după tradiția bizantină, ocupă un loc central în viața comunității și ritmează viața de zi cu zi a Surorilor.',
              style: bodyStyle,
            ),
            Text.rich(
              TextSpan(
                style: bodyStyle,
                children: const [
                  TextSpan(
                    text:
                        'Prin această aplicație dorim să împărtășim această comoară spirituală tuturor celor care doresc să se roage, să descopere sau să aprofundeze ',
                  ),
                  TextSpan(
                    text: 'rugăciunile și cântările greco-catolice',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
            ),
            _Paragraph(
              text:
                  'Aici puteți găsi rugăciuni pentru diferite momente ale zilei, slujbe și rânduieli de rugăciune, precum și cântări care însoțesc viața liturgică și devoțională a Bisericii. Ne dorim ca aplicația să fie un sprijin pentru rugăciunea personală și familială și, în același timp, o punte către frumusețea și profunzimea spiritualității bizantine.',
              style: bodyStyle,
            ),
            Text.rich(
              TextSpan(
                style: bodyStyle,
                children: const [
                  TextSpan(
                    text:
                        'Misiunea noastră este aceeași care animă comunitatea Surorilor Maicii Domnului: ',
                  ),
                  TextSpan(
                    text: 'rugăciunea și slujirea',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text:
                        '. La Mănăstirea Maicii Domnului din Cluj-Napoca, Surorile desfășoară un apostolat al rugăciunii, se roagă pentru intențiile credincioșilor, oferă însoțire spirituală și se implică în apostolatul liturgic.',
                  ),
                ],
              ),
            ),
            _Paragraph(
              text:
                  'Prin această aplicație, dorim ca rugăciunea să poată însoți fiecare om, oriunde s-ar afla: acasă, în călătorie, în familie sau în momentele de liniște ale fiecărei zile.',
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
              'Preasfântă Fecioară Maria, Maica lui Dumnezeu, păzește-ne sub ocrotirea ta. Călăuzește-ne către Fiul tău, Isus Cristos, și dăruiește-ne inimă curată, pace și statornicie în rugăciune. Amin.',
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
