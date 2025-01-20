import 'package:aligned_tooltip/aligned_tooltip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:my_prayer/custom_code/download/download_manager.dart';
import 'package:my_prayer/custom_code/download/notifiers/download_state_notifier.dart';
import 'package:my_prayer/custom_code/widgets/custom_circular_progress_indicator.dart';
import 'package:my_prayer/flutter_flow/flutter_flow_theme.dart';
import 'package:my_prayer/flutter_flow/flutter_flow_util.dart';
import 'package:my_prayer/service_locator.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class DownloadProgressIndicator extends StatefulWidget {
  const DownloadProgressIndicator({
    super.key,
  });

  @override
  State<DownloadProgressIndicator> createState() =>
      _DownloadProgressIndicatorState();
}

class _DownloadProgressIndicatorState extends State<DownloadProgressIndicator> {
  DownloadState downloadState = DownloadState.none;

  double downloadProgress = 0;

  final _downloadManager = getIt<DownloadManager>();

  Future<void> updateDownloadProgress(int downloaded, int totalSize) async {
    downloadProgress = downloaded / totalSize;
    safeSetState(() {});
  }

  Future<void> onDownloadStateChange() async {
    downloadState = _downloadManager.downloadStateNotifier.value;
    if (downloadState == DownloadState.error) {
      onDownloadError(context);
    } else if (downloadState == DownloadState.completed) {
      onDownloadComplete(context);
    }
    safeSetState(() {});
  }

  Future<void> onDownloadComplete(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (alertDialogContext) {
        return AlertDialog(
          title: const Text('Descărcarea a fost finalizată!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(alertDialogContext),
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  Future<void> onDownloadError(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (alertDialogContext) {
        return AlertDialog(
          title: const Text('Descărcarea nu a putut fi finalizată!'),
          content: const Text(
              'Ne pare rău, a intervenit o eroare. Încearcă mai târziu.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(alertDialogContext),
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  void onDownloadProgressChanged() {
    updateDownloadProgress(
      _downloadManager.downloadedSizeNotifier.value,
      _downloadManager.totalSizeNotifier.value ?? 0,
    );
  }

  @override
  void initState() {
    super.initState();

    downloadState = _downloadManager.downloadStateNotifier.value;

    _downloadManager.downloadStateNotifier.addListener(onDownloadStateChange);
    _downloadManager.downloadedSizeNotifier
        .addListener(onDownloadProgressChanged);

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _downloadManager.downloadStateNotifier
        .removeListener(onDownloadStateChange);
    _downloadManager.downloadedSizeNotifier
        .removeListener(onDownloadProgressChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        if (downloadState == DownloadState.loading) {
          return Container(
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary,
            ),
            child: Align(
              alignment: const AlignmentDirectional(0.0, 0.0),
              child: SizedBox(
                width: 20.0,
                height: 20.0,
                child: CustomCircularProgressIndicator(
                  width: 20.0,
                  height: 20.0,
                  color: FlutterFlowTheme.of(context).alternate,
                ),
              ),
            ),
          );
        } else if (downloadState == DownloadState.downloading) {
          return Container(
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary,
            ),
            child: AlignedTooltip(
              content: Padding(
                padding: const EdgeInsets.all(4.0),
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _downloadManager.downloadedSizeNotifier,
                    _downloadManager.totalSizeNotifier,
                  ]),
                  builder: (context, child) {
                    final downloadedSize =
                        _downloadManager.downloadedSizeNotifier.value;
                    final totalSize =
                        _downloadManager.totalSizeNotifier.value ?? 0;

                    final progressText = totalSize > 0
                        ? "${(downloadedSize / (1024 * 1024)).toStringAsFixed(2)} / ${(totalSize / (1024 * 1024)).toStringAsFixed(2)} MB"
                        : '0/0 MB';

                    return Text(
                      progressText,
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: 'Inter',
                            letterSpacing: 0.0,
                          ),
                    );
                  },
                ),
              ),
              offset: 4.0,
              preferredDirection: AxisDirection.down,
              borderRadius: BorderRadius.circular(8.0),
              backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
              elevation: 4.0,
              tailBaseWidth: 24.0,
              tailLength: 12.0,
              waitDuration: const Duration(milliseconds: 100),
              showDuration: const Duration(milliseconds: 1000),
              triggerMode: TooltipTriggerMode.tap,
              child: Align(
                alignment: const AlignmentDirectional(0.0, 0.0),
                child: Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                  child: CircularPercentIndicator(
                    percent: downloadProgress,
                    radius: 12.0,
                    lineWidth: 4.0,
                    animation: true,
                    animateFromLastPercent: true,
                    progressColor: FlutterFlowTheme.of(context).alternate,
                    backgroundColor: const Color(0xFF676767),
                    startAngle: 0.0,
                  ),
                ),
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
