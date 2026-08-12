import 'package:flutter/material.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = await buildAppDependencies();
  runApp(DevFestApp(repository: repository));
}