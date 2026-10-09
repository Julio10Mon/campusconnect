import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'CampusConnect no está configurado para Web.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions no está configurado para esta plataforma.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBrfI_6CNfOi8ri8g_5oevSeOEkkkMD9uI',
    appId: '1:962375991254:android:2c226a6fea29a77a52ae77',
    messagingSenderId: '962375991254',
    projectId: 'campusconnect-1b62c',
    storageBucket: 'campusconnect-1b62c.firebasestorage.app',
  );
}