import '/components/app_drawer_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'canonic_prayers_page_widget.dart' show CanonicPrayersPageWidget;
import 'package:flutter/material.dart';

class CanonicPrayersPageModel
    extends FlutterFlowModel<CanonicPrayersPageWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;

  // Model for AppDrawer component.
  AppDrawerModel? _appDrawerModel;
  AppDrawerModel get appDrawerModel => _appDrawerModel ??= AppDrawerModel();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    tabBarController?.dispose();
    appDrawerModel.dispose();
  }
}
