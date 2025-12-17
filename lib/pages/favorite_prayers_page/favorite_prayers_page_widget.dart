import '/components/empty_favorite_prayers_list_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
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
                            'Aici apar rugăciunile pe care le salvezi ca favorite. Pentru a șterge o rugăciune de la favorite, trage spre stânga și apasă butonul \"Șterge\". Rugaciunile favorite nu sunt disponibile in mod offline decât dacă au fost descărcate anterior.'),
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
                    final favoritePrayer =
                        FFAppState().favoritePrayers.toList();
                    if (favoritePrayer.isEmpty) {
                      return Center(
                        child: SizedBox(
                          width: double.infinity,
                          height: MediaQuery.sizeOf(context).height * 0.5,
                          child: const EmptyFavoritePrayersListWidget(),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: favoritePrayer.length,
                      itemBuilder: (context, favoritePrayerIndex) {
                        final favoritePrayerItem =
                            favoritePrayer[favoritePrayerIndex];
                        return Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () {
                                context.pushReplacementNamed('RosaryPage',
                                    queryParameters: {
                                      'prayerId': favoritePrayerItem.id,
                                    }.withoutNulls);
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
                                      icon: Icons.favorite_border_rounded,
                                      onPressed: (_) async {
                                        FFAppState().removeFromFavoritePrayers(
                                            favoritePrayerItem);
                                        safeSetState(() {});
                                      },
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: ListTile(
                                    title: Text(
                                      favoritePrayerItem.title.isNotEmpty
                                          ? favoritePrayerItem.title
                                          : favoritePrayerItem.subtitle,
                                      style: FlutterFlowTheme.of(context)
                                          .titleLarge
                                          .override(
                                            fontFamily: FFAppState().fontFamily,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                    subtitle: favoritePrayerItem
                                                .title.isNotEmpty &&
                                            favoritePrayerItem.title !=
                                                favoritePrayerItem.subtitle
                                        ? Text(
                                            favoritePrayerItem.subtitle,
                                            style: FlutterFlowTheme.of(context)
                                                .labelMedium
                                                .override(
                                                  fontFamily: 'Inter',
                                                  letterSpacing: 0.0,
                                                ),
                                          )
                                        : null,
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
