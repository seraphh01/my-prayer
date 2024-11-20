import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyAPscQP-FDUkhT21GaUODHGHU6jQn94rTI",
            authDomain: "myprayer-c0e8f.firebaseapp.com",
            projectId: "myprayer-c0e8f",
            storageBucket: "myprayer-c0e8f.firebasestorage.app",
            messagingSenderId: "854966146196",
            appId: "1:854966146196:web:c51bd03283bb090c7e1081",
            measurementId: "G-4GBMQLMRYF"));
  } else {
    await Firebase.initializeApp();
  }
}
