import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const ScentViewApp());
  } catch (e) {
    // Show a clear error screen if Firebase init fails (bad config/unsupported platform)
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Firebase initialization failed.\n'
                        'Reason: ' +
                    e.toString() +
                    '\n\n'
                        'If you are on Web: ensure Authorized Domains and correct firebase_options.dart.\n'
                        'If you are on Windows/macOS/Linux: run flutterfire configure to add desktop configs.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
