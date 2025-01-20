import 'package:flutter/foundation.dart';

class DownloadStateNotifier extends ValueNotifier<DownloadState> {
  DownloadStateNotifier() : super(_initialValue);
  static const _initialValue = DownloadState.none;
}

enum DownloadState { none, loading, canceled, downloading, completed, error }
