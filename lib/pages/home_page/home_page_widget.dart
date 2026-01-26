import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:my_prayer/components/download_progress_indicator.dart';
import 'package:my_prayer/custom_code/audio/notifiers/play_button_notifier.dart';
import 'package:my_prayer/custom_code/audio/page_manager.dart';
import 'package:my_prayer/custom_code/download/download_manager.dart';
import 'package:my_prayer/custom_code/download/notifiers/download_state_notifier.dart';
import 'package:my_prayer/service_locator.dart';

import '/backend/api_requests/api_calls.dart';
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

class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PinnedHeaderDelegate({
    required this.minExtent,
    required this.maxExtent,
    required this.child,
  });

  @override
  final double minExtent;
  @override
  final double maxExtent;
  final Widget child;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _PinnedHeaderDelegate oldDelegate) {
    return maxExtent != oldDelegate.maxExtent ||
        minExtent != oldDelegate.minExtent ||
        child != oldDelegate.child;
  }
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
  static const double _expandedHeight = 350.0;
  static const double _searchBarHeight = 72.0;
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
      final targetOffset = _expandedHeight - minHeight;
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
        if (!_searchPinned) {
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
          final targetOffset = _expandedHeight - minHeight;
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
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
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

    return WillPopScope(
      onWillPop: () async {
        if (_searchActive || _searchFocusNode.hasFocus) {
          _exitSearch();
          return false;
        }
        if (_typeStack.isNotEmpty) {
          _typeStack.removeLast();
          safeSetState(() {});
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
              child: Stack(
                children: [
                  CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverAppBar(
                        backgroundColor: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
                        pinned: true,
                        toolbarHeight: _toolbarHeight,
                        expandedHeight: _searchActive
                          ? _toolbarHeight + _searchBarHeight
                          : _expandedHeight,
                        elevation: 0.0,
                        automaticallyImplyLeading: false,
                        bottom: _searchActive
                            ? PreferredSize(
                                preferredSize: const Size.fromHeight(
                                    _searchBarHeight),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                  child: _buildSearchField(context),
                                ),
                              )
                            : null,
                        leading: _downloadManager.downloadStateNotifier.value == DownloadState.downloading 
                            ?  const Hero(
                                tag: "downloadIndicator",
                                child: DownloadProgressIndicator(),
                              ) : IconButton(
                          icon: Icon(
                            Icons.menu_rounded,
                            color: FlutterFlowTheme.of(context).alternate,
                          ),
                          onPressed: () {
                            scaffoldKey.currentState?.openDrawer();
                          },
                        ),
                        iconTheme: IconThemeData(
                            color: FlutterFlowTheme.of(context).alternate),
                        actions: [
                          if (!_searchActive)
                            FlutterFlowIconButton(
                              borderColor: Colors.transparent,
                              borderRadius: 8.0,
                              buttonSize: 48.0,
                              icon: Icon(
                                Icons.search_rounded,
                                color:
                                    FlutterFlowTheme.of(context).alternate,
                                size: 24.0,
                              ),
                              onPressed: () {
                                _searchPinned = true;
                                safeSetState(() {});
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _searchFocusNode.requestFocus();
                                });
                              },
                            ),
                          FlutterFlowIconButton(
                            borderColor: Colors.transparent,
                            borderRadius: 8.0,
                            buttonSize: 48.0,
                            icon: Icon(
                              Icons.settings_rounded,
                              color:
                                  FlutterFlowTheme.of(context).alternate,
                              size: 24.0,
                            ),
                            onPressed: () async {
                              context.pushNamed(
                                'SettingsPage',
                                extra: <String, dynamic>{
                                  kTransitionInfoKey:
                                      const TransitionInfo(
                                    hasTransition: true,
                                    transitionType: PageTransitionType.fade,
                                    duration: Duration(milliseconds: 250),
                                  ),
                                },
                              );
                            },
                          ),
                        ],
                        flexibleSpace: LayoutBuilder(
                          builder: (context, constraints) {
                            final maxHeight = constraints.biggest.height;
                            final minHeight = _toolbarHeight +
                              (_searchActive ? _searchBarHeight : 0.0);
                            final expandedHeight = _searchActive
                              ? _toolbarHeight + _searchBarHeight
                              : _expandedHeight;
                            final collapseRange = expandedHeight - minHeight;
                            final t = collapseRange <= 0
                                ? 0.0
                                : ((maxHeight - minHeight) / collapseRange)
                                    .clamp(0.0, 1.0);
                            final logoSize = lerpDouble(44.0, 210.0, t) ?? 44.0;
                            final expandedLeft =
                              (constraints.biggest.width - logoSize) / 2;
                            // When collapsed and not searching, position logo to the right of menu button
                            final collapsedLeft = 60.0;
                            final leftPadding =
                              lerpDouble(collapsedLeft, expandedLeft, t) ?? collapsedLeft;
                            final collapsedTop = (_toolbarHeight - logoSize) / 2;
                            final expandedTop = 120.0;
                            final topPadding =
                                lerpDouble(collapsedTop, expandedTop, t) ??
                                    collapsedTop;
                            final cornerRadius =  80.0;

                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        FlutterFlowTheme.of(context).primary,
                                        const Color(0xFF3C010C)
                                      ],
                                      stops: const [0.0, 1.0],
                                      begin:
                                          const AlignmentDirectional(0.0, -1.0),
                                      end: const AlignmentDirectional(0, 1.0),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 16.0,
                                  right: 16.0,
                                  top: 56.0,
                                  child: Opacity(
                                    opacity: _searchPinned ? 0.0 : t,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        AutoSizeText(
                                          'Congregația Surorilor Maicii Domnului',
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          minFontSize: 18.0,
                                          style: FlutterFlowTheme.of(context)
                                              .titleMedium
                                              .override(
                                                fontFamily: 'PlayBall',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .alternate,
                                                fontSize: 28.0,
                                                letterSpacing: 0.0,
                                                shadows: [
                                                  const Shadow(
                                                    color: Color(0xFF1C1200),
                                                    offset: Offset(1.0, 1.0),
                                                    blurRadius: 2.0,
                                                  )
                                                ],
                                                useGoogleFonts: false,
                                              ),
                                        ),
                                        Text(
                                          dateTimeFormat(
                                            "yMMMMEEEEd",
                                            DateTime.fromMillisecondsSinceEpoch(
                                                getCurrentTimestamp
                                                    .millisecondsSinceEpoch),
                                            locale: FFLocalizations.of(context)
                                                .languageCode,
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .titleSmall
                                              .override(
                                                fontFamily: 'Inter',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .alternate,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if(!_searchActive || _downloadManager.downloadStateNotifier.value != DownloadState.downloading)
                                Positioned(
                                  left: leftPadding,
                                  top: topPadding,
                                  child: Hero(
                                    tag: 'homeLogo',
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(cornerRadius),
                                      child: Image.asset(
                                        'assets/images/logo.jpg',
                                        width: logoSize,
                                        height: logoSize,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                                            SliverToBoxAdapter(
                        child: Visibility(
                          visible: valueOrDefault<bool>(
                            !_searchActive &&
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
                                              trailingIcon: Icons.chevron_right_rounded,
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
                                        itemCount: prayerTypes.length, // Simulate more items
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(height: 12.0),
                                        itemBuilder: (context, index) {
                                          final type = prayerTypes[index % prayerTypes.length];
                                          final totalCount =
                                              type.subtypes.length +
                                                  type.prayers.length;
                                          return PrayerTypeCardWidget(
                                            title: type.type,
                                            subtitle: null,
                                            trailingText: null,
                                            trailingIcon: totalCount > 1
                                                ? Icons.menu_book_rounded
                                                : Icons.chevron_right_rounded,
                                            onTap: () async {
                                              if (type.subtypes.isEmpty &&
                                                  type.prayers.isEmpty) {
                                                return;
                                              }
                                              // If only one prayer and no subtypes, open it directly
                                              if (type.subtypes.isEmpty &&
                                                  type.prayers.length == 1) {
                                                await context.pushNamed(
                                                  'RosaryPage',
                                                  queryParameters: {
                                                    'prayerId': serializeParam(
                                                      type.prayers.first.id,
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
                                                return;
                                              }
                                              _typeStack.add(type);
                                              safeSetState(() {});
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
                                : (FFAppState().currentPrayerId.isNotEmpty ||
                                        (FFAppState().savedPrayer.prayer != null &&
                                            FFAppState().savedPrayer.prayer?.id != '' &&
                                            FFAppState().currentPrayerId.isEmpty))
                                    ? 100.0
                                    : 24.0,
                          ),
                        ),
                    ],
                  ),
                StreamBuilder(
                  stream: _audioHandler.queue,
                  builder: (context, snapshot) {
                    var queue = snapshot.data;
                    return Visibility(
                      visible: snapshot.data != null &&
                          FFAppState().currentPrayerId.isNotEmpty &&
                          !_searchPinned &&
                          _searchQuery.isEmpty,
                      child: Positioned(
                        left: 16.0,
                        right: 16.0,
                        bottom: 16.0,
                        child: SafeArea(
                          top: false,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              GestureDetector(
                            onTap: () async {
                              _typeStack.clear();
                              safeSetState(() {});
                              await context.pushNamed('RosaryPage',
                                  queryParameters: {
                                    'prayerId': serializeParam(
                                      valueOrDefault<String>(
                                          FFAppState().currentPrayerId, ''),
                                      ParamType.String,
                                    ),
                                    'continueAudio': serializeParam(
                                      true,
                                      ParamType.bool,
                                    ).toString(),
                                    'page': serializeParam(
                                      valueOrDefault<int>(
                                          _pageManager.trackIndexNotifier.value,
                                          0),
                                      ParamType.int,
                                    ).toString(),
                                    'initialAudioTime': serializeParam(
                                      valueOrDefault<double>(
                                          _pageManager.currentProgressNotifier
                                              .value.inSeconds
                                              .toDouble(),
                                          0.0),
                                      ParamType.double,
                                    ).toString(),
                                  }.withoutNulls);
                            },
                            child: Container(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  12.0, 12.0, 12.0, 12.0),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    FlutterFlowTheme.of(context).alternate,
                                    FlutterFlowTheme.of(context).alternate.withOpacity(0.95),
                                  ],
                                  stops: const [0.0, 1.0],
                                  begin: const AlignmentDirectional(-1.0, -1.0),
                                  end: const AlignmentDirectional(1.0, 1.0),
                                ),
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.2),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: FlutterFlowTheme.of(context).primary.withOpacity(0.2),
                                    blurRadius: 16.0,
                                    offset: const Offset(0.0, 6.0),
                                  ),
                                ],
                              ),
                              child: StreamBuilder(
                                  stream: _audioHandler.mediaItem,
                                  builder: (context, snapshot) {
                                    final mediaItem = queue != null &&
                                            queue.length >
                                                _pageManager
                                                    .trackIndexNotifier.value
                                        ? queue[_pageManager
                                            .trackIndexNotifier.value]
                                        : null;
                                    return mediaItem != null
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Flexible(
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Hero(
                                                      tag: 'sectionImageHero',
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                8.0),
                                                        child: Image.network(
                                                          mediaItem.artUri
                                                                  .toString() ??
                                                              '',
                                                          width: 48,
                                                          height: 48,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    Flexible(
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          AutoSizeText(
                                                            mediaItem.title ?? '',
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow.ellipsis,
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .titleSmall
                                                                .override(
                                                                  fontFamily:
                                                                      'Merriweather',
                                                                  color: FlutterFlowTheme
                                                                          .of(context)
                                                                      .primary,
                                                                  letterSpacing: 0.0,
                                                                ),
                                                          ),
                                                          if (mediaItem.album != null &&
                                                              mediaItem.album!
                                                                  .isNotEmpty) 
                                                          AutoSizeText(
                                                            mediaItem.album ?? '',
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .labelSmall
                                                                .override(
                                                                  fontFamily: 'Inter',
                                                                  color: FlutterFlowTheme
                                                                          .of(context)
                                                                      .primary,
                                                                  letterSpacing: 0.0,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ].divide(
                                                      const SizedBox(width: 8.0)),
                                                ),
                                              ),
                                              ValueListenableBuilder(
                                                  valueListenable:
                                                      _pageManager.playButtonNotifier,
                                                  builder: (_, value, __) {
                                                    switch (value) {
                                                      case ButtonState.loading:
                                                        return Container(
                                                          width: 48,
                                                          height: 48,
                                                          padding:
                                                              const EdgeInsets.all(
                                                                  16),
                                                          child:
                                                              CircularProgressIndicator(
                                                            valueColor:
                                                                AlwaysStoppedAnimation<
                                                                    Color>(
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primary,
                                                            ),
                                                          ),
                                                        );
                                                      case ButtonState.paused:
                                                        return FlutterFlowIconButton(
                                                            buttonSize: 48,
                                                            icon: Icon(
                                                                Icons.play_arrow_rounded,
                                                                color:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary),
                                                            onPressed:  
                                                                _pageManager.play);
                                                      case ButtonState.playing:
                                                        return FlutterFlowIconButton(
                                                          buttonSize: 48,
                                                          icon: Icon(
                                                              Icons.pause_rounded,
                                                              color:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary),
                                                          onPressed: 
                                                              _pageManager.pause
                                                        );
                                                    }
                                                  }),
                                            ].divide(
                                                const SizedBox(width: 8.0)),
                                          )
                                        : const SizedBox();
                                  }),
                            ),
                              ),
                              Positioned(
                                top: -4,
                                right: -4,
                                child: Container(
                                  width: 28.0,
                                  height: 28.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .alternate,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: FlutterFlowTheme.of(context).primary.withOpacity(0.3),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: FlutterFlowTheme.of(context).primary.withOpacity(0.2),
                                        blurRadius: 3.0,
                                        offset: const Offset(0.0, 2.0),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: IconButton(
                                      iconSize: 12.0,
                                      icon: Icon(
                                        Icons.close_rounded,
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                    
                                      ),
                                      onPressed: () async {
                                        _pageManager.stop();
                                        await _pageManager.clearQueue();
                                        FFAppState().currentPrayerId = '';
                                        safeSetState(() {});
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Positioned.fill(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {

                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                

                    },
                    child: _typeStack.isNotEmpty
                        ? Container(
                            key: ValueKey<String>(
                              _typeStack.map((e) => e.id).join('-'),
                            ),
                            color: FlutterFlowTheme.of(context).primary,
                            child: SafeArea(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        16.0, 8.0, 16.0, 8.0),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon:
                                              const Icon(Icons.arrow_back_rounded),
                                          color:
                                              FlutterFlowTheme.of(context).alternate,
                                          onPressed: () {
                                            _typeStack.removeLast();
                                            safeSetState(() {});
                                          },
                                        ),
                                        const SizedBox(width: 8.0),
                                        Expanded(
                                          child: Text(
                                            _typeStack.last.type,
                                            style: FlutterFlowTheme.of(context)
                                                .titleMedium
                                                .override(
                                                  fontFamily: 'Merriweather',
                                                  color: FlutterFlowTheme.of(context)
                                                      .alternate,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              16.0, 0.0, 16.0, 24.0),
                                      child: AnimatedSize(
                                        duration:
                                            const Duration(milliseconds: 250),
                                        curve: Curves.easeOut,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (_typeStack.last.prayers.isNotEmpty)
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [

                                                  ..._typeStack.last.prayers.map(
                                                    (prayer) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .only(bottom: 12.0),
                                                        child: PrayerTypeCardWidget(
                                                          title: prayer.subtitle,
                                                          trailingText: null,
                                                          trailingIcon: Icons.chevron_right_rounded,
                                                          onTap: () async {
                                                            _typeStack.clear();
                                                            safeSetState(() {});
                                                            await context.pushNamed(
                                                              'RosaryPage',
                                                              queryParameters: {
                                                                'prayerId':
                                                                    serializeParam(
                                                                  prayer.id,
                                                                  ParamType.String,
                                                                ),
                                                              }.withoutNulls,
                                                              extra:
                                                                  <String, dynamic>{
                                                                kTransitionInfoKey:
                                                                    const TransitionInfo(
                                                                  hasTransition: true,
                                                                  transitionType:
                                                                      PageTransitionType
                                                                          .fade,
                                                                  duration: Duration(
                                                                      milliseconds: 250),
                                                                ),
                                                              },
                                                            );
                                                          },
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                          if (_typeStack.last.subtypes.isNotEmpty)
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  ..._typeStack.last.subtypes.map(
                                                    (subtype) {
                                                      var totalCount =
                                                          subtype.subtypes.length +
                                                              subtype.prayers.length;
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .only(bottom: 12.0),
                                                        child: PrayerTypeCardWidget(
                                                          title: subtype.type,
                                                          subtitle: null,
                                                          trailingText:  null,
                                                          trailingIcon: totalCount > 1
                                                              ? Icons.menu_book_rounded
                                                              : Icons.chevron_right_rounded,
                                                          onTap: () async {
                                                            if (subtype
                                                                    .subtypes.isEmpty &&
                                                                subtype
                                                                    .prayers.isEmpty) {
                                                              return;
                                                            }
                                                            // If only one prayer and no subtypes, open it directly
                                                            if (subtype.subtypes.isEmpty &&
                                                                subtype.prayers.length == 1) {
                                                              _typeStack.clear();
                                                              safeSetState(() {});
                                                              await context.pushNamed(
                                                                'RosaryPage',
                                                                queryParameters: {
                                                                  'prayerId': serializeParam(
                                                                    subtype.prayers.first.id,
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
                                                              return;
                                                            }
                                                            _typeStack.add(subtype);
                                                            safeSetState(() {});
                                                          },
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
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
