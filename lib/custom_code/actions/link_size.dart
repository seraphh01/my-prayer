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
import 'dart:math';
import 'package:http/http.dart' as http;

Future<String> linkSize(String url) async {
  // Add your function code here!
  try {
    String? fileSize = "";
    var response = await http.head(Uri.parse(url));
    fileSize = response.headers["content-length"];
    int bytes = int.parse(fileSize!);
    if (bytes <= 0) {
      fileSize = "0 B";
    }
    const suffixes = ["B", "KB", "MG", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    fileSize = '${(bytes / pow(1024, i)).toStringAsFixed(0)} ${suffixes[i]}';

    return fileSize;
  } catch (err) {
    return "0 B";
  }
}
