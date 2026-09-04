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

  static const _privacyPolicyText =
      '''Politica de confidențialitate - Rugăciuni și cântări - CMD

Ultima actualizare: 04.09.2026

Introducere

Aplicația „Rugăciuni și cântări - CMD” este pusă la dispoziție de Congregatia Surorilor Maicii Domnului. Această politică explică modul în care aplicația utilizează datele necesare funcționării sale.

Date stocate pe dispozitiv

Aplicația păstrează local, pe dispozitivul utilizatorului, preferințele de afișare și redare, rugăciunile favorite, descărcările pentru utilizare offline, jurnalul de rugăciune și mementourile configurate de utilizator. Jurnalul de rugăciune este păstrat local timp de cel mult 31 de zile. Aceste date nu sunt transmise de aplicație către noi.

Notificări și redare audio

Cu acordul utilizatorului, aplicația trimite notificări locale pentru mementourile de rugăciune. Informațiile necesare acestor notificări rămân pe dispozitiv. Aplicația poate reda audio în fundal și poate afișa controale de redare în sistemul de operare. Nu solicită acces la microfon.

Conținut și conexiune la internet

Pentru a încărca rugăciuni, texte, imagini și fișiere audio, aplicația se conectează la infrastructura Supabase. Furnizorul serviciului poate prelucra date tehnice de conexiune, precum adresa IP și jurnale de securitate, necesare furnizării și protejării serviciului. Conținutul descărcat pentru utilizare offline este stocat pe dispozitiv.

Date personale și partajare

Aplicația nu solicită crearea unui cont și nu colectează în mod intenționat numele, adresa de e-mail, numărul de telefon, locația sau contacte ale utilizatorului. Nu folosim servicii de publicitate comportamentală și nu vindem date personale.

Securitate și control

Poți șterge datele stocate local prin eliminarea favoritelor, a jurnalului, a mementourilor și a descărcărilor din aplicație sau prin ștergerea datelor aplicației din setările dispozitivului. Permisiunea pentru notificări poate fi retrasă oricând din setările sistemului.

Contact

Pentru întrebări legate de această politică, ne poți contacta la:

SeraphicApps
Congregația Surorilor Maicii Domnului
Email: sserafim.socaciu@gmail.com

Această politică poate fi actualizată periodic. Orice modificare va fi publicată pe această pagină.''';

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
            'Politica de confidențialitate',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Merriweather',
                  color: FlutterFlowTheme.of(context).alternate,
                  fontSize: 20.0,
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
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                    child: Text(
                      _privacyPolicyText.isNotEmpty
                          ? _privacyPolicyText
                          : 'Politica de Confidențialitate - Rugaciuni și cântări - CMD\n\nUltima actualizare: 04.09.2026\n\nIntroducere\n\Rugăciuni și Cântări - CMD este o aplicație dezvoltată de SeraphicApps pentru Congregatia Surorilor Maicii Domnului, menitată să faciliteze ascultarea rugăciunilor utilizatorilor. Respectăm confidențialitatea utilizatorilor noștri și ne angajăm să protejăm datele lor personale.\n\nAceastă politică explică ce informații sunt colectate, cum sunt utilizate și ce măsuri luăm pentru a le proteja.\n\nCe date colectăm?\n\nAplicația „Rugaciuni și cântări - CMD” nu colectează date personale identificabile. Singurele informații pe care le colectăm sunt:\n\nDate legate de instalarea aplicației:\n\nTipul dispozitivului utilizat (de exemplu, telefon sau tabletă).\n\nSistemul de operare utilizat (de exemplu, Android sau iOS).\n\nDate de performanță și utilizare:\n\nStatistici anonime privind utilizarea aplicației (de exemplu, numărul de sesiuni deschise).\n\nProbleme tehnice și erori apărute în timpul utilizării aplicației.\n\nDate de diagnostic:\n\nInformații anonime utilizate pentru a îmbunătăți performanța aplicației.\n\nCum utilizăm aceste date?\n\nDatele colectate sunt utilizate exclusiv pentru următoarele scopuri:\n\nÎmbunătățirea aplicației:\n\nIdentificarea și remedierea problemelor tehnice.\n\nOptimizarea funcționalitċții aplicației pentru o experiență mai bună a utilizatorului.\n\nAnaliză internă:\n\nAnaliza statisticilor anonime pentru a înețelege modul în care aplicația este utilizată.\n\nCum protejăm datele utilizatorilor?\n\nNu colectăm informații personale identificabile, astfel încât confidențialitatea utilizatorilor este garantată din start.\n\nToate datele colectate sunt anonimizate și stocate pe servere securizate.\n\nFolosim protocoale standard și tehnologii avansate pentru a preveni accesul neautorizat la datele aplicației.\n\nPartajarea datelor\n\nRugăciuni și cântări - CMD nu partajează datele colectate cu terțe părți, cu excepția:\n\nServiciilor necesare funcționării aplicației:\n\nProducători de soluții de analiză tehnică (de exemplu, pentru raportarea erorilor).\n\nToate serviciile utilizate respectă la rândul lor confidențialitatea și securitatea datelor.\n\nDrepturile utilizatorilor\n\nDeoarece „Rugaciuni și cântări - CMD” nu colectează date personale identificabile, utilizatorii beneficiază implicit de confidențialitate totală. Dacă aveți întrebări sau preocupări legate de datele colectate, ne puteți contacta folosind informațiile de mai jos.\n\nContact\n\nPentru orice întrebări sau nelămuriri legate de această Politică de Confidențialitate, vă rugăm să ne contactați la:\n\nSeraphicApps\nCongregația Surorilor Maicii Domnului\nEmail: sserafim.socaciu@gmail.com\nTelefon: 0757476361\n\nAceastă Politică de Confidențialitate poate fi actualizată periodic. Orice modificări vor fi reflectate prin actualizarea acestei pagini.',
                      textAlign: TextAlign.start,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Inter',
                            letterSpacing: 0.0,
                          ),
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
