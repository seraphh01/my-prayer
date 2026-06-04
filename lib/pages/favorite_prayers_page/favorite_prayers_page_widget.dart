import '/app_state.dart';
import '/backend/schema/structs/index.dart';
import '/components/empty_favorite_prayers_list_widget.dart';
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

  List<IconData> _favoriteTrailingIcons({
    required PrayerStruct prayer,
    required bool downloaded,
  }) {
    return [
      if (downloaded) Icons.offline_pin_rounded,
      ...prayerCardTrailingIcons(prayer),
    ];
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
                iconTheme: IconThemeData(
                  color: FlutterFlowTheme.of(context).alternate,
                ),
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
                              'Trage cu degetul pentru a reordona. Trage spre stânga pentru ștergere. Rugăciunile descărcate au pictograma offline.',
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
              child: favoritePrayers.isEmpty
                  ? Center(
                      child: SizedBox(
                        width: double.infinity,
                        height: MediaQuery.sizeOf(context).height * 0.5,
                        child: const EmptyFavoritePrayersListWidget(),
                      ),
                    )
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
                      itemCount: favoritePrayers.length,
                      onReorder: _onReorder,
                      proxyDecorator: (child, index, animation) {
                        return Material(
                          color: Colors.transparent,
                          elevation: 6.0,
                          shadowColor: FlutterFlowTheme.of(context)
                              .primary
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16.0),
                          child: child,
                        );
                      },
                      itemBuilder: (context, index) {
                        final prayer = favoritePrayers[index];
                        final cardLines = prayerCardTitleAndSubtitle(prayer);
                        final downloaded = FFAppState()
                            .downloadedPrayers
                            .any((p) => p.id == prayer.id);

                        return Material(
                          key: ValueKey(prayer.id),
                          color: Colors.transparent,
                          child: Padding(
                          padding: EdgeInsets.only(
                            bottom: index < favoritePrayers.length - 1
                                ? 12.0
                                : 0.0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ReorderableDragStartListener(
                                index: index,
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    end: 8.0,
                                  ),
                                  child: Icon(
                                    Icons.drag_handle_rounded,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Slidable(
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
                                              .removeFavoriteById(prayer.id);
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
                                    trailingIcons: _favoriteTrailingIcons(
                                      prayer: prayer,
                                      downloaded: downloaded,
                                    ),
                                    onTap: () =>
                                        unawaited(_openPrayer(prayer.id)),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
