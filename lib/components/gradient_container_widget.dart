import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/instant_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'gradient_container_model.dart';
export 'gradient_container_model.dart';

class GradientContainerWidget extends StatefulWidget {
  const GradientContainerWidget({
    super.key,
    int? minAngle,
    int? maxAngle,
  })  : minAngle = minAngle ?? 0,
        maxAngle = maxAngle ?? 180;

  final int minAngle;
  final int maxAngle;

  @override
  State<GradientContainerWidget> createState() =>
      _GradientContainerWidgetState();
}

class _GradientContainerWidgetState extends State<GradientContainerWidget> {
  late GradientContainerModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GradientContainerModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.angleIncrementTimer?.cancel();
      _model.angle = widget.minAngle;
      safeSetState(() {});
      _model.angleIncrementTimer = InstantTimer.periodic(
        duration: const Duration(milliseconds: 25),
        callback: (timer) async {
          if (_model.angle! > widget.maxAngle) {
            _model.incrementValue = -1;
            _model.angle = widget.maxAngle;
          } else if (_model.angle! < widget.minAngle) {
            _model.incrementValue = 1;
            _model.angle = widget.minAngle;
          } else {
            _model.angle = _model.angle! + _model.incrementValue!;
            safeSetState(() {});
          }
        },
        startImmediately: true,
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 397.0,
      height: 52.0,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FlutterFlowTheme.of(context).primary,
            FlutterFlowTheme.of(context).secondary,
            FlutterFlowTheme.of(context).secondary,
            FlutterFlowTheme.of(context).tertiary,
            FlutterFlowTheme.of(context).primary
          ],
          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
          begin: AlignmentDirectional(
              computeGradientAlignmentX(valueOrDefault<double>(
                _model.angle?.toDouble(),
                0.0,
              )),
              computeGradientAlignmentY(valueOrDefault<double>(
                _model.angle?.toDouble(),
                0.0,
              ))),
          end: AlignmentDirectional(
              -1 *
                  computeGradientAlignmentX(valueOrDefault<double>(
                    _model.angle?.toDouble(),
                    0.0,
                  )),
              -1 *
                  computeGradientAlignmentY(valueOrDefault<double>(
                    _model.angle?.toDouble(),
                    0.0,
                  ))),
        ),
      ),
    );
  }
}
