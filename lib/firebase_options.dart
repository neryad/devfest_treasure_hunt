import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    final platformAppId = switch (defaultTargetPlatform) {
      TargetPlatform.android => const String.fromEnvironment(
        'FIREBASE_ANDROID_APP_ID',
      ),
      TargetPlatform.iOS || TargetPlatform.macOS =>
        const String.fromEnvironment('FIREBASE_IOS_APP_ID'),
      TargetPlatform.windows ||
      TargetPlatform.linux ||
      TargetPlatform.fuchsia => const String.fromEnvironment(
        'FIREBASE_WEB_APP_ID',
      ),
    };
    final appId = kIsWeb
        ? const String.fromEnvironment('FIREBASE_WEB_APP_ID')
        : platformAppId;
    final apiKey = const String.fromEnvironment('FIREBASE_API_KEY');
    final projectId = const String.fromEnvironment('FIREBASE_PROJECT_ID');
    final senderId = const String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
    );
    if (apiKey.isEmpty ||
        appId.isEmpty ||
        projectId.isEmpty ||
        senderId.isEmpty) {
      throw StateError(
        'Firebase está habilitado, pero falta configuración. '
        'Completa firebase-config.json usando firebase-config.example.json.',
      );
    }
    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: senderId,
      projectId: projectId,
      authDomain: const String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
      storageBucket: const String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
    );
  }
}
