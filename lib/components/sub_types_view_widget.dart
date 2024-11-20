import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'sub_types_view_model.dart';
export 'sub_types_view_model.dart';

class SubTypesViewWidget extends StatefulWidget {
  const SubTypesViewWidget({
    super.key,
    required this.prayerTypes,
  });

  final List<PrayerTypeStruct>? prayerTypes;

  @override
  State<SubTypesViewWidget> createState() => _SubTypesViewWidgetState();
}

class _SubTypesViewWidgetState extends State<SubTypesViewWidget> {
  late SubTypesViewModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SubTypesViewModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final subTypes = widget.prayerTypes!
            .sortedList(keyOf: (e) => e.sequence, desc: false)
            .toList();

        return ListView.builder(
          padding: EdgeInsets.zero,
          primary: false,
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: subTypes.length,
          itemBuilder: (context, subTypesIndex) {
            final subTypesItem = subTypes[subTypesIndex];
            return Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      if (subTypesItem.prayers.length == 1) {
                        context.pushNamed(
                          'RosaryPage',
                          queryParameters: {
                            'prayerId': serializeParam(
                              subTypesItem.prayers.first.id,
                              ParamType.String,
                            ),
                          }.withoutNulls,
                        );
                      } else {
                        if (_model.currentExpandedType == subTypesItem.id) {
                          _model.currentExpandedType = null;
                          safeSetState(() {});
                        } else {
                          _model.currentExpandedType = subTypesItem.id;
                          safeSetState(() {});
                        }
                      }
                    },
                    child: Material(
                      color: Colors.transparent,
                      child: ListTile(
                        title: Text(
                          subTypesItem.type.maybeHandleOverflow(
                            maxChars: 40,
                          ),
                          style:
                              FlutterFlowTheme.of(context).labelMedium.override(
                                    fontFamily: 'Inter',
                                    letterSpacing: 0.0,
                                  ),
                        ),
                        trailing: Icon(
                          Icons.arrow_right,
                          color: FlutterFlowTheme.of(context).secondaryText,
                          size: 16.0,
                        ),
                        tileColor:
                            FlutterFlowTheme.of(context).secondaryBackground,
                        dense: true,
                        contentPadding: const EdgeInsetsDirectional.fromSTEB(
                            12.0, 0.0, 12.0, 0.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  if (subTypesItem.id == _model.currentExpandedType)
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        if (subTypesItem.prayers.isNotEmpty)
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                8.0, 0.0, 0.0, 0.0),
                            child: Builder(
                              builder: (context) {
                                final prayers = subTypesItem.prayers.toList();

                                return ListView.builder(
                                  padding: EdgeInsets.zero,
                                  primary: false,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount: prayers.length,
                                  itemBuilder: (context, prayersIndex) {
                                    final prayersItem = prayers[prayersIndex];
                                    return InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        context.pushNamed(
                                          'RosaryPage',
                                          queryParameters: {
                                            'prayerId': serializeParam(
                                              prayersItem.id,
                                              ParamType.String,
                                            ),
                                          }.withoutNulls,
                                        );
                                      },
                                      child: Material(
                                        color: Colors.transparent,
                                        child: ListTile(
                                          title: Text(
                                            prayersItem.subtitle,
                                            style: FlutterFlowTheme.of(context)
                                                .labelMedium
                                                .override(
                                                  fontFamily: 'Inter',
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                          trailing: Icon(
                                            Icons.arrow_right,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            size: 16.0,
                                          ),
                                          tileColor:
                                              FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          dense: false,
                                          contentPadding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  12.0, 0.0, 12.0, 0.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        if (subTypesItem.subtypes.isNotEmpty)
                          wrapWithModel(
                            model: _model.subTypesViewModels.getModel(
                              subTypesItem.id.toString(),
                              subTypesIndex,
                            ),
                            updateCallback: () => safeSetState(() {}),
                            child: SubTypesViewWidget(
                              key: Key(
                                'Keyf0l_${subTypesItem.id.toString()}',
                              ),
                              prayerTypes: subTypesItem.subtypes,
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
