import '/components/sub_types_view_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/backend/schema/structs/index.dart';
import 'package:my_prayer/custom_code/prayer/prayer_types_cache.dart';
import 'package:my_prayer/service_locator.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'all_prayers_page_model.dart';
export 'all_prayers_page_model.dart';

class AllPrayersPageWidget extends StatefulWidget {
  const AllPrayersPageWidget({super.key});

  @override
  State<AllPrayersPageWidget> createState() => _AllPrayersPageWidgetState();
}

class _AllPrayersPageWidgetState extends State<AllPrayersPageWidget> {
  late AllPrayersPageModel _model;
  final _typesCache = getIt<PrayerTypesCache>();
  List<PrayerTypeStruct>? _prayerTypes;
  bool _loading = true;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AllPrayersPageModel());
    unawaited(_loadTypes());
  }

  Future<void> _loadTypes({bool forceRefresh = false}) async {
    setState(() => _loading = true);
    _prayerTypes = await _typesCache.load(forceRefresh: forceRefresh);
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primary,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(64.0),
          child: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).primary,
            iconTheme:
                IconThemeData(color: FlutterFlowTheme.of(context).alternate),
            automaticallyImplyLeading: true,
            title: Text(
              'Toate rugăciunile',
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
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 8.0),
            child: _loading && (_prayerTypes == null || _prayerTypes!.isEmpty)
                ? Center(
                    child: SizedBox(
                      width: 24.0,
                      height: 24.0,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          FlutterFlowTheme.of(context).primary,
                        ),
                      ),
                    ),
                  )
                : RefreshIndicator(
                    color: FlutterFlowTheme.of(context).primary,
                    onRefresh: () => _loadTypes(forceRefresh: true),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.zero,
                      child: _prayerTypes != null && _prayerTypes!.isNotEmpty
                          ? SubTypesViewWidget(
                              prayerTypes: _prayerTypes!,
                              onSelectPrayer: (prayerId) async {
                                context.pushReplacementNamed(
                                  'RosaryPage',
                                  queryParameters: {
                                    'prayerId': prayerId,
                                  }.withoutNulls,
                                );
                              },
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
