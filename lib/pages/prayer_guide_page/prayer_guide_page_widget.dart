import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_prayer/custom_code/prayer/prayer_types_cache.dart';
import 'package:my_prayer/service_locator.dart';

import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PrayerGuidePageWidget extends StatefulWidget {
  const PrayerGuidePageWidget({super.key});

  @override
  State<PrayerGuidePageWidget> createState() => _PrayerGuidePageWidgetState();
}

class _PrayerGuidePageWidgetState extends State<PrayerGuidePageWidget> {
  final _typesCache = getIt<PrayerTypesCache>();
  int? _expandedTypeId;

  List<_GuideTypeItem> _types = const [];
  bool _loading = true;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadCatalog());
  }

  Future<void> _loadCatalog({bool forceRefresh = false}) async {
    setState(() {
      _loading = true;
      _loadFailed = false;
    });

    try {
      final catalogTypes = await _typesCache.load(forceRefresh: forceRefresh);
      final types = catalogTypes
          .where(
            (type) => type.prayers.isNotEmpty || type.subtypes.isNotEmpty,
          )
          .map((type) => _GuideTypeItem(type: type, path: type.type))
          .toList()
        ..sort((a, b) => a.type.sequence.compareTo(b.type.sequence));
      if (!mounted) {
        return;
      }
      setState(() => _types = types);
    } catch (_) {
      if (mounted) {
        setState(() => _loadFailed = true);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  ({String meaning, String whenToPray, String howToPray}) _guideFor(
    _GuideTypeItem item,
  ) {
    final label = '${item.type.type} ${item.path}'.toLowerCase();

    if (label.contains('utren')) {
      return (
        meaning:
            'Utrenia este rugăciunea de dimineață a Bisericii. Prin psalmi, cântări și rugăciuni, Îi mulțumim lui Dumnezeu pentru lumina unei noi zile și Îi încredințăm gândurile, lucrările și toate acțiunile noastre. Este chemarea de a începe fiecare zi în lumina lui Cristos.',
        whenToPray: '',
        howToPray: '',
      );
    }
    if (label.contains('oră') ||
        label.contains('ora ') ||
        label.contains('canonic')) {
      return (
        meaning:
            'Orele canonice (sau Ceasurile) așază rugăciunea în diferitele momente ale zilei și ne amintesc faptul că întreaga noastră viață Îi aparține lui Dumnezeu. Prin Ceasul întâi, al treilea, al șaselea și al nouălea, ne oprim din preocupările zilnice pentru a ne întoarce mintea și inima către El.',
        whenToPray: '',
        howToPray: '',
      );
    }
    if (label.contains('vecern')) {
      return (
        meaning:
            'Vecernia este rugăciunea de seară a Bisericii. Îi mulțumim lui Dumnezeu pentru binele primit, Îi cerem iertare pentru greșelile săvârșite și așezăm în mâinile Sale ziua care se încheie. În lumina blândă a serii, Îi încredințăm Lui viața noastră întreagă și pe toți cei dragi.',
        whenToPray: '',
        howToPray: '',
      );
    }
    if (label.contains('rozar')) {
      return (
        meaning:
            'Rozariul ne ajută să contemplăm tainele vieții lui Isus Cristos împreună cu Preasfânta Fecioară Maria. Repetarea rugăciunilor adună mintea și liniștește inima, pentru ca privirea noastră să rămână îndreptată spre Cristos și spre Evanghelia Sa.',
        whenToPray: '',
        howToPray: '',
      );
    }
    if (label.contains('tatăl nostru')) {
      return (
        meaning:
            'Rugăciunea Domnească este rugăciunea pe care însuși Isus ne-a dăruit-o: ne învață să-L numim pe Dumnezeu Tată și să căutăm voia Lui.',
        whenToPray:
            'Se rostește în orice moment al zilei, în rugăciunea personală, familială și liturgică.',
        howToPray:
            'Rostește fiecare cerere cu atenție: laudă Numele Tatălui, cere pâinea de toate zilele, iertare și puterea de a ierta.',
      );
    }
    if (label.contains('crez')) {
      return (
        meaning:
            'Crezul este mărturisirea credinței Bisericii: rezumă lucrarea Tatălui, a Fiului și a Spiritului Sfânt.',
        whenToPray:
            'Este potrivit dimineața, înaintea unei decizii importante și ori de câte ori dorești să-ți reînnoiești credința.',
        howToPray:
            'Rostește-l ca mărturisire personală, oprindu-te cu recunoștință asupra cuvintelor care îți vorbesc mai puternic.',
      );
    }
    if (label.contains('înger') || label.contains('angel')) {
      return (
        meaning:
            'Rugăciunea Îngerului Domnului amintește Buna Vestire și întruparea Fiului lui Dumnezeu pentru mântuirea noastră.',
        whenToPray:
            'În tradiția creștină se rostește dimineața, la amiază și seara; este potrivită pentru a sfinți ritmul zilei.',
        howToPray:
            'Oprește-te pentru câteva clipe din activitate și primește, asemenea Mariei, chemarea de a împlini voia lui Dumnezeu.',
      );
    }
    if (label.contains('diminea')) {
      return (
        meaning:
            'Rugăciunea de dimineață încredințează lui Dumnezeu ziua care începe și cere lumină, pace și credincioșie.',
        whenToPray:
            'Rostește-o la începutul zilei, înainte de a intra în griji și îndatoriri.',
        howToPray:
            'Mulțumește pentru darul vieții, încredințează persoanele dragi și oferă lui Dumnezeu munca și întâlnirile zilei.',
      );
    }
    if (label.contains('seară') || label.contains('seara')) {
      return (
        meaning:
            'Rugăciunea de seară este un timp de mulțumire, cercetare a inimii și odihnire în grija lui Dumnezeu.',
        whenToPray:
            'Rostește-o înainte de culcare, singur sau împreună cu familia.',
        howToPray:
            'Privește ziua cu sinceritate: mulțumește pentru bine, cere iertare pentru greșeli și încredințează noaptea Domnului.',
      );
    }
    if (label.contains('acatist')) {
      return (
        meaning:
            'Acatistul este o rugăciune de laudă și cinstire adusă Preasfintei Născătoare de Dumnezeu și Pururea Fecioarei Maria. Este un imn prin care îi aducem mulțumire Maicii Domnului pentru tot ceea ce I-a permis lui Dumnezeu să înfăptuiască, prin ea, în economia mântuirii și îi cerem să mijlocească pentru noi înaintea Fiului său, Isus Cristos, în bucurii, în încercări și în toate nevoile vieții.',
        whenToPray: '',
        howToPray: '',
      );
    }
    if (label.contains('paraclis')) {
      return (
        meaning:
            'Paraclisul este rugăciunea celui care caută ajutor și mângâiere. Prin cuvintele acestei rugăciuni, ne îndreptăm către Maica Domnului și îi încredințăm suferințele, neliniștile și speranțele noastre, cerându-i să ne ocrotească și să ne călăuzească spre Cristos.',
        whenToPray: '',
        howToPray: '',
      );
    }
    if (label.contains('psalm')) {
      return (
        meaning:
            'Psalmii sunt rugăciunea inspirată a poporului lui Dumnezeu: în ei se întâlnesc lauda, durerea, încrederea, pocăința și speranța.',
        whenToPray:
            'Sunt potriviți în orice timp, mai ales când îți este greu să găsești propriile cuvinte înaintea lui Dumnezeu.',
        howToPray:
            'Citește încet, ca pe o rugăciune personală. Lasă un verset să te însoțească peste zi și răspunde Domnului cu propriile tale cuvinte.',
      );
    }
    if (label.contains('liturgh') || label.contains('cânt')) {
      return (
        meaning:
            'Cântarea este rugăciunea care se înalță din inimă. Cântările liturgice, pricesnele și colindele păstrează și transmit credința Bisericii, unind cuvântul rugăciunii cu frumusețea muzicii și a tradiției creștine.',
        whenToPray: '',
        howToPray: '',
      );
    }
    if (label.contains('zilnic') || label.contains('rugăciuni zilnice')) {
      return (
        meaning:
            'Această secțiune reunește rugăciuni specifice pentru diferitele momente și împrejurări ale vieții: dimineața și seara, înainte și după masă, în clipe de mulțumire, de încercare sau de pocăință. Rostită cu statornicie, rugăciunea nu rămâne doar un moment al zilei, ci devine un mod de a trăi în prezența lui Dumnezeu.',
        whenToPray: '',
        howToPray: '',
      );
    }
    if (label.contains('spoved') || label.contains('pocăin')) {
      return (
        meaning:
            'Rugăciunile de pocăință ne ajută să ne recunoaștem cu sinceritate păcatul și să primim milostivirea vindecătoare a lui Dumnezeu.',
        whenToPray:
            'Sunt potrivite înainte de Spovadă, în zilele de post și ori de câte ori simți nevoia de împăcare cu Dumnezeu și cu aproapele.',
        howToPray:
            'Rostește-le fără teamă și fără justificări. Numește înaintea Domnului ceea ce apasă inima și fă un pas concret spre îndreptare.',
      );
    }
    if (label.contains('famil') || label.contains('copil')) {
      return (
        meaning:
            'Rugăciunea pentru familie încredințează Domnului relațiile, bucuriile și greutățile celor dragi, cerând pace și unitate.',
        whenToPray:
            'Este potrivită dimineața sau seara, la aniversări, în perioade de încercare și înaintea hotărârilor importante ale familiei.',
        howToPray:
            'Adu înaintea lui Dumnezeu fiecare persoană pe nume și cere harul de a o iubi cu răbdare, iertare și adevăr.',
      );
    }
    if (label.contains('maic') || label.contains('născătoare')) {
      return (
        meaning:
            'Această rugăciune ne îndreaptă către Maica Domnului, care mijlocește pentru noi și ne conduce întotdeauna la Fiul ei.',
        whenToPray:
            'Poate fi rostită în orice nevoie, mai ales pentru familie, bolnavi, pace și statornicie în credință.',
        howToPray:
            'Încredințează-i Mariei intențiile tale și cere-i să te ajute să răspunzi, asemenea ei, cu credință chemării lui Dumnezeu.',
      );
    }
    if (label.contains('sfânt') || label.contains('sfant')) {
      return (
        meaning:
            'Rugăciunea cere mijlocirea unui sfânt, martor al lui Cristos și frate mai mare pe drumul credinței.',
        whenToPray:
            'Este potrivită în ziua sărbătorii sfântului, înaintea unei încercări sau când dorești să-i urmezi o virtute.',
        howToPray:
            'Cere mijlocire și alege un gest concret prin care să urmezi în acea zi credința, curajul sau iubirea sfântului.',
      );
    }

    final title = item.type.type;
    return (
      meaning:
          '„$title” este un drum de rugăciune din tradiția Bisericii Greco-Catolice. Prin aceste texte, credința Bisericii devine laudă, cerere și apropiere de Dumnezeu.',
      whenToPray:
          'Poate fi rostită în liniște, în familie sau în comunitate, mai ales atunci când tema ei se potrivește cu nevoia și momentul tău de viață.',
      howToPray:
          'Începe cu semnul crucii, rostește cu atenție și lasă un scurt timp de tăcere la final. Întreabă-te ce răspuns concret te cheamă Dumnezeu să dai prin această rugăciune.',
    );
  }

  Future<void> _openPrayerType(PrayerTypeStruct type) async {
    await context.pushNamed(
      'AllPrayersPage',
      queryParameters: {
        'typeId': serializeParam(type.id, ParamType.int).toString(),
      }.withoutNulls,
      extra: <String, dynamic>{
        kTransitionInfoKey: const TransitionInfo(
          hasTransition: true,
          transitionType: PageTransitionType.fade,
          duration: Duration(milliseconds: 250),
        ),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final items = _types;

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primary,
        foregroundColor: theme.alternate,
        title: Text(
          'Ghid de rugăciune',
          style: theme.titleMedium.override(
            fontFamily: 'Merriweather',
            color: theme.alternate,
            letterSpacing: 0.0,
            useGoogleFonts: false,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Ghid de rugăciune',
                    style: theme.headlineSmall.override(
                      fontFamily: 'Merriweather',
                      letterSpacing: 0.0,
                      useGoogleFonts: false,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Acest ghid li se adresează tuturor celor care doresc să se apropie mai mult de Dumnezeu și să descopere bogăția rugăciunii Bisericii Române Unite cu Roma, Greco-Catolică, în tradiția de rugăciune a Congregației Surorilor Maicii Domnului.\n\nAplicația cuprinde rugăciuni și cântări care ne ajută să-I încredințăm lui Dumnezeu începutul și sfârșitul fiecărei zile, bucuriile, încercările și oamenii pe care îi purtăm în inimă.',
                    style: theme.bodyMedium.override(
                      fontFamily: 'Inter',
                      color: theme.secondaryText,
                      letterSpacing: 0.0,
                      lineHeight: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: theme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: theme.primary.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fie ca aceste rugăciuni să ne apropie de Cristos, să ne deschidă inima către aproapele și să ne ajute să trăim fiecare zi în comuniune cu Biserica, sub ocrotirea Preasfintei Fecioare Maria.',
                                style: theme.titleSmall.override(
                                  fontFamily: 'Merriweather',
                                  color: theme.primary,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: false,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _loadFailed
                      ? Center(
                          child: FilledButton.icon(
                            onPressed: () => unawaited(
                              _loadCatalog(forceRefresh: true),
                            ),
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Reîncearcă'),
                          ),
                        )
                      : items.isEmpty
                          ? Center(
                              child: Text(
                                'Nu am găsit niciun tip de rugăciune.',
                                style: theme.bodyMedium.override(
                                  fontFamily: 'Inter',
                                  color: theme.secondaryText,
                                  letterSpacing: 0.0,
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                16.0,
                                4.0,
                                16.0,
                                24.0,
                              ),
                              itemCount: items.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8.0),
                              itemBuilder: (context, index) {
                                final item = items[index];
                                final type = item.type;
                                final guide = _guideFor(item);
                                final expanded = _expandedTypeId == type.id;

                                return Material(
                                  color: theme.alternate,
                                  borderRadius: BorderRadius.circular(14.0),
                                  child: ExpansionTile(
                                    key: ValueKey('guide_${type.id}_$expanded'),
                                    initiallyExpanded: expanded,
                                    onExpansionChanged: (value) {
                                      setState(
                                        () => _expandedTypeId =
                                            value ? type.id : null,
                                      );
                                    },
                                    title: Text(
                                      type.type,
                                      style: theme.titleSmall.override(
                                        fontFamily: 'Merriweather',
                                        color: theme.primary,
                                        letterSpacing: 0.0,
                                        useGoogleFonts: false,
                                      ),
                                    ),
                                    childrenPadding: const EdgeInsets.fromLTRB(
                                      16.0,
                                      0.0,
                                      16.0,
                                      16.0,
                                    ),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 12.0,
                                        ),
                                        child: Text(
                                          guide.meaning,
                                          style: theme.bodyMedium.override(
                                            fontFamily: 'Inter',
                                            color: theme.primaryText,
                                            letterSpacing: 0.0,
                                            lineHeight: 1.55,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: () => unawaited(
                                            _openPrayerType(type),
                                          ),
                                          style: TextButton.styleFrom(
                                            foregroundColor: theme.primary,
                                            backgroundColor: theme.primary
                                                .withValues(alpha: 0.1),
                                          ),
                                          child: const Text(
                                            'Vezi rugăciunile',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideTypeItem {
  const _GuideTypeItem({
    required this.type,
    required this.path,
  });

  final PrayerTypeStruct type;
  final String path;
}
