// File generated from your google-services.json
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web not configured - use Android');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB7Uo11KWLPdppyXdr0oFcv8002ldmLsq8',
    appId: '1:1030419687237:android:7b3f91900687e2bfa3002c',
    messagingSenderId: '1030419687237',
    projectId: 'ajalaks-el-bouni',
    storageBucket: 'ajalaks-el-bouni.firebasestorage.app',
  );
}
