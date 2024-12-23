import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/components/sub_types_view_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import 'dart:async';
import 'package:flutter/material.dart';
import 'all_prayers_page_model.dart';
export 'all_prayers_page_model.dart';

class AllPrayersPageWidget extends StatefulWidget {
  const AllPrayersPageWidget({super.key});

  @override
  State<AllPrayersPageWidget> createState() => _AllPrayersPageWidgetState();
}

class _AllPrayersPageWidgetState extends State<AllPrayersPageWidget> {
  late AllPrayersPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AllPrayersPageModel());

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
        backgroundColor: FlutterFlowTheme.of(context).primary,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(64.0),
          child: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).primary,
            iconTheme:
                IconThemeData(color: FlutterFlowTheme.of(context).alternate),
            automaticallyImplyLeading: true,
            title: Text(
              'Toate rugăciunile',
              style: FlutterFlowTheme.of(context).titleLarge.override(
                    fontFamily: 'Merriweather',
                    color: FlutterFlowTheme.of(context).alternate,
                    letterSpacing: 0.0,
                  ),
            ),
            actions: const [],
            centerTitle: true,
            toolbarHeight: 64.0,
            elevation: 0.0,
          ),
        ),
        body: SafeArea(
          top: true,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 8.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    FutureBuilder<ApiCallResponse>(
                      future: (_model.apiRequestCompleter ??=
                              Completer<ApiCallResponse>()
                                ..complete(SuapabaseQueriesGroup
                                    .getPrayerTypesCall
                                    .call()))
                          .future,
                      builder: (context, snapshot) {
                        // Customize what your widget looks like when it's loading.
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
                        }
                        final listViewGetPrayerTypesResponse = snapshot.data!;

                        return RefreshIndicator(
                          color: FlutterFlowTheme.of(context).primary,
                          onRefresh: () async {
                            safeSetState(
                                () => _model.apiRequestCompleter = null);
                            await _model.waitForApiRequestCompleted();
                          },
                          child: ListView(
                            padding: EdgeInsets.zero,
                            primary: false,
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            children: [
                              if (listViewGetPrayerTypesResponse.succeeded)
                                wrapWithModel(
                                  model: _model.subTypesViewModel,
                                  updateCallback: () => safeSetState(() {}),
                                  child: SubTypesViewWidget(
                                    prayerTypes:
                                        (listViewGetPrayerTypesResponse.jsonBody
                                                    .toList()
                                                    .map<PrayerTypeStruct?>(
                                                        PrayerTypeStruct
                                                            .maybeFromMap)
                                                    .toList()
                                                as Iterable<PrayerTypeStruct?>)
                                            .withoutNulls,
                                    onSelectPrayer: (prayerId) async {
                                      await actions.navigateWithRelacement(
                                        context,
                                        'RosaryPage',
                                        <String, String?>{
                                          'prayerId': prayerId,
                                        },
                                      );
                                    },
                                  ),
                                ),
                            ].divide(const SizedBox(height: 8.0)),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
