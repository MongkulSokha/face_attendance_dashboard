import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:face_attendance_dashboard/environment.dart';
import 'package:face_attendance_dashboard/root_app.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Environment.init(
    apiBaseUrl: 'https://example.com',
  );

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyB757HmClBFjeUTJOkz-FPD3BwOFUX4khg",
          authDomain: "attendance-app-7f803.firebaseapp.com",
          projectId: "attendance-app-7f803",
          storageBucket: "attendance-app-7f803.appspot.com",
          messagingSenderId: "1056032751950",
          appId: "1:1056032751950:web:1db42dd3cdc5a0eddc5e1f",
          measurementId: "G-E2DMMDFVK7"
        // Your web Firebase config options
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(RootApp());
}

