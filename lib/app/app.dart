import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../data/datasources/mock_local_data_source.dart';
import '../data/local/shared_prefs_local_storage.dart';
import '../data/repositories/mock_app_repository.dart';
import '../state/app_controller.dart';
import '../state/app_scope.dart';
import '../ui/screens/root/session_gate.dart';

/// Everything main() needs to compose the app, kept behind one small factory
/// so Firebase wiring can later replace it in a single place.
class AppDependencies {
  const AppDependencies({required this.repository, required this.resetStore});

  final MockAppRepository repository;
  final Future<void> Function() resetStore;
}

Future<AppDependencies> buildAppDependencies() async {
  final dataSource = MockLocalDataSource(storage: SharedPrefsLocalStorage());
  await dataSource.initialize();
  return AppDependencies(
    repository: MockAppRepository(dataSource),
    resetStore: dataSource.reset,
  );
}

class DevFestApp extends StatefulWidget {
  const DevFestApp({super.key, required this.repository});

  final AppDependencies repository;

  @override
  State<DevFestApp> createState() => _DevFestAppState();
}

class _DevFestAppState extends State<DevFestApp> {
  late final AppController _controller;

  @override
  void initState() {
    super.initState();
    final repo = widget.repository.repository;
    _controller = AppController(
      treasureRepository: repo,
      participantRepository: repo,
      leaderboardRepository: repo,
      eventRepository: repo,
      resetStore: widget.repository.resetStore,
    );
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: _controller,
      child: MaterialApp(
        title: 'DevFest Treasure Hunt',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: const SessionGate(),
      ),
    );
  }
}