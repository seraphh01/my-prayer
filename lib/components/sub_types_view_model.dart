import '/components/sub_types_view_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'sub_types_view_widget.dart' show SubTypesViewWidget;
import 'package:flutter/material.dart';

class SubTypesViewModel extends FlutterFlowModel<SubTypesViewWidget> {
  ///  Local state fields for this component.

  int? currentExpandedType;

  ///  State fields for stateful widgets in this component.

  // Models for SubTypesView dynamic component.
  FlutterFlowDynamicModels<SubTypesViewModel>? _subTypesViewModels;
  FlutterFlowDynamicModels<SubTypesViewModel> get subTypesViewModels =>
      _subTypesViewModels ??=
          FlutterFlowDynamicModels(() => SubTypesViewModel());

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    subTypesViewModels.dispose();
  }
}
