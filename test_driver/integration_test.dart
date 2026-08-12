import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Driver for `flutter drive`. Receives screenshots captured by the app
/// integration test and stores them as PNGs under `assets/screenshots/`.
Future<void> main() async {
  await integrationDriver(
    onScreenshot: (String name, List<int> bytes, [Map<String, Object?>? args]) async {
      final file = File('assets/screenshots/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes);
      return true;
    },
  );
}