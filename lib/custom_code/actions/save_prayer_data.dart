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

Future<bool> savePrayerData(PrayerStruct prayer) async {
  // Add your function code here!
  try {
    // Convert the struct to a JSON string
    final jsonString = jsonEncode(prayer.toMap());

    // Get the directory to save the file
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${prayer.id}');

    // Write the JSON string to the file
    await file.writeAsString(jsonString);
    return true;
  } catch (e) {
    return false;
  }
}
