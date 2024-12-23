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

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<String> downloadAndStoreFile(String fileUrl, String fileName) async {
  try {
    // Get the device's storage directory
    final directory = await getApplicationDocumentsDirectory();
    final savePath = '${directory.path}/$fileName';

    // Set up Dio to download the file
    Dio dio = Dio();
    await dio.download(fileUrl, savePath);

    // Return the saved file path
    return savePath;
  } catch (e) {
    // If an error occurs, print it and return an error message
    print('Error downloading file: $e');
    return 'Error downloading file';
  }
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
