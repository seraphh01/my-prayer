import 'package:my_prayer/flutter_flow/flutter_flow_choice_chips.dart';
import 'package:my_prayer/flutter_flow/form_field_controller.dart';

import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'prayer_options_model.dart';
export 'prayer_options_model.dart';

class PrayerOptionsWidget extends StatefulWidget {
  const PrayerOptionsWidget({
    super.key,
    required this.prayer,
    bool? enableDownloadButton,
    int? currentPageIndex,
  })  : enableDownloadButton = enableDownloadButton ?? false,
        currentPageIndex = currentPageIndex ?? 0;

  final PrayerStruct? prayer;
  final bool enableDownloadButton;
  final int currentPageIndex;

  @override
  State<PrayerOptionsWidget> createState() => _PrayerOptionsWidgetState();
}

class _PrayerOptionsWidgetState extends State<PrayerOptionsWidget> {
  late PrayerOptionsModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PrayerOptionsModel());

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
    _model.themeMode ??= FlutterFlowTheme.themeMode;

    return Material(
      color: Colors.transparent,
      elevation: 0.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0.0),
          bottomRight: Radius.circular(0.0),
          topLeft: Radius.circular(8.0),
          topRight: Radius.circular(8.0),
        ),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryBackground,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(0.0),
            bottomRight: Radius.circular(0.0),
            topLeft: Radius.circular(8.0),
            topRight: Radius.circular(8.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primaryBackground,
                
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        24.0, 16.0, 24.0, 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: const AlignmentDirectional(0.0, 0.0),
                          child: Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(),
                            child: FlutterFlowChoiceChips(
                              options: const [
                                ChipData('Crimson Pro'),
                                ChipData('Patrick Hand'),
                                ChipData('Tinos'),
                                ChipData('Inter')
                              ],
                              onChanged: (val) async {
                                safeSetState(() =>
                                    _model.choiceChipsValue = val?.firstOrNull);
                                FFAppState().fontFamily =
                                    _model.choiceChipsValue!;
                                safeSetState(() {});
                              },
                              selectedChipStyle: ChipStyle(
                                backgroundColor:
                                    FlutterFlowTheme.of(context).primary,
                                textStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Inter',
                                      color: Colors.white,
                                      letterSpacing: 0.0,
                                    ),
                                iconColor: Colors.white,
                                iconSize: 18.0,
                                elevation: 0.0,
                                borderRadius: BorderRadius.circular(8.0),
                                
                              ),
                              unselectedChipStyle: ChipStyle(
                                backgroundColor: const Color(0x00000000),
                                textStyle: FlutterFlowTheme.of(context)
                                    .bodySmall
                                    .override(
                                      fontFamily: 'Inter',
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      letterSpacing: 0.0,
                                    ),
                                iconColor: Colors.white,
                                iconSize: 18.0,
                                elevation: 0.0,
                                borderRadius: BorderRadius.circular(8.0),
                                borderWidth: 0.6,
                                borderColor: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                              ),
                              chipSpacing: 16.0,
                              rowSpacing: 8.0,
                              multiselect: false,
                              initialized: _model.choiceChipsValue != null,
                              alignment: WrapAlignment.spaceBetween,
                              controller: _model.choiceChipsValueController ??=
                                  FormFieldController<List<String>>(
                                [FFAppState().fontFamily],
                              ),
                              wrapped: false,
                            ),
                          ),
                        ),
                      ].divide(const SizedBox(height: 16.0)),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(1.0, 0.0, 0.0, 0.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.transparent,
                        width: 0.0,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 16.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    12.0, 0.0, 8.0, 0.0),
                                child: Icon(
                                  Icons.format_size,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  size: 16.0,
                                ),
                              ),
                              Expanded(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Slider.adaptive(
                                    activeColor:
                                        FlutterFlowTheme.of(context).primary,
                                    inactiveColor: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    min: 0.75,
                                    max: 2.0,
                                    value: _model.fontSizeSliderValue ??=
                                        valueOrDefault<double>(
                                      FFAppState().fontSizeMultiplier,
                                      0.75,
                                    ),
                                    label:
                                        _model.fontSizeSliderValue?.toString(),
                                    divisions: 10,
                                    onChanged: (newValue) {
                                      safeSetState(() => _model
                                          .fontSizeSliderValue = newValue);
                                    },
                                    onChangeEnd: (newValue) async {
                                      safeSetState(() => _model
                                          .fontSizeSliderValue = newValue);
                                      FFAppState().fontSizeMultiplier =
                                          valueOrDefault<double>(
                                        _model.fontSizeSliderValue,
                                        1.0,
                                      );
                                      FFAppState().update(() {});
                                    },
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.format_size,
                                color: FlutterFlowTheme.of(context).primaryText,
                                size: 24.0,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(1.0, 0.0, 0.0, 0.0),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 16.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                '0.75X',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Inter',
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              Expanded(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Slider.adaptive(
                                    activeColor:
                                        FlutterFlowTheme.of(context).primary,
                                    inactiveColor: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    min: 0.75,
                                    max: 2.0,
                                    value: _model.audioSpeedSliderValue ??=
                                        FFAppState().audioSpeed,
                                    label: _model.audioSpeedSliderValue
                                        ?.toString(),
                                    divisions: 5,
                                    onChanged: (newValue) {
                                      safeSetState(() => _model
                                          .audioSpeedSliderValue = newValue);
                                    },
                                    onChangeEnd: (newValue) async {
                                      safeSetState(() => _model
                                          .audioSpeedSliderValue = newValue);
                                      FFAppState().audioSpeed =
                                          valueOrDefault<double>(
                                        _model.audioSpeedSliderValue,
                                        1.0,
                                      );
                                      FFAppState().update(() {});
                                    },
                                  ),
                                ),
                              ),
                              Text(
                                '2X',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Inter',
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      1.0, 0.0, 0.0, 0.0),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            24.0, 12.0, 24.0, 8.0),
                        child: Wrap(
                          spacing: 12.0,
                          runSpacing: 8.0,
                          children: [
                            buildThemeChip(
                              context: context,
                              label: themeModeToLabel(AppThemeMode.light),
                              icon: Icons.light_mode_outlined,
                              isSelected: _model.themeMode == AppThemeMode.light,
                              onSelected: () {               
                                safeSetState(() =>
                                    _model.themeMode = AppThemeMode.light);
                                setDarkModeSetting(context, AppThemeMode.light);
                              },
                            ),
                            buildThemeChip(
                              context: context,
                              label: themeModeToLabel(  AppThemeMode.sepia),
                              icon: Icons.dark_mode_outlined,
                              isSelected: _model.themeMode == AppThemeMode.sepia,
                              onSelected: () {
                                safeSetState(() =>
                                    _model.themeMode = AppThemeMode.sepia);
                                setDarkModeSetting(context, AppThemeMode.sepia);
                              },
                            ),
                            buildThemeChip(
                              context: context,
                              label: themeModeToLabel(  AppThemeMode.dark),
                              icon: Icons.dark_mode_outlined,
                              isSelected: _model.themeMode == AppThemeMode.dark,
                              onSelected: () {
                                safeSetState(() =>
                                    _model.themeMode = AppThemeMode.dark);
                                setDarkModeSetting(context, AppThemeMode.dark);
                              },
                            ),
                            buildThemeChip(
                              context: context,
                              label: themeModeToLabel(AppThemeMode.system),
                              icon: Icons.settings_suggest_outlined,
                              isSelected: _model.themeMode == AppThemeMode.system,
                              onSelected: () {
                                safeSetState(() =>
                                    _model.themeMode = AppThemeMode.system);
                                setDarkModeSetting(context, AppThemeMode.system);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: const AlignmentDirectional(0.0, 0.0),
              child: Container(
                decoration: const BoxDecoration(),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      0.0, 16.0, 0.0, 16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (!isWeb)
                        FlutterFlowIconButton(
                          borderColor: Colors.transparent,
                          borderRadius: 20.0,
                          buttonSize: 40.0,
                          fillColor: FlutterFlowTheme.of(context).primary,
                          disabledColor:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          disabledIconColor:
                              FlutterFlowTheme.of(context).alternate,
                          icon: Icon(
                            Icons.download_rounded,
                            color: FlutterFlowTheme.of(context).alternate,
                            size: 24.0,
                          ),
                          onPressed: !widget.enableDownloadButton
                              ? null
                              : () async {
                                  Navigator.pop(context, 'download');
                                },
                        ),
                      Builder(
                        builder: (context) {
                          if (FFAppState()
                                  .favoritePrayers
                                  .contains(widget.prayer) ==
                              true) {
                            return FlutterFlowIconButton(
                              borderColor: Colors.transparent,
                              borderRadius: 20.0,
                              buttonSize: 40.0,
                              fillColor: FlutterFlowTheme.of(context).primary,
                              icon: Icon(
                                Icons.favorite_rounded,
                                color: FlutterFlowTheme.of(context).alternate,
                                size: 24.0,
                              ),
                              onPressed: () async {
                                FFAppState()
                                    .removeFromFavoritePrayers(widget.prayer!);
                                safeSetState(() {});
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${widget.prayer?.title} - ${widget.prayer?.subtitle} nu mai este in lista de favorite!',
                                      style: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                            fontFamily: 'Inter',
                                            color: Colors.white,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                    duration:
                                        const Duration(milliseconds: 2500),
                                    backgroundColor:
                                        FlutterFlowTheme.of(context).secondary,
                                  ),
                                );
                              },
                            );
                          } else {
                            return FlutterFlowIconButton(
                              borderColor: Colors.transparent,
                              borderRadius: 20.0,
                              buttonSize: 40.0,
                              fillColor: FlutterFlowTheme.of(context).primary,
                              icon: Icon(
                                Icons.favorite_border_rounded,
                                color: FlutterFlowTheme.of(context).alternate,
                                size: 24.0,
                              ),
                              onPressed: () async {
                                FFAppState()
                                    .addToFavoritePrayers(widget.prayer!);
                                safeSetState(() {});
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${widget.prayer?.title} - ${widget.prayer?.subtitle} a fost salvată în lista de favorite!',
                                      style: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                            fontFamily: 'Inter',
                                            color: Colors.white,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                    duration:
                                        const Duration(milliseconds: 2500),
                                    backgroundColor:
                                        FlutterFlowTheme.of(context).success,
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
                      Builder(
                        builder: (context) {
                          if (valueOrDefault<bool>(
                            (FFAppState().savedPrayer.prayer?.id ==
                                    widget.prayer?.id) &&
                                (widget.currentPageIndex ==
                                    FFAppState().savedPrayer.page),
                            false,
                          )) {
                            return FlutterFlowIconButton(
                              borderColor: Colors.transparent,
                              borderRadius: 20.0,
                              buttonSize: 40.0,
                              fillColor: FlutterFlowTheme.of(context).primary,
                              icon: Icon(
                                Icons.bookmark_rounded,
                                color: FlutterFlowTheme.of(context).alternate,
                                size: 24.0,
                              ),
                              onPressed: () async {
                                Navigator.pop(context, 'clear_save');
                              },
                            );
                          } else {
                            return FlutterFlowIconButton(
                              borderColor: Colors.transparent,
                              borderRadius: 20.0,
                              buttonSize: 40.0,
                              fillColor: FlutterFlowTheme.of(context).primary,
                              icon: Icon(
                                Icons.bookmark_border_rounded,
                                color: FlutterFlowTheme.of(context).alternate,
                                size: 24.0,
                              ),
                              onPressed: () async {
                                Navigator.pop(context, 'save');
                              },
                            );
                          }
                        },
                      ),
                      FlutterFlowIconButton(
                        borderColor: Colors.transparent,
                        borderRadius: 20.0,
                        buttonSize: 40.0,
                        fillColor: FlutterFlowTheme.of(context).primary,
                        icon: Icon(
                          Icons.share_rounded,
                          color: FlutterFlowTheme.of(context).alternate,
                          size: 24.0,
                        ),
                        onPressed: () async {
                          Navigator.pop(context, 'share');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
