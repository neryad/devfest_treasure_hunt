import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_theme.dart';
import '../data/datasources/firebase_data_source.dart';
import '../data/datasources/demo_data_seed.dart';
import '../data/datasources/mock_local_data_source.dart';
import '../data/local/shared_prefs_local_storage.dart';
import '../data/repositories/mock_app_repository.dart';
import '../firebase_options.dart';
import '../state/app_controller.dart';
import '../state/app_scope.dart';
import '../ui/screens/root/session_gate.dart';
import '../ui/screens/root/splash_screen.dart';
import '../ui/screens/root/startup_error_screen.dart';
import 'demo_admin_credentials.dart';

class AppDependencies {
  const AppDependencies({
    required this.repository,
    required this.resetStore,
    this.offline = false,
    this.adminAuthenticator,
  });

  final MockAppRepository repository;
  final Future<void> Function() resetStore;
  final AdminAuthenticator? adminAuthenticator;

  /// True when the app uses local, per-browser/device demo data.
  final bool offline;
}

const _useFirebase = bool.fromEnvironment('USE_FIREBASE');

Future<AppDependencies> buildDefaultDependencies() =>
    _useFirebase ? buildFirebaseDependencies() : buildDemoDependencies();

Future<AppDependencies> buildFirebaseDependencies() async {
  try {
    final storage = SharedPrefsLocalStorage();
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    debugPrint('BOOT: firebase initialized');
    final dataSource = FirebaseDataSource(storage: storage);
    await dataSource.initialize();
    debugPrint('BOOT: datasource initialized');
    return AppDependencies(
      repository: MockAppRepository(dataSource),
      resetStore: dataSource.reset,
      offline: false,
      adminAuthenticator: (email, password) async {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      },
    );
  } catch (e, st) {
    debugPrint('BOOT FAILURE: $e\n$st');
    rethrow;
  }
}

Future<AppDependencies> buildDemoDependencies() async {
  final storage = SharedPrefsLocalStorage();
  final seed = DemoDataSeed.fromJson(
    await rootBundle.loadString('assets/demo/devfest-2026.json'),
  );
  final dataSource = MockLocalDataSource(storage: storage, initialData: seed);
  await dataSource.initialize();
  return AppDependencies(
    repository: MockAppRepository(dataSource),
    resetStore: dataSource.reset,
    offline: true,
    adminAuthenticator: (email, password) async {
      if (email.trim().toLowerCase() != demoAdminEmail ||
          password != demoAdminPassword) {
        throw const AdminAuthenticationException();
      }
    },
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
      adminAuthenticator: widget.repository.adminAuthenticator,
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
        title: 'DevFest Master',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        builder: _controller.offline ? _withOfflineBanner : null,
        home: const SessionGate(),
      ),
    );
  }

  Widget _withOfflineBanner(BuildContext context, Widget? child) {
    final content = child ?? const SizedBox.shrink();
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
                      'Demo local — los cambios solo se guardan aquí',
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
/// starting → error (retry / continue in demo mode) → app ready.
class DevFestRoot extends StatefulWidget {
  const DevFestRoot({super.key, this.connect, this.connectOffline});

  /// Injectable for tests. Defaults to the local demo unless Firebase is
  /// explicitly enabled with `USE_FIREBASE`.
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
    _startup = (widget.connect ?? buildDefaultDependencies)();
  }

  void _retry() {
    setState(() {
      _startup = (widget.connect ?? buildDefaultDependencies)();
    });
  }

  void _continueOffline() {
    setState(() {
      _startup = (widget.connectOffline ?? buildDemoDependencies)();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppDependencies>(
      future: _startup,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _startupShell(const SplashScreen());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return _startupShell(
            StartupErrorScreen(onRetry: _retry, onOffline: _continueOffline),
          );
        }
        return DevFestApp(repository: snapshot.data!);
      },
    );
  }

  Widget _startupShell(Widget home) {
    return MaterialApp(
      title: 'DevFest Master',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: home,
    );
  }
}
