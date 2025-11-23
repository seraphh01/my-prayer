// download_manager.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/backend/schema/structs/index.dart';
import './notifiers/download_state_notifier.dart';
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:my_prayer/custom_code/extensions/string_extensions.dart';

class DownloadManager {
  final ValueNotifier<int> downloadedSizeNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int?> totalSizeNotifier = ValueNotifier<int?>(null);

  final ValueNotifier<DownloadState> downloadStateNotifier =
      ValueNotifier<DownloadState>(DownloadState.none);

  Future<void> downloadPrayer({
    required BuildContext context,
    required PrayerStruct prayer,
  }) async {
    // Reset notifiers for a new download process
    downloadStateNotifier.value = DownloadState.none;
    downloadedSizeNotifier.value = 0;
    totalSizeNotifier.value = null;

    // Check if the prayer is already downloaded
    if (FFAppState().downloadedPrayers.any((p) => p.id == prayer.id)) {
      if (!context.mounted) return;
      final downloadAgain = await _showConfirmationDialog(
        context,
        title: 'Confirm Download',
        content:
            'Rugăciunea este deja descărcată! Dorești să o descarci din nou?',
      );

      if (!downloadAgain) {
        downloadStateNotifier.value = DownloadState.canceled;

        return;
      }
    }

    downloadStateNotifier.value = DownloadState.loading;
    // Calculate total download size
    final downloadQueue = <String>[];
    final totalSize =
        await _calculateTotalSize(prayer.sections ?? [], downloadQueue);
    totalSizeNotifier.value = totalSize;

    if (!context.mounted) {
      downloadStateNotifier.value = DownloadState.canceled;
      return;
    }

    final shouldDownload =
        await _showDownloadConfirmationDialog(context, totalSize);
    if (!shouldDownload) {
      downloadStateNotifier.value = DownloadState.canceled;
      return;
    }
    downloadStateNotifier.value = DownloadState.downloading;

    // Download and cache files
    int downloadedBytes = 0;
    for (final url in downloadQueue) {
      final filePath = await _downloadFile(url);

      if (filePath == null) {
        downloadStateNotifier.value = DownloadState.error;
        return;
      }

      final file = File(filePath);
      if (await file.exists()) {
        downloadedBytes += file.lengthSync();
        downloadedSizeNotifier.value = downloadedBytes;
      }
    }

    FFAppState().removeFromDownloadedPrayers(prayer);
    FFAppState().addToDownloadedPrayers(prayer);
    downloadStateNotifier.value = DownloadState.completed;
  }

  Future<int> _calculateTotalSize(
    List<PrayerSectionStruct> sections,
    List<String> downloadQueue,
  ) async {
    int totalSize = 0;

    for (var section in sections) {
      if (section.audioUrl?.isNotEmpty ?? false) {
        final audioUrl = section.audioUrl!;
        if (downloadQueue.contains(audioUrl)) {
          continue;
        }

        final response = await http.head(Uri.parse(audioUrl));
        if (response.statusCode == 200 &&
            response.headers['content-length'] != null) {
          totalSize += int.parse(response.headers['content-length']!);
          downloadQueue.add(audioUrl);
        }
      }

      final response = await PrayerSectionContentCall.call(
          prayerSectionId: section.sectionId);
      final texts = (getJsonField(response.jsonBody, r'$.texts', true)
                  ?.toList()
                  .map<SectionTextStruct?>(SectionTextStruct.maybeFromMap)
                  .toList() as Iterable<SectionTextStruct?>?)
              ?.withoutNulls
              ?.toList() ??
          [];

      section.texts = texts;

      if (section.subsections?.isNotEmpty ?? false) {
        totalSize +=
            await _calculateTotalSize(section.subsections!, downloadQueue);
      }
    }

    return totalSize;
  }

  Future<bool> _showConfirmationDialog(BuildContext context,
      {required String title, required String content}) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title),
              content: Text(content),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Nu'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Da'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<bool> _showDownloadConfirmationDialog(
      BuildContext context, int totalSize) async {
    final sizeInMB = (totalSize / (1024 * 1024)).toStringAsFixed(2);
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Descărcarea'),
              content: Text(
                  'Mărimea totală a descărcării este de $sizeInMB MB. Vrei să continui descărcarea?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Anulează'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Descarcă'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

String sanitizeFilename(String input) {
  // Step 1: Replace accented characters with ASCII equivalents
  const accents = {
    'ă': 'a', 'â': 'a', 'î': 'i', 'ș': 's', 'ş': 's', 'ț': 't', 'ţ': 't',
    'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
    'á': 'a', 'à': 'a', 'ä': 'a',
    'ó': 'o', 'ò': 'o', 'ö': 'o',
    'ú': 'u', 'ù': 'u', 'ü': 'u',
    'ñ': 'n', 'ç': 'c'
  };

  String txt = input;

  accents.forEach((from, to) {
    txt = txt.replaceAll(from, to);
    txt = txt.replaceAll(from.toUpperCase(), to.toUpperCase());
  });

  // Step 2: Replace forbidden characters
  txt = txt.replaceAll(RegExp(r"[<>:\/\\|?']"), "_");


  // Step 3: Remove commas
  txt = txt.replaceAll(',', '');

  // Step 4: Normalize whitespace
  txt = txt.replaceAll(RegExp(r'\s+'), ' ').trim();

  // Step 5: Replace spaces with underscores
  txt = txt.replaceAll(' ', '_');

  return txt;
}


Future<String?> _downloadFile(String url) async {
  try {
    final rawName = extractFileName(url) ?? "file";
    final fileName = sanitizeFilename(rawName);

    // Prevent empty or extension-less filenames
    final safeName = fileName.isEmpty ? "file" : fileName;

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/$safeName");

    // Create the directory if missing (fixes iOS errors)
    await file.parent.create(recursive: true);

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      await file.writeAsBytes(response.bodyBytes);
      return file.path;
    } else {
      print("Download error: ${response.statusCode}");
    }
  } catch (e) {
    print('Error when downloading: $e');
  }
  return null;
}

}
