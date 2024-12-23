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

import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<int> computeFolderSize(String path) async {
  var appDocumentsDirectory = await getApplicationDocumentsDirectory();

  if (path.isNotEmpty) {
    appDocumentsDirectory = Directory('${appDocumentsDirectory.path}/$path');
  }

  int totalSize = 0;

  if (await appDocumentsDirectory.exists()) {
    for (var entity in appDocumentsDirectory.listSync(recursive: true)) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }
  }

  return totalSize;
}
