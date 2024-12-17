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

Future navigateWithRelacement(
  BuildContext context,
  String pageName,
  dynamic? parameters,
) async {
  // Add your function code here!
  while (context.canPop()) {
    context.safePop();
  }
  context.pushReplacementNamed(
    pageName,
    queryParameters: parameters,
  );
}
