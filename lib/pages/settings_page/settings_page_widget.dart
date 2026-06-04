import 'dart:io';

import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_choice_chips.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/components/reading_text_scroll_settings.dart';
import '/custom_code/actions/index.dart' as actions;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'settings_page_model.dart';
export 'settings_page_model.dart';

class SettingsPageWidget extends StatefulWidget {
  const SettingsPageWidget({super.key});

  @override
  State<SettingsPageWidget> createState() => _SettingsPageWidgetState();
}

class _SettingsPageWidgetState extends State<SettingsPageWidget> {
  late SettingsPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SettingsPageModel());

    // Initialize theme mode
    _model.themeMode = FlutterFlowTheme.themeMode;

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.resultedSize = await actions.computeFolderSize(
        '',
      );
      _model.occupiedStorage = _model.resultedSize;
      safeSetState(() {});
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
    return Selector<FFAppState, (String, double, double, double, bool)>(
      selector: (_, state) => (
        state.fontFamily,
        state.fontSizeMultiplier,
        state.audioSpeed,
        state.readingAnchorAlignment,
        state.textAutoScrollEnabled,
      ),
      builder: (context, _, __) {
        return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64.0),
        child: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          iconTheme:
              IconThemeData(color: FlutterFlowTheme.of(context).alternate),
          title: Text(
            'Setări',
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(1.0, 0.0, 0.0, 0.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    border: Border.all(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        2.0, 16.0, 0.0, 0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              24.0, 0.0, 0.0, 0.0),
                          child: Text(
                            'Viteză de redare',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Inter',
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              24.0, 0.0, 0.0, 0.0),
                          child: Text(
                            'Repornește redarea audio pentru a aplica',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Inter',
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
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
              ),
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(1.0, 0.0, 0.0, 0.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    border: Border.all(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        24.0, 16.0, 24.0, 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stil font',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Inter',
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                  ),
                        ),
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
              ),
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(1.0, 0.0, 0.0, 0.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    border: Border.all(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      width: 1.0,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 16.0, 0.0, 0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              24.0, 0.0, 0.0, 0.0),
                          child: Text(
                            'Mărime font',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Inter',
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
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
              ),
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(1.0, 0.0, 0.0, 0.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    border: Border.all(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      width: 1.0,
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 16.0),
                    child: ReadingTextScrollSettings(
                      showTitle: true,
                      showHint: true,
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(1.0, 0.0, 0.0, 0.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    border: Border.all(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      width: 1.0,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        24.0, 16.0, 24.0, 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Temă aplicație',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Inter',
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                  ),
                        ),
                        Wrap(
                          spacing: 12.0,
                          runSpacing: 8.0,
                          children: [
                            buildThemeChip(
                              context: context,
                              label: themeModeToLabel(AppThemeMode.light),
                              icon: Icons.wb_sunny_outlined,
                              isSelected:
                                  _model.themeMode == AppThemeMode.light,
                              onSelected: () {
                                safeSetState(() =>
                                    _model.themeMode = AppThemeMode.light);
                                setDarkModeSetting(context, AppThemeMode.light);
                              },
                            ),
                            buildThemeChip(
                              context: context,
                              label: themeModeToLabel(AppThemeMode.sepia),
                              icon: Icons.auto_stories_outlined,
                              isSelected:
                                  _model.themeMode == AppThemeMode.sepia,
                              onSelected: () {
                                safeSetState(() =>
                                    _model.themeMode = AppThemeMode.sepia);
                                setDarkModeSetting(context, AppThemeMode.sepia);
                              },
                            ),
                            buildThemeChip(
                              context: context,
                              label: themeModeToLabel(AppThemeMode.dark),
                              icon: Icons.dark_mode_outlined,
                              isSelected: _model.themeMode == AppThemeMode.dark,
                              onSelected: () {
                                safeSetState(
                                    () => _model.themeMode = AppThemeMode.dark);
                                setDarkModeSetting(context, AppThemeMode.dark);
                              },
                            ),
                            buildThemeChip(
                              context: context,
                              label: themeModeToLabel(AppThemeMode.system),
                              icon: Icons.settings_suggest_outlined,
                              isSelected:
                                  _model.themeMode == AppThemeMode.system,
                              onSelected: () {
                                safeSetState(() =>
                                    _model.themeMode = AppThemeMode.system);
                                setDarkModeSetting(
                                    context, AppThemeMode.system);
                              },
                            ),
                          ],
                        ),
                        if (_model.themeMode == AppThemeMode.system)
                          Text(
                            'Auto - se sincronizează cu tema telefonului dumneavoastră (folosește Sepia pentru luminos și Întunecat pentru întunecat).',
                            style:
                                FlutterFlowTheme.of(context).bodySmall.override(
                                      fontFamily: 'Inter',
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      letterSpacing: 0.0,
                                    ),
                          ),
                      ].divide(const SizedBox(height: 12.0)),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: !kIsWeb,
                child: Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(1.0, 0.0, 0.0, 0.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primaryBackground,
                      border: Border.all(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        width: 1.0,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          24.0, 16.0, 24.0, 16.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.sizeOf(context).width * 0.7,
                            decoration: const BoxDecoration(),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Eliberează spațiul de stocare',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                                Text(
                                  'Descărcările ocupă ${((_model.occupiedStorage!) / (1024 * 1024)).toStringAsFixed(2)} MB în memorie.',
                                  style: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          FlutterFlowIconButton(
                            borderRadius: 8.0,
                            buttonSize: 40.0,
                            disabledIconColor: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            icon: Icon(
                              Icons.delete_rounded,
                              color: FlutterFlowTheme.of(context).primary,
                              size: 24.0,
                            ),
                            onPressed: (_model.occupiedStorage! <= 0)
                                ? null
                                : () async {
                                    var confirmDialogResponse =
                                        await showDialog<bool>(
                                              context: context,
                                              builder: (alertDialogContext) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      'Eliberare spațiu de stocare'),
                                                  content: Text(
                                                      'Această acțiune va șterge descărcările din memoria telefonului. Vei elibera ${((_model.occupiedStorage!) / (1024 * 1024)).toStringAsFixed(2)} MB, iar rugăciunile nu vor mai fi disponibile fără conexiune la internet.'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              alertDialogContext,
                                                              false),
                                                      child: const Text(
                                                          'Anulează'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              alertDialogContext,
                                                              true),
                                                      child: const Text(
                                                          'Eliberează spațiul'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ) ??
                                            false;
                                    if (confirmDialogResponse) {
                                      _model.success =
                                          await actions.deleteFileOrFolder(
                                        '',
                                        '',
                                      );
                                      if (_model.success!) {
                                        FFAppState().deleteDownloadedPrayers();
                                        FFAppState().downloadedPrayers = [];

                                        FFAppState().update(() {});
                                        _model.occupiedStorage = 0;
                                        safeSetState(() {});
                                      } else {
                                        await showDialog(
                                          context: context,
                                          builder: (alertDialogContext) {
                                            return AlertDialog(
                                              title: const Text(
                                                  'A apărut o eroare!'),
                                              content: const Text(
                                                  'Spațiul de stocare nu a putut fi eliberat. Încearcă să îl eliberezi din setările telefonului.'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          alertDialogContext),
                                                  child: const Text('Ok'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    }

                                    safeSetState(() {});
                                  },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Generated code for this Container Widget...
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(1.0, 0.0, 0.0, 0.0),
                child: InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    context.pushNamed(
                      'PrivacyPolicyPage',
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
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primaryBackground,
                      border: Border.all(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        width: 1.0,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          24.0, 16.0, 24.0, 16.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.sizeOf(context).width * 0.7,
                            decoration: const BoxDecoration(),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Politica de confidențialite',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          FlutterFlowIconButton(
                            borderColor: Colors.transparent,
                            borderRadius: 8.0,
                            buttonSize: 40.0,
                            disabledIconColor: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            icon: Icon(
                              Icons.privacy_tip_rounded,
                              color: FlutterFlowTheme.of(context).primary,
                              size: 24.0,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(1.0, 0.0, 0.0, 0.0),
                child: InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: isWeb
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor:
                                FlutterFlowTheme.of(context).primaryBackground,
                            content: Text(
                              'Aplicația este actualizată la ultima versiune.',
                              style: TextStyle(
                                color: FlutterFlowTheme.of(context).alternate,
                              ),
                            ),
                          ));
                        }
                      : () async {
                          var url = Platform.isAndroid
                              ? 'https://play.google.com/store/apps/details?id=com.surorilecmd.rugaciunisicantari'
                              : 'https://apps.apple.com/app/rugaciunisicantaricmd/id6758237098';
                          await launchURL(url);
                        },
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primaryBackground,
                      border: Border.all(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        width: 1.0,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          24.0, 16.0, 24.0, 16.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.sizeOf(context).width * 0.7,
                            decoration: const BoxDecoration(),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Verifică actualizările aplicației',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                                Text(
                                  'Versiunea curentă: 1.0.0',
                                  style: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .override(
                                        fontFamily: 'Inter',
                                        fontSize: 14.0,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          FlutterFlowIconButton(
                            borderColor: Colors.transparent,
                            borderRadius: 8.0,
                            buttonSize: 40.0,
                            disabledIconColor: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            icon: Icon(
                              Icons.update_rounded,
                              color: FlutterFlowTheme.of(context).primary,
                              size: 24.0,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 32.0, 0.0, 0.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    Theme.of(context).brightness == Brightness.dark
                        ? 'assets/images/logo-cmd-transparent-white.png'
                        : 'assets/images/logo-cmd-transparent.png',
                    width: 200.0,
                    height: 200.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 32.0, 0.0, 32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          16.0, 0.0, 16.0, 0.0),
                      child: AutoSizeText(
                        'CONGREGAȚIA SURORILOR MAICII DOMNULUI',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        minFontSize: 12.0,
                        style: FlutterFlowTheme.of(context).titleSmall.override(
                              fontFamily: 'Merriweather',
                              letterSpacing: 0.0,
                            ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          16.0, 0.0, 16.0, 0.0),
                      child: AutoSizeText(
                        'Str. Romul Ladea, nr. 6, 400481, Cluj-Napoca',
                        maxLines: 1,
                        minFontSize: 10.0,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Inter',
                              letterSpacing: 0.0,
                            ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            await launchURL('https://surorile-cmd.ro/ro/');
                          },
                          child: Text(
                            'www.surorile-cmd.ro',
                            maxLines: 1,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Inter',
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                        Icon(
                          Icons.exit_to_app_rounded,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 16.0,
                        ),
                      ].divide(const SizedBox(width: 4.0)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
      },
    );
  }
}
