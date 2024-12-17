// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'index.dart'; // Imports other custom actions

import 'index.dart'; // Imports other custom actions

import 'package:path_provider/path_provider.dart';

import 'index.dart'; // Imports other custom actions

import 'index.dart'; // Imports other custom actions

import 'index.dart'; // Imports other custom actions

import 'index.dart'; // Imports other custom actions

import 'package:my_prayer/backend/api_requests/api_calls.dart';
import 'index.dart'; // Imports other custom actions

import 'package:http/http.dart' as http;
import 'dart:io';

Future<void> downloadPrayer(
    BuildContext context,
    PrayerStruct prayer,
    Future Function(int downloadedSize, int? totalSize)? onDownloadProgress,
    Future Function()? onDownloadStarted,
    Future Function()? onDownloadComplete,
    Future Function()? onDownloadCanceled) async {
  // Add your function code here!

  if (FFAppState().downloadedPrayers.any((p) => p.id == prayer.id)) {
    print("prayer downloaded already");
    var downloadAgain = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Download'),
              content: const Text(
                'Rugăciunea este deja descărcată!'
                'Dorești să o descarci din nou?',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(false); // User cancels the download
                  },
                  child: const Text('Nu'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(true); // User confirms the download
                  },
                  child: const Text('Da'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!downloadAgain) {
      onDownloadCanceled!();
      return;
    }
  }

  Future<bool> showDownloadConfirmationDialog(
      BuildContext context, int totalSize) async {
    // Convert bytes to MB for user-friendly display
    final sizeInMB = (totalSize / (1024 * 1024)).toStringAsFixed(2);

    return await showDialog<bool>(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Descărcarea'),
              content: Text(
                'Mărimea totală a descărcării este de $sizeInMB MB. '
                'Vrei să continui descărcarea?',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(false); // User cancels the download
                  },
                  child: const Text('Anulează'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(true); // User confirms the download
                  },
                  child: const Text('Descarcă'),
                ),
              ],
            );
          },
        ) ??
        false; // Default to false if the dialog is dismissed
  }

  // Helper function to recursively calculate size and manage downloads
  Future<int> _processSections(
    List<PrayerSectionStruct> sections, {
    required List<String> downloadQueue,
  }) async {
    int totalSize = 0;

    final directory = await getApplicationDocumentsDirectory();
    final allFiles = directory.listSync().map((file) => file.path);
    for (var section in sections) {
      // Add audio file to queue if it exists
      if (section.audioUrl != null && section.audioUrl!.isNotEmpty) {
        final audioUrl = section.audioUrl!;

        if (downloadQueue.contains(audioUrl)) {
          continue;
        }
        final uri = Uri.parse(audioUrl);
        final fileName = extractFileName(audioUrl);

        // Check if the file is already cached

        final fileInfo = await retrieveAudioFile(audioUrl);

        if (fileInfo != null) {
          // File is cached, no need to download again
          continue;
        }

        // Calculate the size of the audio file
        final response = await http.head(uri);
        if (response.statusCode == 200 &&
            response.headers['content-length'] != null) {
          totalSize += int.parse(response.headers['content-length']!);
        }

        downloadQueue.add(audioUrl);
      }

      final response = await PrayerSectionContentCall.call(
          prayerSectionId: section.sectionId);

      final texts = (getJsonField(
            response.jsonBody,
            r'''$.texts''',
            true,
          )
                  ?.toList()
                  .map<SectionTextStruct?>(SectionTextStruct.maybeFromMap)
                  .toList() as Iterable<SectionTextStruct?>)
              .withoutNulls
              ?.toList() ??
          [];

      section.texts = texts;

      // Process subsections recursively
      if (section.subsections != null && section.subsections.isNotEmpty) {
        totalSize += await _processSections(
          section.subsections,
          downloadQueue: downloadQueue,
        );
      }
    }

    return totalSize;
  }

  // Step 1: Calculate total size
  final List<String> downloadQueue = [];
  final int totalSize = await _processSections(
    prayer.sections ?? [],
    downloadQueue: downloadQueue,
  );

  // Notify user of the total size (you can use a dialog here)
  var shouldDownload = false;
  shouldDownload = await showDownloadConfirmationDialog(context, totalSize);

  if (!shouldDownload) {
    return;
  }

  onDownloadStarted!();

  // Step 2: Download and cache audio files
  int downloadedBytes = 0;

  for (final url in downloadQueue) {
    final filePath = await downloadFile(url);

    if (filePath == null) {
      onDownloadCanceled!();
      return;
    }

    final file = File(filePath);
    if (await file.exists()) {
      print(file.path);
      final fileSize = file.lengthSync();
      downloadedBytes += fileSize;

      // Update progress callback
      onDownloadProgress!(downloadedBytes, totalSize);
    }
  }

  if (FFAppState().downloadedPrayers.contains(prayer)) {
    FFAppState().removeFromDownloadedPrayers(prayer);
  }
  FFAppState().addToDownloadedPrayers(prayer);
  onDownloadComplete!();
}
