import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../data/datasources/firebase_data_source.dart';
import '../data/datasources/mock_local_data_source.dart';
import '../data/local/shared_prefs_local_storage.dart';
import '../data/repositories/mock_app_repository.dart';
import '../firebase_options.dart';
import '../state/app_controller.dart';
import '../state/app_scope.dart';
import '../ui/screens/root/session_gate.dart';
import '../ui/screens/root/splash_screen.dart';
import '../ui/screens/root/startup_error_screen.dart';

/// Everything main() needs to compose the app, kept behind one small factory
/// so Firebase wiring can later replace it in a single place.
class AppDependencies {
  const AppDependencies({
    required this.repository,
    required this.resetStore,
    this.offline = false,
  });

  final MockAppRepository repository;
  final Future<void> Function() resetStore;

  /// True when the user explicitly chose local mode after a connection failure.
  final bool offline;
}

/// Connects to Firebase. Throws on any failure — callers decide what to show.
Future<AppDependencies> buildAppDependencies() async {
  final storage = SharedPrefsLocalStorage();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  final dataSource = FirebaseDataSource(storage: storage);
  await dataSource.initialize();
  return AppDependencies(
    repository: MockAppRepository(dataSource),
    resetStore: dataSource.reset,
    offline: false,
  );
}

/// Explicit local mode chosen by the user. Never silent.
Future<AppDependencies> buildOfflineDependencies() async {
  final storage = SharedPrefsLocalStorage();
  final dataSource = MockLocalDataSource(storage: storage);
  await dataSource.initialize();
  return AppDependencies(
    repository: MockAppRepository(dataSource),
    resetStore: dataSource.reset,
    offline: true,
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
      attemptRepository: repo,
      resetStore: widget.repository.resetStore,
      offline: widget.repository.offline,
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
      child: _withOfflineBanner(const SessionGate()),
    );
  }

  Widget _withOfflineBanner(Widget content) {
    if (!_controller.offline) return content;
    return Column(
      children: [
        Material(
          color: AppColors.amber,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: const [
                  Icon(
                    Icons.cloud_off_rounded,
                    size: 14,
                    color: Colors.black87,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sin conexión — datos locales, no se sincronizan',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(child: content),
      ],
    );
  }
}

/// Root widget owning the startup state machine:
/// connecting → error (retry / continue offline) → app ready.
class DevFestRoot extends StatefulWidget {
  const DevFestRoot({super.key, this.connect, this.connectOffline});

  /// Injectable for tests. Defaults to the real Firebase connection.
  final Future<AppDependencies> Function()? connect;
  final Future<AppDependencies> Function()? connectOffline;

  @override
  State<DevFestRoot> createState() => _DevFestRootState();
}

class _DevFestRootState extends State<DevFestRoot> {
  late Future<AppDependencies> _startup;

  @override
  void initState() {
    super.initState();
    _startup = (widget.connect ?? buildAppDependencies)();
  }

  void _retry() {
    setState(() {
      _startup = (widget.connect ?? buildAppDependencies)();
    });
  }

  void _continueOffline() {
    setState(() {
      _startup = (widget.connectOffline ?? buildOfflineDependencies)();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppDependencies>(
      future: _startup,
      builder: (context, snapshot) {
        return MaterialApp(
          title: 'DevFest Master',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          home: _buildHome(snapshot),
        );
      },
    );
  }

  Widget _buildHome(AsyncSnapshot<AppDependencies> snapshot) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const SplashScreen();
    }
    if (snapshot.hasError || !snapshot.hasData) {
      return StartupErrorScreen(onRetry: _retry, onOffline: _continueOffline);
    }
    return DevFestApp(repository: snapshot.data!);
  }
}
