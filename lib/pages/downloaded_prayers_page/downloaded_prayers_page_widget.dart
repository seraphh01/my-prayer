import '/backend/schema/structs/index.dart';
import '/components/empty_downloaded_prayers_list_widget.dart';
import '/components/prayer_type_card_widget.dart';
import '/custom_code/prayer/prayer_card_lines.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'downloaded_prayers_page_model.dart';
export 'downloaded_prayers_page_model.dart';

class DownloadedPrayersPageWidget extends StatefulWidget {
  const DownloadedPrayersPageWidget({super.key});

  @override
  State<DownloadedPrayersPageWidget> createState() =>
      _DownloadedPrayersPageWidgetState();
}

class _DownloadedPrayersPageWidgetState
    extends State<DownloadedPrayersPageWidget> {
  late DownloadedPrayersPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DownloadedPrayersPageModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<void> _openPrayer(String prayerId) async {
    await context.pushNamed(
      'RosaryPage',
      queryParameters: {
        'prayerId': serializeParam(
          prayerId,
          ParamType.String,
        ),
      }.withoutNulls,
      extra: <String, dynamic>{
        kTransitionInfoKey: const TransitionInfo(
          hasTransition: true,
          transitionType: PageTransitionType.fade,
          duration: Duration(milliseconds: 250),
        ),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector<FFAppState, List<PrayerStruct>>(
      selector: (_, state) => state.downloadedPrayers,
      builder: (context, downloadedPrayer, _) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(64.0),
              child: AppBar(
                backgroundColor: FlutterFlowTheme.of(context).primary,
                iconTheme: IconThemeData(
                  color: FlutterFlowTheme.of(context).alternate,
                ),
                automaticallyImplyLeading: true,
                title: AutoSizeText(
                  'Rugăciuni descărcate',
                  maxLines: 1,
                  minFontSize: 16.0,
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                        fontFamily: 'Merriweather',
                        color: FlutterFlowTheme.of(context).alternate,
                        letterSpacing: 0.0,
                      ),
                ),
                actions: [
                  FlutterFlowIconButton(
                    borderColor: Colors.transparent,
                    borderRadius: 8.0,
                    buttonSize: 64.0,
                    icon: Icon(
                      Icons.info_outline_rounded,
                      color: FlutterFlowTheme.of(context).alternate,
                      size: 24.0,
                    ),
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (alertDialogContext) {
                          return AlertDialog(
                            title: const Text('Rugăciuni descărcate'),
                            content: const Text(
                              'Rugăciunile descărcate sunt disponibile in mod offline. Le puteți șterge prin acțiunea de slide către stânga. Atenție, ștergerea din această listă nu implică și ștergerea din memorie. Pentru a șterge din memorie, accesați pagina de setări.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(alertDialogContext),
                                child:
                                    const Text(FFAppConstants.ConfirmButtonText),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
                centerTitle: true,
                toolbarHeight: 64.0,
                elevation: 0.0,
              ),
            ),
            body: SafeArea(
              top: true,
              child: downloadedPrayer.isEmpty
                  ? Center(
                      child: SizedBox(
                        width: double.infinity,
                        height: MediaQuery.sizeOf(context).height * 0.5,
                        child: const EmptyDownloadedPrayersListWidget(),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        16.0,
                        16.0,
                        16.0,
                        24.0,
                      ),
                      itemCount: downloadedPrayer.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12.0),
                      itemBuilder: (context, index) {
                        final prayer = downloadedPrayer[index];
                        final cardLines = prayerCardTitleAndSubtitle(prayer);

                        return Slidable(
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            extentRatio: 0.25,
                            children: [
                              SlidableAction(
                                label: 'Șterge',
                                backgroundColor:
                                    FlutterFlowTheme.of(context).error,
                                icon: Icons.delete_rounded,
                                onPressed: (_) {
                                  FFAppState()
                                      .removeFromDownloadedPrayers(prayer);
                                  safeSetState(() {});
                                },
                              ),
                            ],
                          ),
                          child: PrayerTypeCardWidget(
                            onLightBackground: true,
                            title: cardLines.$1,
                            subtitle: cardLines.$2,
                            trailingText: null,
                            trailingIcons: prayerCardTrailingIcons(prayer),
                            onTap: () => unawaited(_openPrayer(prayer.id)),
                          ),
                        );
                      },
                    ),
            ),
          ),
        );
      },
    );
  }
}
