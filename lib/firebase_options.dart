import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBhx7Ey7uBA_RevDx1iMZ_S02Vhd1dk29I',
    authDomain: 'devfest-master.firebaseapp.com',
    projectId: 'devfest-master',
    storageBucket: 'devfest-master.firebasestorage.app',
    messagingSenderId: '949131407676',
    appId: '1:949131407676:web:5b7e3caa205d25b25bee39',
  );
}
