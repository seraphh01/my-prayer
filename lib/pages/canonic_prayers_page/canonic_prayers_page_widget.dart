import '/components/app_drawer_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'canonic_prayers_page_model.dart';
export 'canonic_prayers_page_model.dart';

class CanonicPrayersPageWidget extends StatefulWidget {
  const CanonicPrayersPageWidget({super.key});

  @override
  State<CanonicPrayersPageWidget> createState() =>
      _CanonicPrayersPageWidgetState();
}

class _CanonicPrayersPageWidgetState extends State<CanonicPrayersPageWidget>
    with TickerProviderStateMixin {
  late CanonicPrayersPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CanonicPrayersPageModel());

    _model.tabBarController = TabController(
      vsync: this,
      length: 4,
      initialIndex: 0,
    )..addListener(() => safeSetState(() {}));
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
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        drawer: AnimatedOpacity(
          opacity: 0.9,
          duration: 570.0.ms,
          curve: Curves.easeInOut,
          child: Drawer(
            elevation: 16.0,
            child: wrapWithModel(
              model: _model.appDrawerModel,
              updateCallback: () => safeSetState(() {}),
              child: const AppDrawerWidget(),
            ),
          ),
        ),
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(MediaQuery.sizeOf(context).height * 0.1),
          child: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            automaticallyImplyLeading: true,
            title: Align(
              alignment: const AlignmentDirectional(-1.0, 0.0),
              child: Text(
                'Rugaciunea orelor canonice',
                textAlign: TextAlign.start,
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                      fontFamily: 'Inter Tight',
                      color: Colors.white,
                      fontSize: 22.0,
                      letterSpacing: 0.0,
                    ),
              ),
            ),
            actions: const [],
            flexibleSpace: FlexibleSpaceBar(
              background: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: CachedNetworkImage(
                  fadeInDuration: const Duration(milliseconds: 500),
                  fadeOutDuration: const Duration(milliseconds: 500),
                  imageUrl:
                      'https://images.unsplash.com/photo-1495552665515-46e119a10545?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHw3fHxwcmF5JTIwZ3JlZWslMjBjYXRob2xpY3xlbnwwfHx8fDE3MzA3MTg3ODd8MA&ixlib=rb-4.0.3&q=80&w=1080',
                  fit: BoxFit.cover,
                  alignment: const Alignment(0.0, -0.1),
                ),
              ),
            ),
            centerTitle: false,
            elevation: 2.0,
          ),
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Align(
                      alignment: const Alignment(0.0, 0),
                      child: TabBar(
                        isScrollable: true,
                        labelColor: FlutterFlowTheme.of(context).primaryText,
                        unselectedLabelColor:
                            FlutterFlowTheme.of(context).secondaryText,
                        labelStyle:
                            FlutterFlowTheme.of(context).titleMedium.override(
                                  fontFamily: 'Inter Tight',
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                ),
                        unselectedLabelStyle:
                            FlutterFlowTheme.of(context).titleMedium.override(
                                  fontFamily: 'Inter Tight',
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.normal,
                                ),
                        indicatorColor: FlutterFlowTheme.of(context).primary,
                        indicatorWeight: 1.0,
                        tabs: const [
                          Tab(
                            text: 'Ora I',
                          ),
                          Tab(
                            text: 'Ora a III-a',
                          ),
                          Tab(
                            text: 'Ora a VI-a',
                          ),
                          Tab(
                            text: 'Ora a IX-a',
                          ),
                        ],
                        controller: _model.tabBarController,
                        onTap: (i) async {
                          [
                            () async {},
                            () async {},
                            () async {},
                            () async {}
                          ][i]();
                        },
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _model.tabBarController,
                        children: const [
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [],
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
      ),
    );
  }
}
