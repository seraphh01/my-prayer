import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyDlj9G7H3GPFgkYU7XFdp5nI9wsLFiVgtM",
            authDomain: "myprayers-d4683.firebaseapp.com",
            projectId: "myprayers-d4683",
            storageBucket: "myprayers-d4683.firebasestorage.app",
            messagingSenderId: "69400948962",
            appId: "1:69400948962:web:8bceaa6385373377b4aebb",
            measurementId: "G-FZWX3THL2Q"));
  } else {
    await Firebase.initializeApp();
  }
}
