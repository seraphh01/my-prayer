import '/backend/schema/structs/index.dart';
import '/components/empty_list_component_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'sub_types_view_model.dart';
export 'sub_types_view_model.dart';

class SubTypesViewWidget extends StatefulWidget {
  const SubTypesViewWidget({
    super.key,
    this.prayerTypes,
    required this.onSelectPrayer,
    this.expandAll = false,
  });

  final List<PrayerTypeStruct>? prayerTypes;
  final Future Function(String prayerId)? onSelectPrayer;
  final bool expandAll;

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
        final subTypes = widget.prayerTypes
                ?.sortedList(keyOf: (e) => e.sequence, desc: false)
                .toList() ??
            [];
        if (subTypes.isEmpty) {
          return const Center(
            child: SizedBox(
              width: double.infinity,
              height: 30.0,
              child: EmptyListComponentWidget(
                title: 'Nu s-a putut încărca.',
                subtitle:
                    'Verifică conexiunea la internet sau mergi la rugăciunile descărcate.',
              ),
            ),
          );
        }

        return Column(
          children: [
            Divider(
              height: 1.0,
              thickness: 1.0,
              color: FlutterFlowTheme.of(context).secondary,
            ),
            ListView.builder(
              padding: EdgeInsets.zero,
              primary: false,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: subTypes.length,
              itemBuilder: (context, subTypesIndex) {
                final subTypesItem = subTypes[subTypesIndex];
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 1.0, 2.0),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              if (subTypesItem.prayers.length == 1) {
                                _model.currentExpandedType = null;
                                safeSetState(() {});
                                await widget.onSelectPrayer?.call(
                                  subTypesItem.prayers.firstOrNull!.id,
                                );
                                return;
                              }

                              if (widget.expandAll) {
                                return;
                              }

                              if (_model.currentExpandedType ==
                                  subTypesItem.id) {
                                _model.currentExpandedType = null;
                                safeSetState(() {});
                              } else {
                                _model.currentExpandedType = subTypesItem.id;
                                safeSetState(() {});
                              }
                            },
                            child: Material(
                              color: Colors.transparent,
                              child: ListTile(
                                title: Text(
                                  subTypesItem.type.maybeHandleOverflow(
                                    maxChars: 40,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .override(
                                        fontFamily: 'Merriweather',
                                        color: FlutterFlowTheme.of(context)
                                            .alternate,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                                trailing: Icon(
                                  Icons.keyboard_arrow_right_rounded,
                                  color: FlutterFlowTheme.of(context).alternate,
                                  size: 24.0,
                                ),
                                dense: true,
                                contentPadding:
                                    const EdgeInsetsDirectional.fromSTEB(
                                        12.0, 0.0, 12.0, 0.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Divider(
                          height: 1.0,
                          thickness: 1.0,
                          color: FlutterFlowTheme.of(context).secondary,
                        ),
                      ],
                    ),
                    if (widget.expandAll ||
                        subTypesItem.id == _model.currentExpandedType)
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          if (subTypesItem.prayers.isNotEmpty)
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  8.0, 0.0, 0.0, 0.0),
                              child: Builder(
                                builder: (context) {
                                  final prayers = subTypesItem.prayers
                                      .sortedList(
                                          keyOf: (e) => e.sequence, desc: false)
                                      .toList();

                                  return ListView.builder(
                                    padding: EdgeInsets.zero,
                                    primary: false,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    itemCount: prayers.length,
                                    itemBuilder: (context, prayersIndex) {
                                      final prayersItem = prayers[prayersIndex];
                                      return Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 0.0, 1.0, 2.0),
                                        child: InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            _model.currentExpandedType = null;
                                            safeSetState(() {});
                                            await widget.onSelectPrayer?.call(
                                              prayersItem.id,
                                            );
                                          },
                                          child: Material(
                                            color: Colors.transparent,
                                            child: ListTile(
                                              title: Text(
                                                prayersItem.subtitle,
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .override(
                                                          fontFamily:
                                                              'Merriweather',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .alternate,
                                                          letterSpacing: 0.0,
                                                        ),
                                              ),
                                              trailing: Icon(
                                                Icons
                                                    .keyboard_arrow_right_rounded,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .alternate,
                                                size: 24.0,
                                              ),
                                              dense: true,
                                              contentPadding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(
                                                      12.0, 0.0, 12.0, 0.0),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
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
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  8.0, 0.0, 0.0, 0.0),
                              child: wrapWithModel(
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
                                  expandAll: widget.expandAll,
                                  onSelectPrayer: (prayerId) async {
                                    await widget.onSelectPrayer?.call(
                                      prayerId,
                                    );
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}
