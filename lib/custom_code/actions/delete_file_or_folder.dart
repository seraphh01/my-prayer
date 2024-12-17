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

Future<bool> deleteFileOrFolder(String relativePath, String? name) async {
  try {
    // Get the application documents directory
    final appDocumentsDirectory = await getApplicationDocumentsDirectory();
    final basePath = appDocumentsDirectory.path;

    // Determine the full path based on relativePath and name
    final targetPath = [
      basePath,
      if (relativePath != null && relativePath.isNotEmpty) relativePath,
      if (name != null) name
    ].join('/');

    final entity = FileSystemEntity.typeSync(targetPath);

    if (entity == FileSystemEntityType.file) {
      final file = File(targetPath);
      if (await file.exists()) {
        await file.delete();
        print('File deleted: $targetPath');
        return true;
      } else {
        print('File not found: $targetPath');
        return false;
      }
    } else if (entity == FileSystemEntityType.directory) {
      final directory = Directory(targetPath);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
        print('Folder deleted: $targetPath');
        return true;
      } else {
        print('Folder not found: $targetPath');
        return false;
      }
    } else {
      print('No file or folder found at: $targetPath');
      return false;
    }
  } catch (e) {
    print('Error deleting file or folder: $e');
    return false;
  }
}
