import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'privacy_policy_page_model.dart';
export 'privacy_policy_page_model.dart';

class PrivacyPolicyPageWidget extends StatefulWidget {
  const PrivacyPolicyPageWidget({super.key});

  @override
  State<PrivacyPolicyPageWidget> createState() =>
      _PrivacyPolicyPageWidgetState();
}

class _PrivacyPolicyPageWidgetState extends State<PrivacyPolicyPageWidget> {
  late PrivacyPolicyPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PrivacyPolicyPageModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          iconTheme:
              IconThemeData(color: FlutterFlowTheme.of(context).alternate),
          automaticallyImplyLeading: true,
          title: Text(
            'Politica de confiedențialite',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Merriweather',
                  color: FlutterFlowTheme.of(context).alternate,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                ),
          ),
          actions: const [],
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Politica de Confidențialitate - MyPrayer\n\nUltima actualizare: 23.12.2024\n\nIntroducere\n\nMyPrayer este o aplicație dezvoltată de SeraphicApps pentru Congregatia Surorilor Maicii Domnului, menitată să faciliteze ascultarea rugăciunilor utilizatorilor. Respectăm confidențialitatea utilizatorilor noștri și ne angajăm să protejăm datele lor personale.\n\nAceastă politică explică ce informații sunt colectate, cum sunt utilizate și ce măsuri luăm pentru a le proteja.\n\nCe date colectăm?\n\nAplicația MyPrayer nu colectează date personale identificabile. Singurele informații pe care le colectăm sunt:\n\nDate legate de instalarea aplicației:\n\nTipul dispozitivului utilizat (de exemplu, telefon sau tabletă).\n\nSistemul de operare utilizat (de exemplu, Android sau iOS).\n\nDate de performanță și utilizare:\n\nStatistici anonime privind utilizarea aplicației (de exemplu, numărul de sesiuni deschise).\n\nProbleme tehnice și erori apărute în timpul utilizării aplicației.\n\nDate de diagnostic:\n\nInformații anonime utilizate pentru a îmbunătăți performanța aplicației.\n\nCum utilizăm aceste date?\n\nDatele colectate sunt utilizate exclusiv pentru următoarele scopuri:\n\nÎmbunătățirea aplicației:\n\nIdentificarea și remedierea problemelor tehnice.\n\nOptimizarea funcționalitċții aplicației pentru o experiență mai bună a utilizatorului.\n\nAnaliză internă:\n\nAnaliza statisticilor anonime pentru a înețelege modul în care aplicația este utilizată.\n\nCum protejăm datele utilizatorilor?\n\nNu colectăm informații personale identificabile, astfel încât confidențialitatea utilizatorilor este garantată din start.\n\nToate datele colectate sunt anonimizate și stocate pe servere securizate.\n\nFolosim protocoale standard și tehnologii avansate pentru a preveni accesul neautorizat la datele aplicației.\n\nPartajarea datelor\n\nMyPrayer nu partajează datele colectate cu terțe părți, cu excepția:\n\nServiciilor necesare funcționării aplicației:\n\nProducători de soluții de analiză tehnică (de exemplu, pentru raportarea erorilor).\n\nToate serviciile utilizate respectă la rândul lor confidențialitatea și securitatea datelor.\n\nDrepturile utilizatorilor\n\nDeoarece MyPrayer nu colectează date personale identificabile, utilizatorii beneficiază implicit de confidențialitate totală. Dacă aveți întrebări sau preocupări legate de datele colectate, ne puteți contacta folosind informațiile de mai jos.\n\nContact\n\nPentru orice întrebări sau nelămuriri legate de această Politică de Confidențialitate, vă rugăm să ne contactați la:\n\nSeraphicApps\nCongregația Surorilor Maicii Domnului\nEmail: sserafim.socaciu@gmail.com\nTelefon: 0757476361\n\nAceastă Politică de Confidențialitate poate fi actualizată periodic. Orice modificări vor fi reflectate prin actualizarea acestei pagini.',
                    textAlign: TextAlign.start,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Inter',
                          letterSpacing: 0.0,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
