import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:my_prayer/backend/schema/enums/enums.dart';
import 'dart:math' as math;
import 'package:my_prayer/components/download_progress_indicator.dart';
import 'package:my_prayer/custom_code/audio/notifiers/play_button_notifier.dart';
import 'package:my_prayer/custom_code/audio/page_manager.dart';
import 'package:my_prayer/custom_code/download/download_manager.dart';
import 'package:my_prayer/custom_code/download/notifiers/download_state_notifier.dart';
import 'package:my_prayer/custom_code/prayer/prayer_card_lines.dart';
import 'package:my_prayer/custom_code/prayer/prayer_content_cache.dart';
import 'package:my_prayer/custom_code/prayer/prayer_search_index.dart';
import 'package:my_prayer/custom_code/prayer/prayer_types_cache.dart';
import 'package:my_prayer/custom_code/recommended_prayer_picker.dart';
import 'package:my_prayer/service_locator.dart';

import '/components/home_audio_mini_player.dart';
import '/components/prayer_type_card_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/backend/schema/structs/index.dart';
import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_page_model.dart';
export 'home_page_model.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({
    super.key,
  });

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  late HomePageModel _model;

  static const double _toolbarHeight = 60.0;
  static const double _searchBarHeight = 72.0;
  double _headerExpandedHeightCache = 320.0;
  final _downloadManager = getIt<DownloadManager>();
  final _typesCache = getIt<PrayerTypesCache>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _pageManager = getIt<PageManager>();
  final _audioHandler = getIt<AudioHandler>();
  final List<PrayerTypeStruct> _typeStack = [];
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _searchFieldKey = GlobalKey();
  String _searchQuery = '';
  String _debouncedSearchQuery = '';
  Timer? _searchDebounce;
  List<PrayerTypeStruct>? _prayerTypes;
  PrayerSearchIndex? _searchIndex;
  bool _typesLoading = true;
  bool _typesLoadFailed = false;
  bool _searchPinned = false;
  bool _isAutoScrolling = false;

  bool get _searchActive => _searchPinned || _searchQuery.isNotEmpty;

  bool get _showAudioPlayer =>
      !_searchPinned && _searchQuery.isEmpty;

  /// Trailing space at the end of the catalog scroll.
  double get _catalogScrollBottomPadding =>
      _searchActive ? 16.0 : 24.0;

  Future<void> _loadPrayerTypes({bool forceRefresh = false}) async {
    if (mounted) {
      setState(() {
        _typesLoading = true;
        _typesLoadFailed = false;
      });
    }

    try {
      final types = await _typesCache.load(forceRefresh: forceRefresh);
      _prayerTypes = types;
      _searchIndex = PrayerSearchIndex.build(types);
      _typesLoadFailed = types.isEmpty && forceRefresh;
    } catch (_) {
      _typesLoadFailed = true;
    } finally {
      if (mounted) {
        setState(() => _typesLoading = false);
      }
    }
  }

  double _headerExpandedHeight(BuildContext context) {
    return _toolbarHeight + _searchBarHeight;
  }

  static const double _appBarLogoSize = 44.0;
  static const Duration _headerAnimationDuration = Duration(milliseconds: 300);
  static const String _homeLogoHeroTag = 'homeLogo';

  double _fixedLogoSize(BuildContext context) {
    return math.min(210.0, MediaQuery.sizeOf(context).width * 0.55);
  }

  Widget _buildAppLogo(double size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2.5),
      child: Image.asset(
        'assets/images/logo.jpg',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildHeroLogo(double size) {
    return Hero(
      tag: _homeLogoHeroTag,
      child: Material(
        type: MaterialType.transparency,
        child: _buildAppLogo(size),
      ),
    );
  }

  void _popTypeNav() {
    if (_typeStack.isEmpty) {
      return;
    }
    _typeStack.removeLast();
    safeSetState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollHomeToTop());
  }

  BoxDecoration _homeHeaderGradient(BuildContext context) {
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

  Widget _buildToolbarLeading(
    BuildContext context, {
    required bool headerCollapsed,
  }) {
    return ValueListenableBuilder<DownloadState>(
      valueListenable: _downloadManager.downloadStateNotifier,
      builder: (context, downloadState, _) {
        final isDownloading = downloadState == DownloadState.downloading;
        final inTypeNav = _typeStack.isNotEmpty;
        final showToolbarLogo =
            !_searchActive && (headerCollapsed || inTypeNav);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.menu_rounded,
                color: FlutterFlowTheme.of(context).alternate,
              ),
              onPressed: () => scaffoldKey.currentState?.openDrawer(),
            ),
            if (showToolbarLogo)
              Padding(
                padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                child: IgnorePointer(
                  child: _buildHeroLogo(_appBarLogoSize),
                ),
              ),
            if (isDownloading)
              const Padding(
                padding: EdgeInsets.only(right: 4.0),
                child: Hero(
                  tag: 'downloadIndicator',
                  child: DownloadProgressIndicator(),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildHeaderCollapseToggle(
    BuildContext context, {
    required bool isCollapsed,
  }) {
    final color = FlutterFlowTheme.of(context).alternate.withOpacity(0.85);

    return Semantics(
      button: true,
      label: isCollapsed ? 'Extinde antetul' : 'Restrânge antetul',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => FFAppState().toggleHomeHeaderCollapsed(),
          borderRadius: BorderRadius.circular(20.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AnimatedSwitcher(
              duration: _headerAnimationDuration,
              switchInCurve: Curves.easeInOutCubic,
              switchOutCurve: Curves.easeInOutCubic,
              transitionBuilder: (child, animation) {
                return RotationTransition(
                  turns: Tween<double>(begin: 0.85, end: 1.0).animate(
                    animation,
                  ),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: Icon(
                isCollapsed
                    ? Icons.keyboard_arrow_down_rounded
                    : Icons.keyboard_arrow_up_rounded,
                key: ValueKey(isCollapsed),
                size: 22.0,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderTitleAndDate(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AutoSizeText(
          'Congregația Surorilor Maicii Domnului',
          textAlign: TextAlign.center,
          maxLines: 1,
          minFontSize: 12.0,
          style: theme.titleMedium.override(
            fontFamily: 'PlayBall',
            color: theme.alternate,
            fontSize: 24.0,
            letterSpacing: 0.0,
            shadows: const [
              Shadow(
                color: Color(0xFF1C1200),
                offset: Offset(1.0, 1.0),
                blurRadius: 2.0,
              ),
            ],
            useGoogleFonts: false,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          dateTimeFormat(
            'yMMMMEEEEd',
            DateTime.fromMillisecondsSinceEpoch(
              getCurrentTimestamp.millisecondsSinceEpoch,
            ),
            locale: FFLocalizations.of(context).languageCode,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: theme.titleSmall.override(
                fontFamily: 'Inter',
                color: theme.alternate,
                letterSpacing: 0.0,
              ),
        ),
      ],
    );
  }

  Widget _buildHomeHeader(
    BuildContext context, {
    required bool headerCollapsed,
  }) {
    final inTypeNav = _typeStack.isNotEmpty;
    final showCollapseToggle = !inTypeNav && !_searchActive;
    final isCollapsed = headerCollapsed && !inTypeNav;
    final showExpandedLogo = !isCollapsed && !inTypeNav;

    return Container(
      width: double.infinity,
      decoration: _homeHeaderGradient(context),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: _headerTextScaler(context),
        ),
        child: AnimatedSize(
          duration: _headerAnimationDuration,
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: _toolbarHeight,
                child: Row(
                  children: [
                    _buildToolbarLeading(
                      context,
                      headerCollapsed: headerCollapsed,
                    ),
                    const Spacer(),
                    ..._buildToolbarActions(context, includeSearch: true),
                  ],
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      16.0,
                      0.0,
                      16.0,
                      showCollapseToggle ? 28.0 : 16.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeaderTitleAndDate(context),
                        AnimatedSize(
                          duration: _headerAnimationDuration,
                          curve: Curves.easeInOutCubic,
                          alignment: Alignment.topCenter,
                          clipBehavior: Clip.none,
                          child: showExpandedLogo
                              ? Column(
                                  key: const ValueKey('home-logo-expanded'),
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(height: 12.0),
                                    _buildHeroLogo(_fixedLogoSize(context)),
                                  ],
                                )
                              : const SizedBox(
                                  key: ValueKey('home-logo-collapsed'),
                                  width: double.infinity,
                                ),
                        ),
                      ],
                    ),
                  ),
                  if (showCollapseToggle)
                    Positioned(
                      right: 12.0,
                      bottom: 4.0,
                      child: _buildHeaderCollapseToggle(
                        context,
                        isCollapsed: isCollapsed,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const _drawerTransition = TransitionInfo(
    hasTransition: true,
    transitionType: PageTransitionType.fade,
    duration: Duration(milliseconds: 250),
  );

  Future<void> _openDrawerPage(String routeName) async {
    Navigator.of(context).pop();
    await context.pushNamed(
      routeName,
      extra: <String, dynamic>{
        kTransitionInfoKey: _drawerTransition,
      },
    );
  }

  Widget _drawerNavTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String routeName,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: FlutterFlowTheme.of(context).primary,
      ),
      title: Text(
        title,
        style: FlutterFlowTheme.of(context).bodyLarge.override(
              fontFamily: 'Inter',
              color: FlutterFlowTheme.of(context).primaryText,
              letterSpacing: 0.0,
            ),
      ),
      onTap: () => unawaited(_openDrawerPage(routeName)),
    );
  }

  List<Widget> _buildToolbarActions(
    BuildContext context, {
    required bool includeSearch,
  }) {
    return [
      if (includeSearch)
        FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 8.0,
          buttonSize: 48.0,
          icon: Icon(
            Icons.search_rounded,
            color: FlutterFlowTheme.of(context).alternate,
            size: 24.0,
          ),
          onPressed: _enterSearch,
        ),
    ];
  }

  Widget _buildTypeNavBackRow(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: _popTypeNav,
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Icon(Icons.arrow_back_rounded, color: theme.alternate, size: 24.0),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  _typeStack.last.type,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.titleMedium.override(
                    fontFamily: 'Merriweather',
                    color: theme.alternate,
                    letterSpacing: 0.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedTypeList(BuildContext context) {
    final currentType = _typeStack.last;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTypeNavBackRow(context),
        if (currentType.prayers.isNotEmpty)
          ...currentType.prayers.map(
            (prayer) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: PrayerTypeCardWidget(
                title: prayer.subtitle,
                trailingText: null,
                trailingIcons: prayer.mode != PrayerMode.audioAndText
                    ? [
                        prayer.mode == PrayerMode.audioOnly
                            ? Icons.audiotrack_rounded
                            : Icons.format_size_rounded,
                        Icons.chevron_right_rounded,
                      ]
                    : const [Icons.chevron_right_rounded],
                onTap: () => _openPrayerFromTypeNav(prayer.id),
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
                onTap: () => _onSubtypeTap(subtype),
              ),
            ),
          ),
      ],
    );
  }

  void _scrollHomeToTop() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0.0);
    }
  }

  Future<void> _openPrayerFromTypeNav(String prayerId) async {
    _typeStack.clear();
    safeSetState(() {});
    getIt<PrayerContentCache>().prefetch(prayerId);
    await _prepareToOpenPrayer();
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
      await _openPrayerFromTypeNav(subtype.prayers.first.id);
      return;
    }
    _typeStack.add(subtype);
    safeSetState(() {});
    _scrollHomeToTop();
  }

  void _enterPrayerType(PrayerTypeStruct type) {
    if (type.subtypes.isEmpty && type.prayers.isEmpty) {
      return;
    }
    _typeStack.add(type);
    safeSetState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollHomeToTop());
  }

  Widget _buildSearchSliverAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      pinned: true,
      toolbarHeight: _toolbarHeight,
      expandedHeight: _headerExpandedHeightCache,
      elevation: 0.0,
      automaticallyImplyLeading: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(_searchBarHeight),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 16.0),
          child: _buildSearchField(context),
        ),
      ),
      leading: _buildToolbarLeading(
        context,
        headerCollapsed: FFAppState().homeHeaderCollapsed,
      ),
      iconTheme: IconThemeData(color: FlutterFlowTheme.of(context).alternate),
      actions: _buildToolbarActions(context, includeSearch: false),
      flexibleSpace: Container(
        decoration: _homeHeaderGradient(context),
      ),
    );
  }

  TextScaler _headerTextScaler(BuildContext context) {
    return TextScaler.linear(
      MediaQuery.textScalerOf(context).scale(1.0).clamp(1.0, 1.3),
    );
  }

  Future<void> _openCurrentPrayerWithAudio() async {
    _typeStack.clear();
    safeSetState(() {});
    await context.pushNamed(
      'RosaryPage',
      queryParameters: {
        'prayerId': serializeParam(
          valueOrDefault<String>(FFAppState().currentPrayerId, ''),
          ParamType.String,
        ),
        'continueAudio': serializeParam(true, ParamType.bool).toString(),
        'page': serializeParam(
          valueOrDefault<int>(_pageManager.trackIndexNotifier.value, 0),
          ParamType.int,
        ).toString(),
        'initialAudioTime': serializeParam(
          _pageManager.currentProgressNotifier.value.inSeconds,
          ParamType.int,
        ).toString(),
      }.withoutNulls,
    );
  }

  Future<void> _closeAudioPlayer() async {
    await _pageManager.stop();
    await _pageManager.clearQueue();
    FFAppState().currentPrayerId = '';
    safeSetState(() {});
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());
    _model.recommendedPrayerFuture = fetchRecommendedPrayer().then((result) {
      final prayerId = result?.prayer.id;
      if (prayerId != null && prayerId.isNotEmpty) {
        getIt<PrayerContentCache>().prefetch(prayerId);
      }
      return result;
    });
    unawaited(_loadPrayerTypes());
    _scrollController.addListener(() {
      if (!_searchActive || !_scrollController.hasClients || _isAutoScrolling) {
        return;
      }
      final minHeight =
          _toolbarHeight + (_searchActive ? _searchBarHeight : 0.0);
      final targetOffset = _headerExpandedHeightCache - minHeight;
      final maxOffset = _scrollController.position.maxScrollExtent;
      final clampedTarget = math.min(targetOffset, maxOffset);
      if (_scrollController.offset < clampedTarget - 1.0) {
        _isAutoScrolling = true;
        _scrollController.jumpTo(clampedTarget);
        _isAutoScrolling = false;
      }
    });
    _searchFocusNode.addListener(() {
      final pinned = _searchFocusNode.hasFocus;
      if (pinned) {
        if (!_searchPinned || _typeStack.isNotEmpty) {
          _typeStack.clear();
          _searchPinned = true;
          safeSetState(() {});
        }
      } else if (_searchPinned && _searchQuery.isEmpty) {
        _searchPinned = false;
        safeSetState(() {});
      }
      if (pinned && _scrollController.hasClients && !_isAutoScrolling) {
        _isAutoScrolling = true;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted || !_scrollController.hasClients) {
            _isAutoScrolling = false;
            return;
          }
          if (!_searchFocusNode.hasFocus) {
            _searchFocusNode.requestFocus();
          }
          final minHeight =
              _toolbarHeight + (_searchActive ? _searchBarHeight : 0.0);
          final targetOffset = _headerExpandedHeightCache - minHeight;
          final maxOffset = _scrollController.position.maxScrollExtent;
          final clampedTarget = math.min(targetOffset, maxOffset);
          if ((_scrollController.offset - clampedTarget).abs() < 2.0) {
            _isAutoScrolling = false;
            return;
          }
          await _scrollController.animateTo(
            clampedTarget,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOut,
          );
          _isAutoScrolling = false;
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      safeSetState(() {});
      if (FFAppState().isFirstTime && mounted) {
        context.pushNamed('OnboardingPage');
      }
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _headerExpandedHeightCache = _headerExpandedHeight(context);

    return PopScope(
      canPop: !_searchActive &&
          _searchFocusNode.hasFocus == false &&
          _typeStack.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        if (_searchActive || _searchFocusNode.hasFocus) {
          _exitSearch();
          return;
        }
        if (_typeStack.isNotEmpty) {
          _popTypeNav();
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (details) {
          final box =
              _searchFieldKey.currentContext?.findRenderObject() as RenderBox?;
          if (box != null) {
            final topLeft = box.localToGlobal(Offset.zero);
            final rect = topLeft & box.size;
            if (rect.contains(details.globalPosition)) {
              return;
            }
          }
          if (_searchActive || _searchFocusNode.hasFocus) {
            _exitSearch();
            return;
          }
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primary,
          resizeToAvoidBottomInset: false,
          drawer: Drawer(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            child: SafeArea(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          FlutterFlowTheme.of(context).primary,
                          const Color(0xFF3C010C)
                        ],
                        stops: const [0.0, 1.0],
                        begin: const AlignmentDirectional(0.0, -1.0),
                        end: const AlignmentDirectional(0, 1.0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          16.0, 24.0, 16.0, 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: Image.asset(
                                  'assets/images/logo.jpg',
                                  width: 56.0,
                                  height: 56.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Rugăciuni și cântări',
                                      style: FlutterFlowTheme.of(context)
                                          .titleLarge
                                          .override(
                                            fontFamily: 'Merriweather',
                                            color: FlutterFlowTheme.of(context)
                                                .alternate,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      'Congregația Surorilor Maicii Domnului',
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            fontFamily: 'Inter',
                                            color:
                                                FlutterFlowTheme.of(context)
                                                    .alternate,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w300,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 1.0,
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                  ),
                  const SizedBox(height: 8.0),
                  _drawerNavTile(
                    context: context,
                    icon: Icons.calendar_today_rounded,
                    title: 'Calendar',
                    routeName: 'CalendarPage',
                  ),
                  if (!kIsWeb)
                    _drawerNavTile(
                      context: context,
                      icon: Icons.notifications_outlined,
                      title: 'Memento',
                      routeName: 'RemindersPage',
                    ),
                  if (!kIsWeb)
                    _drawerNavTile(
                      context: context,
                      icon: Icons.download_rounded,
                      title: 'Descărcări',
                      routeName: 'DownloadedPrayersPage',
                    ),
                  _drawerNavTile(
                    context: context,
                    icon: Icons.menu_book_rounded,
                    title: 'Jurnal',
                    routeName: 'PrayerJournalPage',
                  ),
                  _drawerNavTile(
                    context: context,
                    icon: Icons.favorite_rounded,
                    title: 'Favorite',
                    routeName: 'FavoritePrayersPage',
                  ),
                  Divider(
                    height: 1.0,
                    indent: 16.0,
                    endIndent: 16.0,
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                  ),
                  const Spacer(),
                  _drawerNavTile(
                    context: context,
                    icon: Icons.settings_rounded,
                    title: 'Setări',
                    routeName: 'SettingsPage',
                  ),
                ],
              ),
            ),
          ),
          body: SafeArea(
            top: true,
            bottom: true,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    FlutterFlowTheme.of(context).primary,
                    const Color(0xFF3C010C)
                  ],
                  stops: const [0.0, 1.0],
                  begin: const AlignmentDirectional(0.0, -1.0),
                  end: const AlignmentDirectional(0, 1.0),
                ),
              ),
              child: Column(
                children: [
                  if (!_searchActive)
                    Selector<FFAppState, bool>(
                      selector: (_, state) => state.homeHeaderCollapsed,
                      builder: (context, headerCollapsed, _) {
                        return _buildHomeHeader(
                          context,
                          headerCollapsed: headerCollapsed,
                        );
                      },
                    ),
                  Expanded(
                    child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      if (_searchActive) _buildSearchSliverAppBar(context),
                      Selector<FFAppState, SavedPrayerDataStruct>(
                        selector: (_, state) => state.savedPrayer,
                        builder: (context, savedPrayer, _) {
                          final showBookmark = !_searchActive &&
                              _typeStack.isEmpty &&
                              savedPrayer.prayer != null &&
                              savedPrayer.prayer!.id.isNotEmpty;
                          if (!showBookmark) {
                            return const SliverToBoxAdapter(
                              child: SizedBox.shrink(),
                            );
                          }
                          final prayer = savedPrayer.prayer!;
                          final savedCard = savedPrayerCardContent(savedPrayer);

                          return SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                16.0,
                                8.0,
                                16.0,
                                0.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildHomeSectionLabel(
                                    context,
                                    'Continuă de unde ai rămas',
                                  ),
                                  const SizedBox(height: 8.0),
                                  PrayerTypeCardWidget(
                                    title: savedCard.$1,
                                    subtitle: savedCard.$2,
                                    leadingImageUrl: savedCard.$3,
                                    trailingText: null,
                                    trailingIcons:
                                        _trailingIconsForPrayer(prayer),
                                    onTap: () => unawaited(
                                      _openSavedPrayer(context, savedPrayer),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      if (!_searchActive && _typeStack.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                              16.0,
                              8.0,
                              16.0,
                              0.0,
                            ),
                            child: _buildHomeSectionLabel(
                              context,
                              'Rugăciuni și cântări',
                            ),
                          ),
                        ),
                      SliverPadding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          16.0,
                          8.0,
                          16.0,
                          0.0,
                        ),
                        sliver: _buildPrayerTypesSliver(context),
                      ),
                      SliverToBoxAdapter(
                        child: _buildRecommendedPrayerSection(context),
                      ),
                      Selector<FFAppState, List<PrayerStruct>>(
                        selector: (_, state) => state.favoritePrayers,
                        builder: (context, favoritePrayers, _) {
                          return SliverToBoxAdapter(
                            child: _buildFavoritePrayersSection(
                              context,
                              favoritePrayers: favoritePrayers,
                            ),
                          );
                        },
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: _catalogScrollBottomPadding,
                        ),
                      ),
                    ],
                    ),
                  ),
                  Selector<FFAppState, String>(
                    selector: (_, state) => state.currentPrayerId,
                    builder: (context, currentPrayerId, _) {
                      if (!_showAudioPlayer || currentPrayerId.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          HomeAudioMiniPlayer.homeScreenMarginVertical / 2,
                          16.0,
                          HomeAudioMiniPlayer.homeScreenMarginVertical / 2,
                        ),
                        child: HomeAudioMiniPlayer(
                          pageManager: _pageManager,
                          audioHandler: _audioHandler,
                          onClose: _closeAudioPlayer,
                          onOpenPrayer: _openCurrentPrayerWithAudio,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ));
  }

  Widget _buildSearchField(BuildContext context) {
    final isActive = _searchPinned || _searchFocusNode.hasFocus;
    return TextFormField(
      key: _searchFieldKey,
      controller: _searchController,
      focusNode: _searchFocusNode,
      onChanged: (value) {
        _searchQuery = value;
        _searchDebounce?.cancel();
        _searchDebounce = Timer(const Duration(milliseconds: 250), () {
          if (mounted) {
            setState(() => _debouncedSearchQuery = value);
          }
        });
        safeSetState(() {});
      },
      style: FlutterFlowTheme.of(context).bodyMedium.override(
            fontFamily: 'Inter',
            color: isActive
                ? FlutterFlowTheme.of(context).primary
                : FlutterFlowTheme.of(context).alternate,
            letterSpacing: 0.0,
          ),
      decoration: InputDecoration(
        hintText: 'Caută rugăciuni și cântări',
        hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
              fontFamily: 'Inter',
              color: isActive
                  ? FlutterFlowTheme.of(context).secondaryText
                  : FlutterFlowTheme.of(context).alternate.withOpacity(0.6),
              letterSpacing: 0.0,
            ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: isActive
              ? FlutterFlowTheme.of(context).secondaryText
              : FlutterFlowTheme.of(context).alternate.withOpacity(0.6),
          size: 20.0,
        ),
        suffixIcon: (_searchPinned ||
                _searchQuery.isNotEmpty ||
                _searchFocusNode.hasFocus)
            ? IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: isActive
                      ? FlutterFlowTheme.of(context).secondaryText
                      : FlutterFlowTheme.of(context).alternate.withOpacity(0.8),
                  size: 20.0,
                ),
                onPressed: _exitSearch,
              )
            : null,
        filled: true,
        fillColor: isActive
            ? FlutterFlowTheme.of(context).alternate
            : FlutterFlowTheme.of(context).primary.withOpacity(0.3),
        focusColor: FlutterFlowTheme.of(context).alternate,
        hoverColor: FlutterFlowTheme.of(context).alternate,
        contentPadding:
            const EdgeInsetsDirectional.fromSTEB(12.0, 14.0, 12.0, 14.0),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isActive
                ? FlutterFlowTheme.of(context).secondaryBackground
                : FlutterFlowTheme.of(context).alternate.withOpacity(0.2),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: FlutterFlowTheme.of(context).primary,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: FlutterFlowTheme.of(context).error,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: FlutterFlowTheme.of(context).error,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }

  Widget _buildPrayerTypesSliver(BuildContext context) {
    if (_typesLoading && (_prayerTypes == null || _prayerTypes!.isEmpty)) {
      return SliverToBoxAdapter(
        child: Center(
          child: SizedBox(
            width: 24.0,
            height: 24.0,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                FlutterFlowTheme.of(context).primary,
              ),
            ),
          ),
        ),
      );
    }

    if (_typesLoadFailed || _prayerTypes == null || _prayerTypes!.isEmpty) {
      return SliverToBoxAdapter(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 12.0),
              child: Text(
                'Rugăciunile nu au putut fi încărcate. Vă rugăm să încercați din nou mai târziu sau verificați conexiunea la internet.',
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
              onPressed: () => unawaited(_loadPrayerTypes(forceRefresh: true)),
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
        ),
      );
    }

    if (_typeStack.isNotEmpty && !_searchActive) {
      return SliverToBoxAdapter(child: _buildSelectedTypeList(context));
    }

    final query = _debouncedSearchQuery.toLowerCase().trim();
    if (query.isNotEmpty) {
      final searchResults = _searchIndex?.search(query) ?? const [];
      if (searchResults.isEmpty) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsetsDirectional.only(top: 12.0),
            child: Text(
              'Nu există rugăciuni cu acest nume.',
              style: FlutterFlowTheme.of(context).labelMedium.override(
                    fontFamily: 'Inter',
                    color: FlutterFlowTheme.of(context).alternate,
                    letterSpacing: 0.0,
                  ),
            ),
          ),
        );
      }

      return SliverList.separated(
        itemCount: searchResults.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12.0),
        itemBuilder: (context, index) {
          final result = searchResults[index];
          return _buildSearchResultCard(context, result);
        },
      );
    }

    final visibleTypes = _prayerTypes!
        .where((type) => type.subtypes.isNotEmpty || type.prayers.isNotEmpty)
        .toList();

    return SliverList.separated(
      itemCount: visibleTypes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12.0),
      itemBuilder: (context, index) {
        final type = visibleTypes[index];
        if (type.subtypes.isEmpty && type.prayers.length == 1) {
          final prayer = type.prayers.first;
          return PrayerTypeCardWidget(
            title: prayer.subtitle,
            subtitle: null,
            trailingText: null,
            trailingIcons: _trailingIconsForPrayer(prayer),
            onTap: () => _openPrayer(context, prayer.id),
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
    );
  }

  Widget _buildHomeSectionLabel(BuildContext context, String label) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        label.toUpperCase(),
        textAlign: TextAlign.start,
        style: FlutterFlowTheme.of(context).labelSmall.override(
              fontFamily: 'Inter',
              color: FlutterFlowTheme.of(context).alternate.withOpacity(0.85),
              letterSpacing: 0.5,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  (String, String?) _prayerCardTitleAndSubtitle(PrayerStruct prayer) {
    final cardTitle =
        prayer.title.isNotEmpty ? prayer.title : prayer.subtitle;
    final cardSubtitle = prayer.title.isNotEmpty &&
            prayer.subtitle.isNotEmpty &&
            prayer.subtitle != cardTitle
        ? prayer.subtitle
        : null;
    return (cardTitle, cardSubtitle);
  }

  Future<void> _openSavedPrayer(
    BuildContext context,
    SavedPrayerDataStruct savedPrayer,
  ) async {
    final prayerId = savedPrayer.prayer?.id;
    final page = savedPrayer.page;

    if (prayerId == null || prayerId.isEmpty) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: FlutterFlowTheme.of(context).alternate,
          content: Text(
            'Rugăciunea salvată nu este validă. Vă rugăm să salvați o rugăciune din nou.',
            style: FlutterFlowTheme.of(context).labelMedium.override(
                  fontFamily: 'Inter',
                  color: FlutterFlowTheme.of(context).primary,
                  letterSpacing: 0.0,
                ),
          ),
        ),
      );
      return;
    }

    _typeStack.clear();
    safeSetState(() {});

    getIt<PrayerContentCache>().prefetch(prayerId);
    await _prepareToOpenPrayer();

    await context.pushNamed(
      'RosaryPage',
      queryParameters: {
        'prayerId': serializeParam(
          prayerId,
          ParamType.String,
        ).toString(),
        'page': serializeParam(
          valueOrDefault<int>(page, 0),
          ParamType.int,
        ).toString(),
      }.withoutNulls,
      extra: <String, dynamic>{
        kTransitionInfoKey: const TransitionInfo(
          hasTransition: true,
          transitionType: PageTransitionType.fade,
          duration: Duration(milliseconds: 250),
        ),
      },
    );

    if (!context.mounted) {
      return;
    }
    FFAppState().deleteSavedPrayer();
    FFAppState().savedPrayer = SavedPrayerDataStruct();
  }

  Widget _buildFavoritePrayersSection(
    BuildContext context, {
    required List<PrayerStruct> favoritePrayers,
  }) {
    if (_searchActive || _typeStack.isNotEmpty || favoritePrayers.isEmpty) {
      return const SizedBox.shrink();
    }

    final preview = favoritePrayers.take(3).toList();
    for (final prayer in preview) {
      if (prayer.id.isNotEmpty) {
        getIt<PrayerContentCache>().prefetch(prayer.id);
      }
    }

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHomeSectionLabel(
            context,
            'Favorite',
          ),
          const SizedBox(height: 8.0),
          ...List.generate(preview.length, (index) {
            final prayer = preview[index];
            final cardLines = _prayerCardTitleAndSubtitle(prayer);
            return Padding(
              padding: EdgeInsets.only(top: index > 0 ? 12.0 : 0.0),
              child: PrayerTypeCardWidget(
                title: cardLines.$1,
                subtitle: cardLines.$2,
                trailingText: null,
                trailingIcons: _trailingIconsForPrayer(prayer),
                onTap: () => unawaited(_openPrayer(context, prayer.id)),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecommendedPrayerSection(BuildContext context) {
    if (_searchActive || _typeStack.isNotEmpty) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<RecommendedPrayerResult?>(
      future: _model.recommendedPrayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 0.0),
            child: Container(
              height: 72.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).alternate,
                borderRadius: BorderRadius.circular(16.0),
              ),
              alignment: Alignment.center,
              child: SizedBox(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            ),
          );
        }

        final recommendation = snapshot.data;
        if (recommendation == null) {
          return Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHomeSectionLabel(
                  context,
                  'Pentru astăzi',
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Nicio recomandare pentru astăzi. Deschide calendarul pentru rugăciunile zilei.',
                  style: FlutterFlowTheme.of(context).labelMedium.override(
                        fontFamily: 'Inter',
                        color: FlutterFlowTheme.of(context).alternate,
                        letterSpacing: 0.0,
                      ),
                ),
                const SizedBox(height: 8.0),
                TextButton.icon(
                  onPressed: () => unawaited(
                    context.pushNamed(
                      'CalendarPage',
                      extra: <String, dynamic>{
                        kTransitionInfoKey: _drawerTransition,
                      },
                    ),
                  ),
                  icon: Icon(
                    Icons.calendar_today_rounded,
                    size: 18.0,
                    color: FlutterFlowTheme.of(context).alternate,
                  ),
                  label: Text(
                    'Deschide calendarul',
                    style: FlutterFlowTheme.of(context).labelMedium.override(
                          fontFamily: 'Inter',
                          color: FlutterFlowTheme.of(context).alternate,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          );
        }

        final prayer = recommendation.prayer;
        final cardLines = _prayerCardTitleAndSubtitle(prayer);

        return Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHomeSectionLabel(
                context,
                'Pentru astăzi',
              ),
              const SizedBox(height: 8.0),
              PrayerTypeCardWidget(
                title: cardLines.$1,
                subtitle: cardLines.$2,
                trailingText: null,
                trailingIcons: _trailingIconsForPrayer(prayer),
                onTap: () async {
                  _typeStack.clear();
                  safeSetState(() {});
                  await _openPrayer(context, prayer.id);
                },
              ),
            ],
          ),
        );
      },
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

  Widget _buildSearchResultCard(BuildContext context, PrayerSearchEntry result) {
    final subtitle = result.displaySubtitle;
    return PrayerTypeCardWidget(
      title: result.prayer.subtitle.isNotEmpty
          ? result.prayer.subtitle
          : result.prayer.title,
      subtitle: subtitle.isEmpty ? null : subtitle,
      trailingText: null,
      trailingIcons: _trailingIconsForPrayer(result.prayer),
      onTap: () async {
        _typeStack.clear();
        _exitSearch();
        safeSetState(() {});
        await _openPrayer(context, result.prayer.id);
      },
    );
  }

  Future<void> _prepareToOpenPrayer() async {
    if (FFAppState().currentPrayerId.isEmpty &&
        !_pageManager.hasActiveQueue &&
        _pageManager.playButtonNotifier.value != ButtonState.playing) {
      return;
    }

    await _pageManager.stop();
    if (_pageManager.hasActiveQueue) {
      await _pageManager.clearQueue();
    }
    FFAppState().currentPrayerId = '';
  }

  Future<void> _openPrayer(BuildContext context, String prayerId) async {
    getIt<PrayerContentCache>().prefetch(prayerId);
    await _prepareToOpenPrayer();
    await context.pushNamed(
      'RosaryPage',
      queryParameters: {
        'prayerId': serializeParam(
          prayerId,
          ParamType.String,
        ),
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

  void _exitSearch() {
    _searchController.clear();
    _searchQuery = '';
    _debouncedSearchQuery = '';
    _searchDebounce?.cancel();
    _searchPinned = false;
    _searchFocusNode.unfocus();
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    }
    safeSetState(() {});
  }

  void _enterSearch() {
    _typeStack.clear();
    _searchPinned = true;
    safeSetState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
      _scrollHomeToTop();
    });
  }
}
