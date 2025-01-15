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

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

Future<String?> retrieveAudioFile(String url) async {
  try {
    final fileName = extractFileName(url);

    final dir = await getApplicationDocumentsDirectory();

    final filePath = '${dir.path}/$fileName';

    final file = File(filePath);
    if (await file.exists()) {
      return file.path;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}
