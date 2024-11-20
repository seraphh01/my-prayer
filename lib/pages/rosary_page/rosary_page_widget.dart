import '/backend/api_requests/api_calls.dart';
import '/components/app_drawer_widget.dart';
import '/components/sections_view_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/backend/schema/structs/index.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'rosary_page_model.dart';
export 'rosary_page_model.dart';

class RosaryPageWidget extends StatefulWidget {
  const RosaryPageWidget({
    super.key,
    required this.prayerId,
  });

  final String? prayerId;

  @override
  State<RosaryPageWidget> createState() => _RosaryPageWidgetState();
}

class _RosaryPageWidgetState extends State<RosaryPageWidget> {
  late RosaryPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RosaryPageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.weekDay = valueOrDefault<int>(
        DateTime.fromMillisecondsSinceEpoch(
                getCurrentTimestamp.millisecondsSinceEpoch)
            .weekday,
        1,
      );
      _model.rosaryTabIndex = valueOrDefault<int>(
        () {
          if ((_model.weekDay == 1) || (_model.weekDay == 6)) {
            return 0;
          } else if (_model.weekDay == 4) {
            return 1;
          } else if ((_model.weekDay == 2) || (_model.weekDay == 5)) {
            return 2;
          } else {
            return 3;
          }
        }(),
        0,
      );
      _model.currentAudioUrl = '';
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiCallResponse>(
      future: _model.prayerSectionsQuery(
        uniqueQueryKey: 'prayersSectionsQuery${widget.prayerId}',
        requestFn: () =>
            SuapabaseQueriesGroup.getPrayerWithSectionsRecursiveCall.call(
          requestPrayerId: widget.prayerId,
        ),
      ),
      builder: (context, snapshot) {
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Center(
              child: SizedBox(
                width: 40.0,
                height: 40.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            ),
          );
        }
        final rosaryPageGetPrayerWithSectionsRecursiveResponse = snapshot.data!;

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
                title: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: const AlignmentDirectional(-1.0, 0.0),
                      child: Text(
                        valueOrDefault<String>(
                          PrayerStruct.maybeFromMap(
                                  rosaryPageGetPrayerWithSectionsRecursiveResponse
                                      .jsonBody)
                              ?.title,
                          'Titlu rugăciune',
                        ),
                        textAlign: TextAlign.start,
                        style: FlutterFlowTheme.of(context)
                            .headlineMedium
                            .override(
                              fontFamily: 'Inter Tight',
                              color: Colors.white,
                              fontSize: 22.0,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ),
                    FlutterFlowIconButton(
                      borderRadius: 8.0,
                      buttonSize: 40.0,
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: FlutterFlowTheme.of(context).primaryText,
                        size: 24.0,
                      ),
                      onPressed: () async {
                        context.pushNamed(
                          'PrayerOptionsPage',
                          queryParameters: {
                            'prayerDetails': serializeParam(
                              PrayerStruct.maybeFromMap(
                                  rosaryPageGetPrayerWithSectionsRecursiveResponse
                                      .jsonBody),
                              ParamType.DataStruct,
                            ),
                          }.withoutNulls,
                          extra: <String, dynamic>{
                            kTransitionInfoKey: const TransitionInfo(
                              hasTransition: true,
                              transitionType: PageTransitionType.fade,
                              duration: Duration(milliseconds: 500),
                            ),
                          },
                        );
                      },
                    ),
                  ],
                ),
                actions: const [],
                flexibleSpace: FlexibleSpaceBar(
                  background: ClipRRect(
                    borderRadius: BorderRadius.circular(0.0),
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
                toolbarHeight: MediaQuery.sizeOf(context).height * 0.1,
                elevation: 2.0,
              ),
            ),
            body: SafeArea(
              top: true,
              child: SafeArea(
                child: SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.9,
                  child: wrapWithModel(
                    model: _model.sectionsViewModel,
                    updateCallback: () => safeSetState(() {}),
                    child: SectionsViewWidget(
                      sections: PrayerStruct.maybeFromMap(
                              rosaryPageGetPrayerWithSectionsRecursiveResponse
                                  .jsonBody)
                          ?.sections,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
