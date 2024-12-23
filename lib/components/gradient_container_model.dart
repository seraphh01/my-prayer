import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/instant_timer.dart';
import 'gradient_container_widget.dart' show GradientContainerWidget;
import 'package:flutter/material.dart';

class GradientContainerModel extends FlutterFlowModel<GradientContainerWidget> {
  ///  Local state fields for this component.

  int? angle = 0;

  int? incrementValue = 1;

  ///  State fields for stateful widgets in this component.

  InstantTimer? angleIncrementTimer;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    angleIncrementTimer?.cancel();
  }
}
