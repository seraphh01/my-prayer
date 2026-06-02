import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:my_prayer/backend/schema/enums/enums.dart';
import 'dart:math' as math;
import 'package:my_prayer/components/download_progress_indicator.dart';
import 'package:my_prayer/custom_code/audio/page_manager.dart';
import 'package:my_prayer/custom_code/download/download_manager.dart';
import 'package:my_prayer/custom_code/download/notifiers/download_state_notifier.dart';
import 'package:my_prayer/service_locator.dart';

import '/backend/api_requests/api_calls.dart';
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

class _PrayerSearchItem {
  _PrayerSearchItem({
    required this.prayer,
    required this.path,
  });

  final PrayerStruct prayer;
  final String path;
}

class _HomePageWidgetState extends State<HomePageWidget> {
  late HomePageModel _model;

  static const double _toolbarHeight = 60.0;
  static const double _searchBarHeight = 72.0;
  double _headerExpandedHeightCache = 320.0;
 final _downloadManager = getIt<DownloadManager>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _pageManager = getIt<PageManager>();
  final _audioHandler = getIt<AudioHandler>();
  final List<PrayerTypeStruct> _typeStack = [];
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _searchFieldKey = GlobalKey();
  String _searchQuery = '';
  bool _searchPinned = false;
  bool _isAutoScrolling = false;

  bool get _searchActive => _searchPinned || _searchQuery.isNotEmpty;

  bool get _showAudioPlayer =>
      FFAppState().currentPrayerId.isNotEmpty &&
      !_searchPinned &&
      _searchQuery.isEmpty;

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

  Widget _buildToolbarLeading(BuildContext context) {
    if (_downloadManager.downloadStateNotifier.value ==
        DownloadState.downloading) {
      return const Hero(
        tag: 'downloadIndicator',
        child: DownloadProgressIndicator(),
      );
    }
    return IconButton(
      icon: Icon(
        Icons.menu_rounded,
        color: FlutterFlowTheme.of(context).alternate,
      ),
      onPressed: () => scaffoldKey.currentState?.openDrawer(),
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
      FlutterFlowIconButton(
        borderColor: Colors.transparent,
        borderRadius: 8.0,
        buttonSize: 48.0,
        icon: Icon(
          Icons.settings_rounded,
          color: FlutterFlowTheme.of(context).alternate,
          size: 24.0,
        ),
        onPressed: () async {
          context.pushNamed(
            'SettingsPage',
            extra: <String, dynamic>{
              kTransitionInfoKey: const TransitionInfo(
                hasTransition: true,
                transitionType: PageTransitionType.fade,
                duration: Duration(milliseconds: 250),
              ),
            },
          );
        },
      ),
    ];
  }

