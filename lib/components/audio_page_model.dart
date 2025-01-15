import '/flutter_flow/flutter_flow_util.dart';
import 'audio_page_widget.dart' show AudioPageWidget;
import 'package:flutter/material.dart';

class AudioPageModel extends FlutterFlowModel<AudioPageWidget> {
  ///  Local state fields for this component.

  int? slideAudioTime = 0;

  bool isSliding = false;

  int currentAudioTime = 0;

  int bufferedTime = 0;

  int totalDuration = 0;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
