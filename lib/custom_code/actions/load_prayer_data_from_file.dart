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

Future<PrayerStruct?> loadPrayerDataFromFile(String prayerId) async {
  // Add your function code here!
  try {
    // Get the directory to read the file
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$prayerId');

    // Check if the file exists
    if (!await file.exists()) {
      return null; // File not found
    }

    // Read the file contents as a JSON string
    final jsonString = await file.readAsString();

    // Decode the JSON string to a Map
    final jsonData = jsonDecode(jsonString);

    // Convert the Map to a PrayerStruct
    return PrayerStruct.fromMap(jsonData);
  } catch (e) {
    throw Exception('Error loading PrayerStruct from file: $e');
  }
}