  Widget _buildHomeHeader(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final inTypeNav = _typeStack.isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: _homeHeaderGradient(context),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: _headerTextScaler(context),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: _toolbarHeight,
              child: Row(
                children: [
                  _buildToolbarLeading(context),
                  AnimatedSize(
                    duration: _headerAnimationDuration,
                    curve: Curves.easeInOutCubic,
                    alignment: Alignment.centerLeft,
                    clipBehavior: Clip.none,
                    child: inTypeNav
                        ? Row(
                            key: const ValueKey('app-bar-logo'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(width: 4.0),
                              _buildHeroLogo(_appBarLogoSize),
                            ],
                          )
                        : const SizedBox(
                            key: ValueKey('app-bar-logo-spacer'),
                            width: 0.0,
                            height: _appBarLogoSize,
                          ),
                  ),
                  const Spacer(),
                  ..._buildToolbarActions(context, includeSearch: true),
                ],
              ),
            ),
            AnimatedSize(
              duration: _headerAnimationDuration,
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16.0,
                  0.0,
                  16.0,
                  inTypeNav ? 12.0 : 16.0,
                ),
                child: Column(
                  key: ValueKey(inTypeNav ? 'header-compact' : 'header-expanded'),
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
                    AnimatedSize(
                      duration: _headerAnimationDuration,
                      curve: Curves.easeInOutCubic,
                      alignment: Alignment.topCenter,
                      clipBehavior: Clip.none,
                      child: inTypeNav
                          ? const SizedBox(width: double.infinity)
                          : Column(
                              key: const ValueKey('home-logo-expanded'),
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 12.0),
                                _buildHeroLogo(_fixedLogoSize(context)),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
      leading: _buildToolbarLeading(context),
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
          valueOrDefault<double>(
            _pageManager.currentProgressNotifier.value.inSeconds.toDouble(),
            0.0,
          ),
          ParamType.double,
        ).toString(),
      }.withoutNulls,
    );
  }

  Future<void> _closeAudioPlayer() async {
    _pageManager.stop();
    await _pageManager.clearQueue();
    FFAppState().currentPrayerId = '';
    safeSetState(() {});
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());
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
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    _headerExpandedHeightCache = _headerExpandedHeight(context);

    return WillPopScope(
      onWillPop: () async {
        if (_searchActive || _searchFocusNode.hasFocus) {
          _exitSearch();
          return false;
        }
        if (_typeStack.isNotEmpty) {
          _popTypeNav();
          return false;
        }
        return true;
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
                  ListTile(
                    leading: Icon(
                      Icons.calendar_today_rounded,
                      color: FlutterFlowTheme.of(context).primary,
                    ),
                    title: Text(
                      'Calendar',
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily: 'Inter',
                            color: FlutterFlowTheme.of(context).primaryText,
                            letterSpacing: 0.0,
                          ),
                    ),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await context.pushNamed(
                        'CalendarPage',
                        extra: <String, dynamic>{
                          kTransitionInfoKey: const TransitionInfo(
                            hasTransition: true,
                            transitionType: PageTransitionType.fade,
                            duration: Duration(milliseconds: 250),
                          ),
                        },
                      );
                    },
                  ),
                  if (!kIsWeb)
                    ListTile(
                      leading: Icon(
                        Icons.notifications_outlined,
                        color: FlutterFlowTheme.of(context).primary,
                      ),
                      title: Text(
                        'Memento rugăciune',
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                              fontFamily: 'Inter',
                              color: FlutterFlowTheme.of(context).primaryText,
                              letterSpacing: 0.0,
                            ),
                      ),
                      onTap: () async {
                        Navigator.of(context).pop();
                        await context.pushNamed(
                          'RemindersPage',
                          extra: <String, dynamic>{
                            kTransitionInfoKey: const TransitionInfo(
                              hasTransition: true,
                              transitionType: PageTransitionType.fade,
                              duration: Duration(milliseconds: 250),
                            ),
                          },
                        );
                      },
                    ),
                  if (!kIsWeb)
                    ListTile(
                      leading: Icon(
                        Icons.download_rounded,
                        color: FlutterFlowTheme.of(context).primary,
                      ),
                      title: Text(
                        'Descărcate',
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                              fontFamily: 'Inter',
                              color: FlutterFlowTheme.of(context).primaryText,
                              letterSpacing: 0.0,
                            ),
                      ),
                      onTap: () async {
                        Navigator.of(context).pop();
                        await context.pushNamed(
                          'DownloadedPrayersPage',
                          extra: <String, dynamic>{
                            kTransitionInfoKey: const TransitionInfo(
                              hasTransition: true,
                              transitionType: PageTransitionType.fade,
                              duration: Duration(milliseconds: 250),
                            ),
                          },
                        );
                      },
                    ),
                  ListTile(
                    leading: Icon(
                      Icons.menu_book_rounded,
                      color: FlutterFlowTheme.of(context).primary,
                    ),
                    title: Text(
                      'Jurnal de rugăciune',
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily: 'Inter',
                            color: FlutterFlowTheme.of(context).primaryText,
                            letterSpacing: 0.0,
                          ),
                    ),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await context.pushNamed('PrayerJournalPage');
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.favorite_rounded,
                      color: FlutterFlowTheme.of(context).primary,
                    ),
                    title: Text(
                      'Favorite',
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily: 'Inter',
                            color: FlutterFlowTheme.of(context).primaryText,
                            letterSpacing: 0.0,
                          ),
                    ),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await context.pushNamed(
                        'FavoritePrayersPage',
                        extra: <String, dynamic>{
                          kTransitionInfoKey: const TransitionInfo(
                            hasTransition: true,
                            transitionType: PageTransitionType.fade,
                            duration: Duration(milliseconds: 250),
                          ),
                        },
                      );
                    },
                  ),
                  Divider(
                    height: 1.0,
                    indent: 16.0,
                    endIndent: 16.0,
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                  ),
                  const Spacer(),
                  ListTile(
                    leading: Icon(
                      Icons.settings_rounded,
                      color: FlutterFlowTheme.of(context).primary,
                    ),
                    title: Text(
                      'Setări',
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily: 'Inter',
                            color: FlutterFlowTheme.of(context).primaryText,
                            letterSpacing: 0.0,
                          ),
                    ),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await context.pushNamed(
                        'SettingsPage',
                        extra: <String, dynamic>{
                          kTransitionInfoKey: const TransitionInfo(
                            hasTransition: true,
                            transitionType: PageTransitionType.fade,
                            duration: Duration(milliseconds: 250),
                          ),
                        },
                      );
                    },
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
                  if (!_searchActive) _buildHomeHeader(context),
                  Expanded(
                    child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      if (_searchActive) _buildSearchSliverAppBar(context),
                                            SliverToBoxAdapter(
                        child: Visibility(
                          visible: valueOrDefault<bool>(
                            !_searchActive &&
                                _typeStack.isEmpty &&
                                (FFAppState().savedPrayer.prayer != null) &&
                                (FFAppState().savedPrayer.prayer?.id != '') &&
                                (FFAppState().currentPrayerId.isEmpty),
                            false,
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16.0, 8.0, 16.0, 0.0),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                var prayerId =
                                    FFAppState().savedPrayer.prayer?.id;
                                var page = FFAppState().savedPrayer.page;

                                FFAppState().deleteSavedPrayer();
                                FFAppState().savedPrayer = SavedPrayerDataStruct();

                                safeSetState(() {});

                                if (prayerId == null || prayerId.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor:
                                          FlutterFlowTheme.of(context).alternate,
                                      content: Text(
                                        'Rugăciunea salvată nu este validă. Vă rugăm să salvați o rugăciune din nou.',
                                        style: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .override(
                                              fontFamily: 'Inter',
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                _typeStack.clear();
                                safeSetState(() {});

                                context.pushNamed(
                                  'RosaryPage',
                                  queryParameters: {
                                    'prayerId': serializeParam(
                                      prayerId,
                                      ParamType.String,
                                    ).toString(),
                                    'page': serializeParam(
                                      valueOrDefault<int>(
                                        page,
                                        0,
                                      ),
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
                              },
                              child: Container(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    16.0, 14.0, 16.0, 14.0),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      FlutterFlowTheme.of(context).alternate,
                                      FlutterFlowTheme.of(context).alternate.withOpacity(0.9),
                                    ],
                                    stops: const [0.0, 1.0],
                                    begin: const AlignmentDirectional(-1.0, 0.0),
                                    end: const AlignmentDirectional(1.0, 0.0),
                                  ),
                                  borderRadius: BorderRadius.circular(16.0),
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(context).primary.withOpacity(0.2),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: FlutterFlowTheme.of(context).primary.withOpacity(0.15),
                                      blurRadius: 12.0,
                                      offset: const Offset(0.0, 4.0),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      child: Icon(
                                        Icons.bookmark_rounded,
                                        color: FlutterFlowTheme.of(context).primary,
                                        size: 24.0,
                                      ),
                                    ),
                                    const SizedBox(width: 12.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Continuă rugăciunea salvată',
                                            style: FlutterFlowTheme.of(context)
                                                .labelSmall
                                                .override(
                                                  fontFamily: 'Inter',
                                                  color: FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                                  letterSpacing: 0.5,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          const SizedBox(height: 2.0),
                                          Text(
                                            '${FFAppState().savedPrayer.prayer?.title}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: FlutterFlowTheme.of(context)
                                                .titleSmall
                                                .override(
                                                  fontFamily: 'Merriweather',
                                                  color: FlutterFlowTheme.of(context)
                                                      .primary,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      color: FlutterFlowTheme.of(context).primary,
                                      size: 20.0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SliverPadding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                          16.0,
                          16.0,
                          16.0,
                          0.0,
                        ),
                        
                        sliver: SliverToBoxAdapter(
                          child: FutureBuilder<ApiCallResponse>(
                            future: (_model.apiRequestCompleter ??=
                                    Completer<ApiCallResponse>()
                                      ..complete(SuapabaseQueriesGroup
                                          .getPrayerTypesCall
                                          .call()))
                                .future,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Center(
                                  child: SizedBox(
                                    width: 24.0,
                                    height: 24.0,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        FlutterFlowTheme.of(context).primary,
                                      ),
                                    ),
                                  ),
                                );
                              } else if (snapshot.data!.succeeded ==
                                  false) {
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                          top: 12.0),
                                      child: Text(
                                        'Rugăciunile nu au putut fi încărcate. Vă rugăm să încercați din nou mai târziu sau verificați conexiunea la internet.',
                                        style: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .override(
                                              fontFamily: 'Inter',
                                              color: FlutterFlowTheme.of(context)
                                                  .alternate,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(height: 12.0),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            FlutterFlowTheme.of(context)
                                                .alternate,
                                      ),
                                      onPressed: () {
                                        _model.apiRequestCompleter = null;
                                        safeSetState(() {});
                                      },

                                      child: Text(
                                        'Reîncearcă',
                                        style: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .override(
                                              fontFamily: 'Inter',
                                              color: FlutterFlowTheme.of(context)
                                                  .primary,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ),
                                    SizedBox(height: 16.0),
                                    Text(
                                        'Verifică rugăciunile descărcate pe telefon:',
                                        style: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .override(
                                              fontFamily: 'Inter',
                                              color: FlutterFlowTheme.of(context)
                                                  .alternate,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          FlutterFlowTheme.of(context)
                                              .alternate,
                                    ),
                                    onPressed: () {
                                      context.pushNamed(
                                        'DownloadedPrayersPage',
                                        extra: <String, dynamic>{
                                          kTransitionInfoKey:
                                              const TransitionInfo(
                                            hasTransition: true,
                                            transitionType:
                                                PageTransitionType.fade,
                                            duration:
                                                Duration(milliseconds: 250),
                                          ),
                                        },
                                      );
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Rugăciuni descărcate',
                                          style: FlutterFlowTheme.of(context)
                                              .labelMedium
                                              .override(
                                                fontFamily: 'Inter',
                                                color: FlutterFlowTheme.of(context)
                                                    .primary,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                        const SizedBox(width: 8.0),
                                        Icon(
                                          Icons.download_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          size: 20.0,
                                        ),
                                      ],
                                    ),
                                  ),
                    ]);
                              }

                              final listViewGetPrayerTypesResponse =
                                  snapshot.data!;
                              final prayerTypes =
                                  (listViewGetPrayerTypesResponse.jsonBody
                                          .toList()
                                          .map<PrayerTypeStruct?>(
                                            PrayerTypeStruct.maybeFromMap,
                                          )
                                          .toList()
                                      as Iterable<PrayerTypeStruct?>)
                                      .withoutNulls
                                      .toList();
                              prayerTypes.sort(
                                  (a, b) => a.sequence.compareTo(b.sequence));

                              final query = _searchQuery.toLowerCase().trim();
                              final searchResults = query.isNotEmpty
                                  ? _buildPrayerSearchResults(prayerTypes, query)
                                  : const <_PrayerSearchItem>[];

                              if (_typeStack.isNotEmpty && !_searchActive) {
                                return _buildSelectedTypeList(context);
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (query.isNotEmpty)
                                    const SizedBox(height: 8.0),
                                  if (listViewGetPrayerTypesResponse.succeeded)
                                    if (query.isNotEmpty)
                                      if (searchResults.isNotEmpty)
                                        ListView.separated(
                                          padding: EdgeInsets.zero,
                                          primary: false,
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: searchResults.length,
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(height: 12.0),
                                          itemBuilder: (context, index) {
                                            final result = searchResults[index];
                                            return PrayerTypeCardWidget(
                                              title: result.prayer.subtitle,
                                              subtitle: result.prayer.title,
                                              trailingText: null,
                                              trailingIcons: result.prayer.mode != PrayerMode.audioAndText ? [result.prayer.mode == PrayerMode.audioOnly ? Icons.audiotrack_rounded : Icons.text_snippet_rounded, Icons.chevron_right_rounded] : const [Icons.chevron_right_rounded],
                                              onTap: () async {
                                                _typeStack.clear();
                                                _exitSearch();
                                                safeSetState(() {});
                                                await context.pushNamed(
                                                  'RosaryPage',
                                                  queryParameters: {
                                                    'prayerId': serializeParam(
                                                      result.prayer.id,
                                                      ParamType.String,
                                                    ),
                                                  }.withoutNulls,
                                                  extra: <String, dynamic>{
                                                    kTransitionInfoKey:
                                                        const TransitionInfo(
                                                      hasTransition: true,
                                                      transitionType:
                                                          PageTransitionType.fade,
                                                      duration: Duration(
                                                          milliseconds: 250),
                                                    ),
                                                  },
                                                );
                                              },
                                            );
                                          },
                                        )
                                      else
                                        Padding(

                                          padding:
                                              const EdgeInsetsDirectional.only(
                                                  top: 12.0),
                                          child: Text(
                                            'Nu există rugăciuni cu acest nume.',
                                            style: FlutterFlowTheme.of(context)
                                                .labelMedium
                                                .override(
                                                  fontFamily: 'Inter',
                                                  color:
                                                      FlutterFlowTheme.of(context)
                                                          .alternate,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        )
                                    else
                                      ListView.separated(
                                        padding: EdgeInsets.zero,
                                        primary: false,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: prayerTypes.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(height: 12.0),
                                        itemBuilder: (context, index) {
                                          final type = prayerTypes[index % prayerTypes.length];
                                          final totalCount =
                                              type.subtypes.length +
                                                  type.prayers.length;
                                          if (totalCount == 0) {
                                            // Skip types with no subtypes or prayers
                                            return const SizedBox.shrink();
                                          }

                                          if(type.subtypes.isEmpty &&
                                             type.prayers.length == 1) {
                                            final prayer = type.prayers.first;
                                             return PrayerTypeCardWidget(
                                            title: prayer.subtitle,
                                            subtitle: null,
                                            trailingText: null,
                                            trailingIcons: prayer.mode != PrayerMode.audioAndText ? [prayer.mode == PrayerMode.audioOnly ? Icons.audiotrack_rounded : Icons.text_snippet_rounded, Icons.chevron_right_rounded] : const [Icons.chevron_right_rounded],
                                            onTap: () async {
                                              // only one prayer and no subtypes, open it directly
             
                                                await context.pushNamed(
                                                  'RosaryPage',
                                                  queryParameters: {
                                                    'prayerId': serializeParam(
                                                      prayer.id,
                                                      ParamType.String,
                                                    ),
                                                  }.withoutNulls,
                                                  extra: <String, dynamic>{
                                                    kTransitionInfoKey:
                                                        const TransitionInfo(
                                                      hasTransition: true,
                                                      transitionType:
                                                          PageTransitionType.fade,
                                                      duration: Duration(
                                                          milliseconds: 250),
                                                    ),
                                                  },
                                                );
                                            },
                                          );
                                          }

                                          return PrayerTypeCardWidget(
                                            title: type.type,
                                            subtitle: null,
                                            trailingText: null,
                                            trailingIcons: [Icons.chevron_right_rounded],
                                            onTap: () async {
                                              if (type.subtypes.isEmpty &&
                                                  type.prayers.isEmpty) {
                                                return;
                                              }
                                              _enterPrayerType(type);
                                            },
                                          );
                                        },
                                      ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),

                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: _searchActive
                                ? 16.0
                                : (_showAudioPlayer ? 8.0 : 24.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_showAudioPlayer)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                      child: HomeAudioMiniPlayer(
                        pageManager: _pageManager,
                        audioHandler: _audioHandler,
                        onClose: _closeAudioPlayer,
                        onOpenPrayer: _openCurrentPrayerWithAudio,
                      ),
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

  List<_PrayerSearchItem> _buildPrayerSearchResults(
    List<PrayerTypeStruct> types,
    String query,
  ) {
    final lower = query.toLowerCase().trim();
    if (lower.isEmpty) {
      return [];
    }

    final results = <_PrayerSearchItem>[];

    void walkType(PrayerTypeStruct type, String prefix) {
      final currentPath = prefix.isEmpty ? type.type : '$prefix > ${type.type}';

      for (final prayer in type.prayers) {
        final haystack =
            '${prayer.title} ${prayer.subtitle} $currentPath'.toLowerCase();
        if (haystack.contains(lower)) {
          results.add(
            _PrayerSearchItem(
              prayer: prayer,
              path: currentPath,
            ),
          );
        }
      }

      for (final subtype in type.subtypes) {
        walkType(subtype, currentPath);
      }
    }

    for (final type in types) {
      walkType(type, '');
    }

    return results;
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

  void _exitSearch() {
    _searchController.clear();
    _searchQuery = '';
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
}
