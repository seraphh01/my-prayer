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

  static const String _fallbackPrayerLabel = 'Rugăciune';

  String _prayerTitle(PrayerStruct prayer) {
    if (prayer.title.isNotEmpty) {
      return prayer.title;
    }
    if (prayer.subtitle.isNotEmpty) {
      return prayer.subtitle;
    }
    return _fallbackPrayerLabel;
  }

  String? _prayerSubtitle(PrayerStruct prayer) {
    if (prayer.subtitle.isEmpty) {
      return null;
    }
    if (prayer.title.isEmpty) {
      return null;
    }
    if (prayer.subtitle.trim().toLowerCase() ==
        prayer.title.trim().toLowerCase()) {
      return null;
    }
    return prayer.subtitle;
  }

  String _typeRowTitle(PrayerTypeStruct type) {
    if (type.prayers.length == 1 && type.subtypes.isEmpty) {
      return _prayerTitle(type.prayers.first);
    }
    return type.type.isNotEmpty ? type.type : _fallbackPrayerLabel;
  }

  String? _typeRowSubtitle(PrayerTypeStruct type) {
    if (type.prayers.length == 1 && type.subtypes.isEmpty) {
      final prayer = type.prayers.first;
      final prayerSubtitle = _prayerSubtitle(prayer);
      if (prayerSubtitle != null) {
        return prayerSubtitle;
      }
      if (type.type.isNotEmpty &&
          type.type.trim().toLowerCase() !=
              _prayerTitle(prayer).trim().toLowerCase()) {
        return type.type;
      }
      return null;
    }
    return null;
  }

  Widget _buildNavListTile({
    required BuildContext context,
    required String title,
    String? subtitle,
    bool useCompactPrayerStyle = false,
  }) {
    final theme = FlutterFlowTheme.of(context);
  final titleStyle = useCompactPrayerStyle
        ? theme.titleSmall
        : theme.titleMedium;

    return Material(
      color: Colors.transparent,
      child: ListTile(
        title: Text(
          title.maybeHandleOverflow(maxChars: 80),
          style: titleStyle.override(
            fontFamily: 'Merriweather',
            color: theme.primaryText,
            letterSpacing: 0.0,
          ),
        ),
        subtitle: subtitle == null || subtitle.isEmpty
            ? null
            : Text(
                subtitle.maybeHandleOverflow(maxChars: 80),
                style: theme.labelMedium.override(
                  fontFamily: 'Inter',
                  color: theme.secondaryText,
                  letterSpacing: 0.0,
                ),
              ),
        trailing: Icon(
          Icons.keyboard_arrow_right_rounded,
          color: useCompactPrayerStyle ? theme.secondaryText : theme.secondary,
          size: 24.0,
        ),
        dense: true,
        contentPadding: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0.0),
        ),
      ),
    );
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
                            child: _buildNavListTile(
                              context: context,
                              title: _typeRowTitle(subTypesItem),
                              subtitle: _typeRowSubtitle(subTypesItem),
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
                                          child: _buildNavListTile(
                                            context: context,
                                            title: _prayerTitle(prayersItem),
                                            subtitle:
                                                _prayerSubtitle(prayersItem),
                                            useCompactPrayerStyle: true,
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
