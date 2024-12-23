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

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'dart:async';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();

  late StreamSubscription _subscription;

  factory ConnectivityService() {
    return _instance;
  }

  ConnectivityService._internal();

  void initialize() {
    print('initialize service');
    // Listen for connectivity changes
    _subscription = Connectivity().onConnectivityChanged.listen((_) async {
      bool isConnected = await InternetConnectionChecker().hasConnection;

      // Update FFAppState with connectivity status
      FFAppState().isDeviceOnline = isConnected;
      FFAppState().update(() {});

      print('Device online? $isConnected');
    });
  }

  void dispose() {
    _subscription.cancel();
  }
}

Future checkInternetConnection() async {
  ConnectivityService().initialize();
}
