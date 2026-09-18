import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_prayer/custom_code/prayer/prayer_types_cache.dart';
import 'package:my_prayer/service_locator.dart';

import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/l10n/generated/app_localizations.dart';

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
    BuildContext context,
    _GuideTypeItem item,
  ) {
    final l10n = AppLocalizations.of(context);
    final label = '${item.type.type} ${item.path}'.toLowerCase();

    if (label.contains('utren')) {
      return (
        meaning: l10n.guideMeaningUtrenia,
        whenToPray: '',
        howToPray: '',
      );
    }
    if (label.contains('oră') ||
        label.contains('ora ') ||
        label.contains('canonic')) {
      return (
        meaning: l10n.guideMeaningCanonicalHours,
        whenToPray: '',
        howToPray: '',
      );
    }
    if (label.contains('vecern')) {
      return (
        meaning: l10n.guideMeaningVespers,
        whenToPray: '',
        howToPray: '',
      );
    }
    if (label.contains('rozar')) {
      return (
        meaning: l10n.guideMeaningRosary,
        whenToPray: '',
        howToPray: '',
      );
    }
    if (label.contains('tatăl nostru')) {
      return (
        meaning: l10n.guideMeaningOurFather,
        whenToPray:
            'Se rostește în orice moment al zilei, în rugăciunea personală, familială și liturgică.',
        howToPray:
            'Rostește fiecare cerere cu atenție: laudă Numele Tatălui, cere pâinea de toate zilele, iertare și puterea de a ierta.',
      );
    }
    if (label.contains('crez')) {
      return (
        meaning: l10n.guideMeaningCreed,
        whenToPray:
            'Este potrivit dimineața, înaintea unei decizii importante și ori de câte ori dorești să-ți reînnoiești credința.',
        howToPray:
            'Rostește-l ca mărturisire personală, oprindu-te cu recunoștință asupra cuvintelor care îți vorbesc mai puternic.',
      );
    }
    if (label.contains('înger') || label.contains('angel')) {
      return (
        meaning: l10n.guideMeaningAngelus,
        whenToPray:
            'În tradiția creștină se rostește dimineața, la amiază și seara; este potrivită pentru a sfinți ritmul zilei.',
        howToPray:
            'Opește-te pentru câteva clipe din activitate și primește, asemenea Mariei, chemarea de a împlini voia lui Dumnezeu.',
      );
    }
    if (label.contains('diminea')) {
      return (
        meaning: l10n.guideMeaningMorning,
        whenToPray:
            'Rostește-o la începutul zilei, înainte de a intra în griji și îndatoriri.',
        howToPray:
            'Mulțumește pentru darul vieții, încredințează persoanele dragi și oferă lui Dumnezeu munca și întâlnirile zilei.',
      );
    }
    if (label.contains('seară') || label.contains('seara')) {
      return (
        meaning: l10n.guideMeaningEvening,
        whenToPray:
            'Rostește-o înainte de culcare, singur sau împreună cu familia.',
        howToPray:
            'Privește ziua cu sinceritate: mulțumește pentru bine, cere iertare pentru greșeli și încredințează noaptea Domnului.',
      );
    }
    if (label.contains('acatist')) {
      return (
        meaning: l10n.guideMeaningAcathist,
        whenToPray: '',
        howToPray: '',
      );
    }
    if (label.contains('paraclis')) {
      return (
        meaning: l10n.guideMeaningParaclis,
        whenToPray: '',
        howToPray: '',
      );
    }
    if (label.contains('psalm')) {
      return (
        meaning: l10n.guideMeaningPsalms,
        whenToPray:
            'Sunt potriviți în orice timp, mai ales când îți este greu să găsești propriile cuvinte înaintea lui Dumnezeu.',
        howToPray:
            'Citește încet, ca pe o rugăciune personală. Lasă un verset să te însoțească peste zi și răspunde Domnului cu propriile tale cuvinte.',
      );
    }
    if (label.contains('liturgh') || label.contains('cânt')) {
      return (
        meaning: l10n.guideMeaningHymns,
        whenToPray: '',
        howToPray: '',
      );
    }
    if (label.contains('zilnic') || label.contains('rugăciuni zilnice')) {
      return (
        meaning: l10n.guideMeaningDaily,
        whenToPray: '',
        howToPray: '',
      );
    }
    if (label.contains('spoved') || label.contains('pocăin')) {
      return (
        meaning: l10n.guideMeaningRepentance,
        whenToPray:
            'Sunt potrivite înainte de Spovadă, în zilele de post și ori de câte ori simți nevoia de împăcare cu Dumnezeu și cu aproapele.',
        howToPray:
            'Rostește-le fără teamă și fără justificări. Numește înaintea Domnului ceea ce apasă inima și fă un pas concret spre îndreptare.',
      );
    }
    if (label.contains('famil') || label.contains('copil')) {
      return (
        meaning: l10n.guideMeaningFamily,
        whenToPray:
            'Este potrivită dimineața sau seara, la aniversari, în perioade de încercare și înaintea hotărârilor importante ale familiei.',
        howToPray:
            'Adu înaintea lui Dumnezeu fiecare persoană pe nume și cere harul de a o iubi cu răbdare, iertare și adevăr.',
      );
    }
    if (label.contains('maic') || label.contains('născătoare')) {
      return (
        meaning: l10n.guideMeaningMotherOfGod,
        whenToPray:
            'Poate fi rostită în orice nevoie, mai ales pentru familie, bolnavi, pace și statornicie în credință.',
        howToPray:
            'Încredințează-i Mariei intențiile tale și cere-i să te ajute să răspunzi, asemenea ei, cu credință chemării lui Dumnezeu.',
      );
    }
    if (label.contains('sfânt') || label.contains('sfant')) {
      return (
        meaning: l10n.guideMeaningSaint,
        whenToPray:
            'Este potrivită în ziua sărbătorii sfântului, înaintea unei încercări sau când dorești să-i urmezi o virtute.',
        howToPray:
            'Cere mijlocire și alege un gest concret prin care să urmezi în acea zi credința, curajul sau iubirea sfântului.',
      );
    }

    final title = item.type.type;
    return (
      meaning: l10n.guideMeaningDefault(title),
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
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).guidePageTitle,
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 24.0),
          children: [
            Text(
              AppLocalizations.of(context).guideIntro,
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
              child: Text(
                AppLocalizations.of(context).guideQuote,
                style: theme.titleSmall.override(
                  fontFamily: 'Merriweather',
                  color: theme.primary,
                  letterSpacing: 0.0,
                  useGoogleFonts: false,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_loadFailed)
              Center(
                child: FilledButton.icon(
                  onPressed: () => unawaited(
                    _loadCatalog(forceRefresh: true),
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(AppLocalizations.of(context).retry),
                ),
              )
            else if (items.isEmpty)
              Center(
                child: Text(
                  AppLocalizations.of(context).guideEmptyTypes,
                  style: theme.bodyMedium.override(
                    fontFamily: 'Inter',
                    color: theme.secondaryText,
                    letterSpacing: 0.0,
                  ),
                ),
              )
            else
              ...List.generate(items.length, (index) {
                final item = items[index];
                final type = item.type;
                final guide = _guideFor(context, item);
                final expanded = _expandedTypeId == type.id;

                return Padding(
                  padding: EdgeInsets.only(top: index == 0 ? 0.0 : 8.0),
                  child: Material(
                    color: theme.secondaryBackground,
                    borderRadius: BorderRadius.circular(14.0),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        key: ValueKey('guide_${type.id}_$expanded'),
                        initiallyExpanded: expanded,
                        onExpansionChanged: (value) {
                          setState(
                            () => _expandedTypeId = value ? type.id : null,
                          );
                        },
                        title: Text(
                          type.type,
                          style: theme.titleSmall.override(
                            fontFamily: 'Merriweather',
                            color: theme.primaryText,
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
                                color: theme.secondaryText,
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
                                backgroundColor:
                                    theme.primary.withValues(alpha: 0.1),
                              ),
                              child: Text(
                                AppLocalizations.of(context).guideOpenPrayers,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
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
