import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_prayer/backend/schema/enums/enums.dart';
import 'package:my_prayer/custom_code/prayer/prayer_types_cache.dart';
import 'package:my_prayer/service_locator.dart';

import '/backend/schema/structs/index.dart';
import '/components/prayer_type_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'all_prayers_page_model.dart';
export 'all_prayers_page_model.dart';

class AllPrayersPageWidget extends StatefulWidget {
  const AllPrayersPageWidget({super.key});

  @override
  State<AllPrayersPageWidget> createState() => _AllPrayersPageWidgetState();
}

class _AllPrayersPageWidgetState extends State<AllPrayersPageWidget> {
  late AllPrayersPageModel _model;
  final _typesCache = getIt<PrayerTypesCache>();
  final _scrollController = ScrollController();
  final List<PrayerTypeStruct> _typeStack = [];

  List<PrayerTypeStruct>? _prayerTypes;
  bool _typesLoading = true;
  bool _typesLoadFailed = false;

  static const double _toolbarHeight = 60.0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AllPrayersPageModel());
    unawaited(_loadTypes());
  }

  Future<void> _loadTypes({bool forceRefresh = false}) async {
    if (mounted) {
      setState(() {
        _typesLoading = true;
        _typesLoadFailed = false;
      });
    }

    try {
      final types = await _typesCache.load(forceRefresh: forceRefresh);
      _prayerTypes = types;
      _typesLoadFailed = types.isEmpty && forceRefresh;
    } catch (_) {
      _typesLoadFailed = true;
    } finally {
      if (mounted) {
        setState(() => _typesLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _model.dispose();
    super.dispose();
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Text(
      label,
      style: FlutterFlowTheme.of(context).labelSmall.override(
            fontFamily: 'Inter',
            color: FlutterFlowTheme.of(context).alternate.withOpacity(0.85),
            letterSpacing: 0.5,
            fontWeight: FontWeight.w600,
          ),
    );
  }

  BoxDecoration _pageGradient(BuildContext context) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          FlutterFlowTheme.of(context).primary,
          const Color(0xFF3C010C),
        ],
        stops: const [0.0, 1.0],
        begin: const AlignmentDirectional(0.0, -1.0),
        end: const AlignmentDirectional(0, 1.0),
      ),
    );
  }

  void _popTypeNav() {
    if (_typeStack.isEmpty) {
      return;
    }
    _typeStack.removeLast();
    safeSetState(() {});
    _scrollToTop();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0.0);
    }
  }

  void _handleBack() {
    if (_typeStack.isNotEmpty) {
      _popTypeNav();
      return;
    }
    context.safePop();
  }

  Widget _buildPageHeader(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final title = _typeStack.isEmpty ? 'Toate rugăciunile' : _typeStack.last.type;

    return Container(
      width: double.infinity,
      decoration: _pageGradient(context),
      child: SizedBox(
        height: _toolbarHeight,
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: theme.alternate,
              ),
              onPressed: _handleBack,
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.titleMedium.override(
                  fontFamily: 'Merriweather',
                  color: theme.alternate,
                  letterSpacing: 0.0,
                ),
              ),
            ),
            const SizedBox(width: 48.0),
          ],
        ),
      ),
    );
  }

  List<IconData> _trailingIconsForPrayer(PrayerStruct prayer) {
    if (prayer.mode == PrayerMode.audioAndText) {
      return const [Icons.chevron_right_rounded];
    }
    return [
      prayer.mode == PrayerMode.audioOnly
          ? Icons.audiotrack_rounded
          : Icons.text_snippet_rounded,
      Icons.chevron_right_rounded,
    ];
  }

  Future<void> _openPrayer(String prayerId) async {
    _typeStack.clear();
    safeSetState(() {});
    await context.pushNamed(
      'RosaryPage',
      queryParameters: {
        'prayerId': serializeParam(prayerId, ParamType.String),
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

  Future<void> _onSubtypeTap(PrayerTypeStruct subtype) async {
    if (subtype.subtypes.isEmpty && subtype.prayers.isEmpty) {
      return;
    }
    if (subtype.subtypes.isEmpty && subtype.prayers.length == 1) {
      await _openPrayer(subtype.prayers.first.id);
      return;
    }
    _typeStack.add(subtype);
    safeSetState(() {});
    _scrollToTop();
  }

  void _enterPrayerType(PrayerTypeStruct type) {
    if (type.subtypes.isEmpty && type.prayers.isEmpty) {
      return;
    }
    if (type.subtypes.isEmpty && type.prayers.length == 1) {
      unawaited(_openPrayer(type.prayers.first.id));
      return;
    }
    _typeStack.add(type);
    safeSetState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToTop());
  }

  Widget _buildSelectedTypeList(BuildContext context) {
    final currentType = _typeStack.last;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (currentType.prayers.isNotEmpty)
          ...currentType.prayers.map(
            (prayer) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: PrayerTypeCardWidget(
                title: prayer.subtitle,
                subtitle: null,
                trailingText: null,
                trailingIcons: _trailingIconsForPrayer(prayer),
                onTap: () => unawaited(_openPrayer(prayer.id)),
              ),
            ),
          ),
        if (currentType.subtypes.isNotEmpty)
          ...currentType.subtypes.map(
            (subtype) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: PrayerTypeCardWidget(
                title: subtype.type,
                subtitle: null,
                trailingText: null,
                trailingIcons: const [Icons.chevron_right_rounded],
                onTap: () => unawaited(_onSubtypeTap(subtype)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCatalogContent(BuildContext context) {
    if (_typesLoading && (_prayerTypes == null || _prayerTypes!.isEmpty)) {
      return Center(
        child: SizedBox(
          width: 24.0,
          height: 24.0,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              FlutterFlowTheme.of(context).alternate,
            ),
          ),
        ),
      );
    }

    if (_typesLoadFailed || _prayerTypes == null || _prayerTypes!.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 12.0),
            child: Text(
              'Rugăciunile nu au putut fi încărcate. Vă rugăm să încercați din nou mai târziu sau verificați conexiunea la internet.',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).labelMedium.override(
                    fontFamily: 'Inter',
                    color: FlutterFlowTheme.of(context).alternate,
                    letterSpacing: 0.0,
                  ),
            ),
          ),
          const SizedBox(height: 12.0),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: FlutterFlowTheme.of(context).alternate,
            ),
            onPressed: () => unawaited(_loadTypes(forceRefresh: true)),
            child: Text(
              'Reîncearcă',
              style: FlutterFlowTheme.of(context).labelMedium.override(
                    fontFamily: 'Inter',
                    color: FlutterFlowTheme.of(context).primary,
                    letterSpacing: 0.0,
                  ),
            ),
          ),
        ],
      );
    }

    if (_typeStack.isNotEmpty) {
      return _buildSelectedTypeList(context);
    }

    final visibleTypes = _prayerTypes!
        .where((type) => type.subtypes.isNotEmpty || type.prayers.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < visibleTypes.length; i++) ...[
          if (i > 0) const SizedBox(height: 12.0),
          Builder(
            builder: (context) {
              final type = visibleTypes[i];
              if (type.subtypes.isEmpty && type.prayers.length == 1) {
                final prayer = type.prayers.first;
                return PrayerTypeCardWidget(
                  title: prayer.subtitle,
                  subtitle: null,
                  trailingText: null,
                  trailingIcons: _trailingIconsForPrayer(prayer),
                  onTap: () => unawaited(_openPrayer(prayer.id)),
                );
              }

              return PrayerTypeCardWidget(
                title: type.type,
                subtitle: null,
                trailingText: null,
                trailingIcons: const [Icons.chevron_right_rounded],
                onTap: () => _enterPrayerType(type),
              );
            },
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _typeStack.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        if (_typeStack.isNotEmpty) {
          _popTypeNav();
        }
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          body: SafeArea(
            top: true,
            bottom: true,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: _pageGradient(context),
              child: Column(
                children: [
                  _buildPageHeader(context),
                  Expanded(
                    child: RefreshIndicator(
                      color: FlutterFlowTheme.of(context).alternate,
                      backgroundColor: FlutterFlowTheme.of(context).primary,
                      onRefresh: () => _loadTypes(forceRefresh: true),
                      child: ListView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          16.0,
                          16.0,
                          16.0,
                          24.0,
                        ),
                        children: [
                          if (_typeStack.isEmpty) ...[
                            _buildSectionLabel(
                              context,
                              'Rugăciuni și cântări',
                            ),
                            const SizedBox(height: 8.0),
                          ],
                          _buildCatalogContent(context),
                        ],
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
