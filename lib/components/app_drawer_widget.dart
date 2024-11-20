import '/backend/api_requests/api_calls.dart';
import '/components/sub_types_view_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/backend/schema/structs/index.dart';
import 'package:aligned_tooltip/aligned_tooltip.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_drawer_model.dart';
export 'app_drawer_model.dart';

class AppDrawerWidget extends StatefulWidget {
  const AppDrawerWidget({super.key});

  @override
  State<AppDrawerWidget> createState() => _AppDrawerWidgetState();
}

class _AppDrawerWidgetState extends State<AppDrawerWidget> {
  late AppDrawerModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AppDrawerModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  'assets/images/logo_cmd.png',
                  width: 64.0,
                  height: 64.0,
                  fit: BoxFit.cover,
                ),
              ),
              Text(
                'Surorile CMD',
                style: FlutterFlowTheme.of(context).titleLarge.override(
                      fontFamily: 'Inter Tight',
                      letterSpacing: 0.0,
                    ),
              ),
            ].divide(const SizedBox(width: 16.0)),
          ),
          Divider(
            thickness: 2.0,
            color: FlutterFlowTheme.of(context).alternate,
          ),
          Container(
            height: MediaQuery.sizeOf(context).height * 0.6,
            decoration: const BoxDecoration(),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              children: [
                FutureBuilder<ApiCallResponse>(
                  future: _model.prayerTypesQuery(
                    uniqueQueryKey: 'prayerTypesQuery',
                    requestFn: () =>
                        SuapabaseQueriesGroup.getPrayerTypesCall.call(),
                  ),
                  builder: (context, snapshot) {
                    // Customize what your widget looks like when it's loading.
                    if (!snapshot.hasData) {
                      return Center(
                        child: SizedBox(
                          width: 50.0,
                          height: 50.0,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              FlutterFlowTheme.of(context).primary,
                            ),
                          ),
                        ),
                      );
                    }
                    final subTypesViewGetPrayerTypesResponse = snapshot.data!;

                    return wrapWithModel(
                      model: _model.subTypesViewModel,
                      updateCallback: () => safeSetState(() {}),
                      child: SubTypesViewWidget(
                        prayerTypes: (subTypesViewGetPrayerTypesResponse
                                .jsonBody
                                .toList()
                                .map<PrayerTypeStruct?>(
                                    PrayerTypeStruct.maybeFromMap)
                                .toList() as Iterable<PrayerTypeStruct?>)
                            .withoutNulls,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Divider(
            thickness: 2.0,
            color: FlutterFlowTheme.of(context).alternate,
          ),
          AlignedTooltip(
            content: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                'Continuă automat partea audio între sectiuni',
                style: FlutterFlowTheme.of(context).bodyLarge.override(
                      fontFamily: 'Inter',
                      letterSpacing: 0.0,
                    ),
              ),
            ),
            offset: 4.0,
            preferredDirection: AxisDirection.up,
            borderRadius: BorderRadius.circular(8.0),
            backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
            elevation: 4.0,
            tailBaseWidth: 24.0,
            tailLength: 12.0,
            waitDuration: const Duration(milliseconds: 100),
            showDuration: const Duration(milliseconds: 1500),
            triggerMode: TooltipTriggerMode.longPress,
            child: Material(
              color: Colors.transparent,
              child: SwitchListTile.adaptive(
                value: _model.switchListTileValue ??= FFAppState().autoPlayNext,
                onChanged: (newValue) async {
                  safeSetState(() => _model.switchListTileValue = newValue);
                  if (newValue) {
                    FFAppState().autoPlayNext = true;
                    safeSetState(() {});
                  } else {
                    FFAppState().autoPlayNext = false;
                    safeSetState(() {});
                  }
                },
                title: Text(
                  'Auto Play',
                  style: FlutterFlowTheme.of(context).titleSmall.override(
                        fontFamily: 'Inter Tight',
                        letterSpacing: 0.0,
                      ),
                ),
                tileColor: FlutterFlowTheme.of(context).secondaryBackground,
                activeColor: FlutterFlowTheme.of(context).alternate,
                activeTrackColor: FlutterFlowTheme.of(context).primary,
                dense: true,
                controlAffinity: ListTileControlAffinity.trailing,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
