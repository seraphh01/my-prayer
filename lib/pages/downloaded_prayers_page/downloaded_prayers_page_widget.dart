import '/components/empty_downloaded_prayers_list_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
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

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

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
            iconTheme:
                IconThemeData(color: FlutterFlowTheme.of(context).alternate),
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
                            'Rugăciunile descărcate sunt disponibile in mod offline. Le puteți șterge prin acțiunea de slide către stânga. Atenție, ștergerea din această listă nu implică și ștergerea din memorie. Pentru a șterge din memorie, accesați pagina de setări.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(alertDialogContext),
                            child: const Text(FFAppConstants.ConfirmButtonText),
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
          child: Align(
            alignment: const AlignmentDirectional(0.0, -1.0),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
              child: Container(
                width: 400.0,
                height: double.infinity,
                decoration: const BoxDecoration(),
                child: Builder(
                  builder: (context) {
                    final downloadedPrayer =
                        FFAppState().downloadedPrayers.toList();
                    if (downloadedPrayer.isEmpty) {
                      return Center(
                        child: SizedBox(
                          width: double.infinity,
                          height: MediaQuery.sizeOf(context).height * 0.5,
                          child: const EmptyDownloadedPrayersListWidget(),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: downloadedPrayer.length,
                      itemBuilder: (context, downloadedPrayerIndex) {
                        final downloadedPrayerItem =
                            downloadedPrayer[downloadedPrayerIndex];
                        return Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                context.goNamed(
                                  'RosaryPage',
                                  queryParameters: {
                                    'prayerId': serializeParam(
                                      downloadedPrayerItem.id,
                                      ParamType.String,
                                    ),
                                    'downloadedPrayer': serializeParam(
                                      downloadedPrayerItem,
                                      ParamType.DataStruct,
                                    ),
                                  }.withoutNulls,
                                );
                              },
                              child: Slidable(
                                endActionPane: ActionPane(
                                  motion: const ScrollMotion(),
                                  extentRatio: 0.25,
                                  children: [
                                    SlidableAction(
                                      label: 'Sterge',
                                      backgroundColor:
                                          FlutterFlowTheme.of(context).error,
                                      icon: Icons.delete_rounded,
                                      onPressed: (_) async {
                                        FFAppState()
                                            .removeFromDownloadedPrayers(
                                                downloadedPrayerItem);
                                        safeSetState(() {});
                                      },
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: ListTile(
                                    title: Text(
                                      downloadedPrayerItem.title,
                                      style: FlutterFlowTheme.of(context)
                                          .titleLarge
                                          .override(
                                            fontFamily: 'Merriweather',
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                    subtitle: Text(
                                      downloadedPrayerItem.subtitle,
                                      style: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                            fontFamily: 'Inter',
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                    trailing: Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 16.0,
                                    ),
                                    dense: false,
                                    contentPadding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            12.0, 0.0, 12.0, 0.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
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
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
