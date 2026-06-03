import '/app_state.dart';
import '/backend/schema/structs/index.dart';
import '/components/empty_favorite_prayers_list_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'favorite_prayers_page_model.dart';
export 'favorite_prayers_page_model.dart';

class FavoritePrayersPageWidget extends StatefulWidget {
  const FavoritePrayersPageWidget({super.key});

  @override
  State<FavoritePrayersPageWidget> createState() =>
      _FavoritePrayersPageWidgetState();
}

class _FavoritePrayersPageWidgetState extends State<FavoritePrayersPageWidget> {
  late FavoritePrayersPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FavoritePrayersPageModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final list = FFAppState().favoritePrayers.toList();
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    FFAppState().favoritePrayers = list;
    safeSetState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Selector<FFAppState, List<PrayerStruct>>(
      selector: (_, state) => state.favoritePrayers,
      builder: (context, favoritePrayers, _) {
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
              'Rugăciuni favorite',
              maxLines: 1,
              minFontSize: 18.0,
              style: FlutterFlowTheme.of(context).titleLarge.override(
                    fontFamily: 'Merriweather',
                    color: FlutterFlowTheme.of(context).alternate,
                    letterSpacing: 0.0,
                  ),
            ),
            actions: [
              FlutterFlowIconButton(
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
                        title: const Text('Rugăciuni favorite'),
                        content: const Text(
                            'Trage cu degetul pentru a reordona. Trage spre stânga pentru ștergere. Rugăciunile descărcate au pictograma offline.'),
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
                    if (favoritePrayers.isEmpty) {
                      return Center(
                        child: SizedBox(
                          width: double.infinity,
                          height: MediaQuery.sizeOf(context).height * 0.5,
                          child: const EmptyFavoritePrayersListWidget(),
                        ),
                      );
                    }

                    return ReorderableListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: favoritePrayers.length,
                      onReorder: _onReorder,
                      itemBuilder: (context, index) {
                        final item = favoritePrayers[index];
                        final downloaded = FFAppState()
                            .downloadedPrayers
                            .any((p) => p.id == item.id);

                        return Column(
                          key: ValueKey(item.id),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Slidable(
                              endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                extentRatio: 0.25,
                                children: [
                                  SlidableAction(
                                    label: 'Șterge',
                                    backgroundColor:
                                        FlutterFlowTheme.of(context).error,
                                    icon: Icons.favorite_border_rounded,
                                    onPressed: (_) {
                                      FFAppState()
                                          .removeFavoriteById(item.id);
                                      safeSetState(() {});
                                    },
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: ListTile(
                                  onTap: () {
                                    context.pushNamed(
                                      'RosaryPage',
                                      queryParameters: {
                                        'prayerId': item.id,
                                      }.withoutNulls,
                                    );
                                  },
                                  leading: ReorderableDragStartListener(
                                    index: index,
                                    child: Icon(
                                      Icons.drag_handle_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                    ),
                                  ),
                                  title: Text(
                                    item.title.isNotEmpty
                                        ? item.title
                                        : item.subtitle,
                                    style: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .override(
                                          fontFamily: FFAppState().fontFamily,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                  subtitle: item.title.isNotEmpty &&
                                          item.title != item.subtitle
                                      ? Text(
                                          item.subtitle,
                                          style: FlutterFlowTheme.of(context)
                                              .labelMedium
                                              .override(
                                                fontFamily: 'Inter',
                                                letterSpacing: 0.0,
                                              ),
                                        )
                                      : null,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (downloaded)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 8.0),
                                          child: Icon(
                                            Icons.offline_pin_rounded,
                                            color: FlutterFlowTheme.of(context)
                                                .success,
                                            size: 22.0,
                                          ),
                                        ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        size: 16.0,
                                      ),
                                    ],
                                  ),
                                  contentPadding:
                                      const EdgeInsetsDirectional.fromSTEB(
                                          4.0, 0.0, 12.0, 0.0),
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
      },
    );
  }
}
