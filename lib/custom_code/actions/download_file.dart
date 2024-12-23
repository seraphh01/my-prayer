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

import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String?> downloadFile(String url) async {
  try {
    // Extract file name from the URL
    final fileName = extractFileName(url);

    // Get the application's document directory
    final dir = await getApplicationDocumentsDirectory();

    // Create the file path
    final filePath = '${dir.path}/$fileName';

    // Make HTTP GET request
    final response = await http.get(Uri.parse(url));

    // Check if the request was successful
    if (response.statusCode == 200) {
      // Write the file bytes to the created file
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      // Return the file path
      return filePath;
    } else {
      print('Failed to download file: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error downloading file: $e');
    return null;
  }
}
