import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDiLYJDRA7K-FFASUUzfac2FTxPMloK-9g',
    appId: '1:703643829941:web:18c8a4f692a90a983460fc',
    messagingSenderId: '703643829941',
    projectId: 'scentview-95df0',
    authDomain: 'scentview-95df0.firebaseapp.com',
    storageBucket: 'scentview-95df0.firebasestorage.app',
    measurementId: 'G-MS5QJXTTNX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBbL3OO9Rn5OWJzUjzGNWod1RrGmsOoNdQ',
    appId: '1:703643829941:android:fcb0ed31d6a5c5a13460fc',
    messagingSenderId: '703643829941',
    projectId: 'scentview-95df0',
    storageBucket: 'scentview-95df0.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC-x3ZSPxgNLEQTLjR702yMe1G6fs6gvn8',
    appId: '1:703643829941:ios:7a0e4dbcc62320f83460fc',
    messagingSenderId: '703643829941',
    projectId: 'scentview-95df0',
    storageBucket: 'scentview-95df0.firebasestorage.app',
    iosClientId:
        '703643829941-6v7hfqb1vm07k13510fc739m4flghih5.apps.googleusercontent.com',
    iosBundleId: 'com.example.scentview',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC-x3ZSPxgNLEQTLjR702yMe1G6fs6gvn8',
    appId: '1:703643829941:ios:7a0e4dbcc62320f83460fc',
    messagingSenderId: '703643829941',
    projectId: 'scentview-95df0',
    storageBucket: 'scentview-95df0.firebasestorage.app',
    iosClientId:
        '703643829941-6v7hfqb1vm07k13510fc739m4flghih5.apps.googleusercontent.com',
    iosBundleId: 'com.example.scentview',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDiLYJDRA7K-FFASUUzfac2FTxPMloK-9g',
    appId: '1:703643829941:web:761b89e6c459984b3460fc',
    messagingSenderId: '703643829941',
    projectId: 'scentview-95df0',
    authDomain: 'scentview-95df0.firebaseapp.com',
    storageBucket: 'scentview-95df0.firebasestorage.app',
    measurementId: 'G-RCYGNDQ826',
  );
}
