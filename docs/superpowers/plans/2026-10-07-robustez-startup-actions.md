# Robustez: Arranque, Acciones y Datos Resilientes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** Que la app nunca se rompa ni se quede colgada ante fallos de red o datos malformados antes del evento del viernes.

**Architecture:** Un estado de arranque de 3 fases (conectando → error con reintento → lista) con elección explícita de modo offline y banner persistente; patrón uniforme try/catch/finally + SnackBar en todas las acciones con spinner; parsers tolerantes que filtran docs corruptos; limpieza de sesión huérfana.

**Tech Stack:** Flutter (Material), Firebase (solo como fuente de datos), tests con `flutter_test` y repos mock existentes.

**Spec:** `docs/superpowers/specs/2026-10-07-robustez-startup-actions-design.md`

---

### Task 1: Extraer SplashScreen y crear StartupErrorScreen

**Files:**
- Create: `lib/ui/screens/root/splash_screen.dart`
- Create: `lib/ui/screens/root/startup_error_screen.dart`
- Modify: `lib/ui/screens/root/session_gate.dart`

- [x] **Step 1: Crear SplashScreen (widget público, movido desde session_gate)**

Crear `lib/ui/screens/root/splash_screen.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.45),
                    blurRadius: 40,
                  ),
                ],
              ),
              child: const Icon(
                Icons.explore_rounded,
                size: 64,
                color: AppColors.primarySoft,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'DevFest Master',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
```

- [x] **Step 2: Crear StartupErrorScreen**

Crear `lib/ui/screens/root/startup_error_screen.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class StartupErrorScreen extends StatelessWidget {
  const StartupErrorScreen({
    super.key,
    required this.onRetry,
    this.onOffline,
    this.message = 'No se pudo conectar con el evento',
  });

  final VoidCallback onRetry;
  final VoidCallback? onOffline;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off_rounded,
                  size: 72,
                  color: AppColors.textMuted,
                ),
                const SizedBox(height: 20),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Revisa tu conexión a internet e intenta de nuevo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reintentar'),
                ),
                if (onOffline != null) ...[
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: onOffline,
                    child: const Text(
                      'Continuar sin conexión',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

Nota: `AppColors.textMuted` — verificar que existe en `lib/core/theme/app_theme.dart`; si no, usar `AppColors.textSecondary`.

- [x] **Step 3: Rewire session_gate.dart**

Reemplazar `lib/ui/screens/root/session_gate.dart` completo por:

```dart
import 'package:flutter/material.dart';

import '../../../state/app_scope.dart';
import '../home/home_shell.dart';
import '../welcome/welcome_screen.dart';
import 'splash_screen.dart';
import 'startup_error_screen.dart';

/// Decides where the app starts: splash while loading, error + retry when
/// initialization failed, Welcome (no participant) or Home (session exists).
class SessionGate extends StatelessWidget {
  const SessionGate({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);

    if (controller.initializing) {
      return const SplashScreen();
    }
    if (controller.initFailed) {
      return StartupErrorScreen(onRetry: controller.initialize);
    }
    if (!controller.hasParticipant) {
      return const WelcomeScreen();
    }
    return const HomeScreen();
  }
}
```

Esto NO compila todavía porque `initFailed` no existe — se agrega en Task 4. Ejecutar `flutter analyze` en Task 4 cuando todo cierre.

- [x] **Step 4: Commit**

```bash
git add lib/ui/screens/root/splash_screen.dart lib/ui/screens/root/startup_error_screen.dart lib/ui/screens/root/session_gate.dart
git commit -m "feat: add splash and startup error screens"
```

---

### Task 2: DevFestRoot — máquina de estados de arranque (A1/A2)

**Files:**
- Modify: `lib/app/app.dart`
- Modify: `lib/main.dart`
- Test: `test/widgets/startup_root_test.dart`

- [x] **Step 1: Escribir el test RED**

Crear `test/widgets/startup_root_test.dart`:

```dart
import 'package:devfest_treasure_hunt/app/app.dart';
import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<AppDependencies> _deps({bool offline = false}) async {
  final ds = MockLocalDataSource(seedData: false);
  await ds.initialize();
  return AppDependencies(
    repository: MockAppRepository(ds),
    resetStore: ds.reset,
    offline: offline,
  );
}

void main() {
  testWidgets('shows error screen with retry when connection fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      DevFestRoot(
        connect: () async => throw Exception('network down'),
        connectOffline: () => _deps(offline: true),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No se pudo conectar con el evento'), findsOneWidget);
    expect(find.text('Continuar sin conexión'), findsOneWidget);
    expect(find.text('¡Comenzar aventura!'), findsNothing);
    expect(find.textContaining('Sin conexión —'), findsNothing);
  });

  testWidgets('retry reconnects after a transient failure', (tester) async {
    var attempts = 0;
    await tester.pumpWidget(
      DevFestRoot(
        connect: () async {
          attempts++;
          if (attempts == 1) throw Exception('network down');
          return _deps();
        },
        connectOffline: () => _deps(offline: true),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No se pudo conectar con el evento'), findsOneWidget);

    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(attempts, 2);
    expect(find.text('¡Comenzar aventura!'), findsOneWidget);
  });
}
```

- [x] **Step 2: Correr el test para verlo fallar**

Run: `flutter test test/widgets/startup_root_test.dart`
Expected: FAIL — `AppDependencies` no tiene constructor con `offline`, `DevFestRoot` no existe.

- [x] **Step 3: Implementar DevFestRoot y las funciones de conexión en app.dart**

En `lib/app/app.dart`, reemplazar `AppDependencies` y `buildAppDependencies` y agregar `DevFestRoot`. El bloque completo de la parte superior de la función queda así (sustituye las líneas 14-43 actuales):

```dart
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
```

Agregar después (antes de `DevFestApp` o después — al final del archivo):

```dart
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
        if (snapshot.connectionState != ConnectionState.done) {
          return const SplashScreen();
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return StartupErrorScreen(
            onRetry: _retry,
            onOffline: _continueOffline,
          );
        }
        return DevFestApp(repository: snapshot.data!);
      },
    );
  }
}
```

Imports nuevos en `app.dart`:

```dart
import '../ui/screens/root/splash_screen.dart';
import '../ui/screens/root/startup_error_screen.dart';
```

- [x] **Step 4: Cambiar main.dart**

Reemplazar `lib/main.dart` completo:

```dart
import 'package:flutter/material.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DevFestRoot());
}
```

- [x] **Step 5: Correr el test hasta que pase**

Run: `flutter test test/widgets/startup_root_test.dart`
Expected: PASS (2 tests).

- [x] **Step 6: Correr la suite completa por si se rompió algo**

Run: `flutter test`
Expected: `+45: All tests passed!` o superior (los tests existentes que construían `DevFestApp` directamente — si los hay — podrían necesitar ajuste; `main.dart` no se testea).

- [x] **Step 7: Commit**

```bash
git add lib/app/app.dart lib/main.dart test/widgets/startup_root_test.dart
git commit -m "feat: add startup state machine with retry and offline choice"
```

---

### Task 3: Banner persistente de modo offline (A1)

**Files:**
- Modify: `lib/app/app.dart` (`DevFestApp` — constructor del controller y `MaterialApp.builder`)
- Modify: `lib/state/app_controller.dart` (parámetro `offline`)
- Test: `test/widgets/offline_banner_test.dart`

- [x] **Step 1: Escribir el test RED**

Crear `test/widgets/offline_banner_test.dart`:

```dart
import 'package:devfest_treasure_hunt/app/app.dart';
import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
import 'package:flutter_test/flutter_test.dart';

Future<AppDependencies> _offlineDeps() async {
  final ds = MockLocalDataSource(seedData: false);
  await ds.initialize();
  return AppDependencies(
    repository: MockAppRepository(ds),
    resetStore: ds.reset,
    offline: true,
  );
}

void main() {
  testWidgets('offline choice enters local mode with persistent banner', (
    tester,
  ) async {
    await tester.pumpWidget(
      DevFestRoot(
        connect: () async => throw Exception('network down'),
        connectOffline: _offlineDeps,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continuar sin conexión'));
    await tester.pumpAndSettle();

    expect(
      find.text('Sin conexión — datos locales, no se sincronizan'),
      findsOneWidget,
    );
    expect(find.text('¡Comenzar aventura!'), findsOneWidget);
  });
}
```

- [x] **Step 2: Correr el test para verlo fallar**

Run: `flutter test test/widgets/offline_banner_test.dart`
Expected: FAIL — el banner no existe y `DevFestApp` ignora `offline`.

- [x] **Step 3: Agregar `offline` al AppController**

En `lib/state/app_controller.dart`, en el constructor (líneas 31-39) agregar `this.offline = false,` después de `this.enableElapsedTicker = true,` y declarar el campo junto a `enableElapsedTicker`:

```dart
  AppController({
    required TreasureRepository treasureRepository,
    required ParticipantRepository participantRepository,
    required LeaderboardRepository leaderboardRepository,
    required EventRepository eventRepository,
    Future<void> Function()? resetStore,
    AttemptRepository? attemptRepository,
    this.enableElapsedTicker = true,
    this.offline = false,
  }) : _treasureRepository = treasureRepository,
       _participantRepository = participantRepository {
```

```dart
  final bool enableElapsedTicker;

  /// True when the app is running on local (unsynced) data by explicit choice.
  final bool offline;
```

- [x] **Step 4: Cablear DevFestApp — controller + builder con banner**

En `lib/app/app.dart`, `initState` de `_DevFestAppState`:

```dart
    _controller = AppController(
      treasureRepository: repo,
      participantRepository: repo,
      leaderboardRepository: repo,
      eventRepository: repo,
      attemptRepository: repo,
      resetStore: widget.repository.resetStore,
      offline: widget.repository.offline,
    );
```

Y el `build` de `_DevFestAppState`:

```dart
  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: _controller,
      child: MaterialApp(
        title: 'DevFest Master',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        builder: (context, child) => _withOfflineBanner(child),
        home: const SessionGate(),
      ),
    );
  }

  Widget _withOfflineBanner(Widget? child) {
    final content = child ?? const SizedBox.shrink();
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
```

- [x] **Step 5: Correr el test hasta que pase**

Run: `flutter test test/widgets/offline_banner_test.dart`
Expected: PASS.

- [x] **Step 6: Suite completa**

Run: `flutter test`
Expected: All tests passed.

- [x] **Step 7: Commit**

```bash
git add lib/app/app.dart lib/state/app_controller.dart test/widgets/offline_banner_test.dart
git commit -m "feat: show persistent banner in offline mode"
```

---

### Task 4: initialize() a prueba de fallos + sesión huérfana (A2/B10)

**Files:**
- Modify: `lib/domain/repositories/participant_repository.dart` (`setCurrentParticipantId(String?)`)
- Modify: `lib/data/repositories/mock_app_repository.dart` (misma firma)
- Modify: `lib/state/app_controller.dart` (`initialize()` con try/catch, `initFailed`, `sessionExpired`)
- Modify: `lib/ui/screens/welcome/welcome_screen.dart` (aviso de sesión expirada)
- Test: `test/state/app_controller_init_test.dart`

- [x] **Step 1: Escribir el test RED**

Crear `test/state/app_controller_init_test.dart`:

```dart
import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
import 'package:devfest_treasure_hunt/domain/entities/participant.dart';
import 'package:devfest_treasure_hunt/domain/entities/treasure_item.dart';
import 'package:devfest_treasure_hunt/state/app_controller.dart';
import 'package:devfest_treasure_hunt/state/app_scope.dart';
import 'package:devfest_treasure_hunt/ui/screens/root/session_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FlakyRepository extends MockAppRepository {
  _FlakyRepository(super.dataSource);

  bool failStaticLoad = false;
  bool orphanCurrent = false;

  @override
  Future<List<TreasureItem>> getTreasures() async {
    if (failStaticLoad) throw Exception('network down');
    return super.getTreasures();
  }

  @override
  Future<Participant?> getParticipant(String id) async {
    if (orphanCurrent) return null;
    return super.getParticipant(id);
  }
}

AppController _controller(_FlakyRepository repo, MockLocalDataSource ds) =>
    AppController(
      treasureRepository: repo,
      participantRepository: repo,
      leaderboardRepository: repo,
      eventRepository: repo,
      resetStore: ds.reset,
      attemptRepository: repo,
      enableElapsedTicker: false,
    );

void main() {
  testWidgets('initialize failure shows retry instead of infinite splash', (
    tester,
  ) async {
    final ds = MockLocalDataSource(seedData: false);
    await ds.initialize();
    final repo = _FlakyRepository(ds)..failStaticLoad = true;
    final controller = _controller(repo, ds);
    addTearDown(controller.dispose);

    await controller.initialize();
    expect(controller.initFailed, isTrue);

    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: const MaterialApp(home: SessionGate()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No se pudo conectar con el evento'), findsOneWidget);

    repo.failStaticLoad = false;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(controller.initFailed, isFalse);
    expect(find.text('¡Comenzar aventura!'), findsOneWidget);
  });

  test('orphaned session id is cleared and flagged', () async {
    final ds = MockLocalDataSource(seedData: false);
    await ds.initialize();
    final repo = _FlakyRepository(ds);
    await repo.createParticipant(
      id: 'participant-x',
      name: 'X',
      nickname: 'x',
      startedAt: DateTime.now(),
    );
    await repo.setCurrentParticipantId('participant-x');
    repo.orphanCurrent = true;

    final controller = _controller(repo, ds);
    addTearDown(controller.dispose);
    await controller.initialize();

    expect(controller.hasParticipant, isFalse);
    expect(controller.sessionExpired, isTrue);
    expect(await repo.getCurrentParticipantId(), isNull);
  });

  testWidgets('welcome shows a notice after an expired session', (
    tester,
  ) async {
    final ds = MockLocalDataSource(seedData: false);
    await ds.initialize();
    final repo = _FlakyRepository(ds);
    await repo.createParticipant(
      id: 'participant-x',
      name: 'X',
      nickname: 'x',
      startedAt: DateTime.now(),
    );
    await repo.setCurrentParticipantId('participant-x');
    repo.orphanCurrent = true;

    final controller = _controller(repo, ds);
    addTearDown(controller.dispose);
    await controller.initialize();

    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: const MaterialApp(home: SessionGate()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Tu sesión anterior ya no existe — regístrate de nuevo.'),
      findsOneWidget,
    );
  });
}
```

- [x] **Step 2: Correr el test para verlo fallar**

Run: `flutter test test/state/app_controller_init_test.dart`
Expected: FAIL — `initFailed`/`sessionExpired` no existen.

- [x] **Step 3: Cambiar la firma en la interfaz y el repo**

`lib/domain/repositories/participant_repository.dart` línea 25:

```dart
  /// Id remembered so the demo can restore the last session on restart.
  Future<void> setCurrentParticipantId(String? id);
```

`lib/data/repositories/mock_app_repository.dart` líneas 111-112:

```dart
  @override
  Future<void> setCurrentParticipantId(String? id) =>
      _dataSource.setCurrentParticipantId(id);
```

- [x] **Step 4: initialize() con try/catch + flags en AppController**

En `lib/state/app_controller.dart`, reemplazar `initialize()` (líneas 187-199) por:

```dart
  Future<void> initialize() async {
    _initializing = true;
    _initFailed = false;
    _sessionExpired = false;
    notifyListeners();
    try {
      final id = await _participantRepository.getCurrentParticipantId();
      if (id != null) {
        _participant = await _participantRepository.getParticipant(id);
        if (_participant == null) {
          await _participantRepository.setCurrentParticipantId(null);
          _sessionExpired = true;
        }
      }
      await _reloadStaticData();
      await _reloadLeaderboard();
      _startTickerIfNeeded();
    } catch (_) {
      _initFailed = true;
    }
    _initializing = false;
    notifyListeners();
  }
```

Agregar los campos y getters junto a `_initializing` (línea 69) y `initializing` (línea 82):

```dart
  bool _initializing = true;
  bool _initFailed = false;
  bool _sessionExpired = false;
```

```dart
  bool get initializing => _initializing;
  bool get initFailed => _initFailed;
  bool get sessionExpired => _sessionExpired;
```

Y en `startParticipant` (línea 201), al inicio del método:

```dart
  Future<void> startParticipant({
    required String name,
    required String nickname,
  }) async {
    _sessionExpired = false;
    _participant = await _startUseCase.execute(name: name, nickname: nickname);
    _consultedClues.clear();
    await _reloadLeaderboard();
    _startTickerIfNeeded();
    notifyListeners();
  }
```

- [x] **Step 5: Aviso en WelcomeScreen**

En `lib/ui/screens/welcome/welcome_screen.dart`, sustituir el bloque:

```dart
                    // --- DIRECT REGISTRATION CARD ---
                    Card(
```

por:

```dart
                    if (controller.sessionExpired) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Tu sesión anterior ya no existe — regístrate de nuevo.',
                          textAlign: TextAlign.Center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.amber,
                          ),
                        ),
                      ),
                    ],

                    // --- DIRECT REGISTRATION CARD ---
                    Card(
```

(Nota: `TextAlign.center` en minúsculas, como se usa en el resto del archivo.)

- [x] **Step 6: Correr el test hasta que pase**

Run: `flutter test test/state/app_controller_init_test.dart`
Expected: PASS (3 tests).

- [x] **Step 7: Suite completa + analyze**

Run: `flutter test && flutter analyze`
Expected: All tests passed; no issues (Task 1 dejó session_gate compilando ahora).

- [x] **Step 8: Commit**

```bash
git add lib/domain/repositories/participant_repository.dart lib/data/repositories/mock_app_repository.dart lib/state/app_controller.dart lib/ui/screens/welcome/welcome_screen.dart test/state/app_controller_init_test.dart lib/ui/screens/root/session_gate.dart
git commit -m "fix: handle init failures and orphaned sessions"
```

---

### Task 5: SnackBar helper + acciones de participante a prueba de fallos (A7)

**Files:**
- Create: `lib/core/utils/snack_bar_utils.dart`
- Modify: `lib/ui/screens/welcome/welcome_screen.dart` (`_start`)
- Modify: `lib/ui/screens/setup/participant_setup_screen.dart` (`_start`)
- Modify: `lib/ui/screens/discovery/manual_code_screen.dart` (`_submit`)
- Modify: `lib/ui/screens/discovery/qr_scanner_screen.dart` (`_handleValue`)
- Test: `test/widgets/action_error_feedback_test.dart`

- [x] **Step 1: Escribir el test RED**

Crear `test/widgets/action_error_feedback_test.dart`:

```dart
import 'package:devfest_treasure_hunt/core/utils/snack_bar_utils.dart';
import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
import 'package:devfest_treasure_hunt/domain/entities/attempt.dart';
import 'package:devfest_treasure_hunt/domain/entities/participant.dart';
import 'package:devfest_treasure_hunt/domain/entities/treasure_item.dart';
import 'package:devfest_treasure_hunt/state/app_controller.dart';
import 'package:devfest_treasure_hunt/state/app_scope.dart';
import 'package:devfest_treasure_hunt/ui/screens/discovery/manual_code_screen.dart';
import 'package:devfest_treasure_hunt/ui/screens/root/session_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FlakyRepository extends MockAppRepository {
  _FlakyRepository(super.dataSource);

  bool throwOnCreate = false;
  bool throwOnGetByCode = false;

  @override
  Future<Participant> createParticipant({
    required String id,
    required String name,
    required String nickname,
    required DateTime startedAt,
  }) async {
    if (throwOnCreate) throw Exception('network down');
    return super.createParticipant(
      id: id,
      name: name,
      nickname: nickname,
      startedAt: startedAt,
    );
  }

  @override
  Future<TreasureItem?> getByCode(String code) async {
    if (throwOnGetByCode) throw Exception('network down');
    return super.getByCode(code);
  }
}

Future<AppController> _controller(_FlakyRepository repo) async {
  final ds = MockLocalDataSource(seedData: false);
  final controller = AppController(
    treasureRepository: repo,
    participantRepository: repo,
    leaderboardRepository: repo,
    eventRepository: repo,
    attemptRepository: repo,
    enableElapsedTicker: false,
  );
  return controller;
}

void main() {
  testWidgets('registration failure shows snackbar and re-enables button', (
    tester,
  ) async {
    final ds = MockLocalDataSource(seedData: false);
    await ds.initialize();
    final repo = _FlakyRepository(ds)..throwOnCreate = true;
    final controller = await _controller(repo);
    addTearDown(controller.dispose);
    await controller.initialize();

    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: const MaterialApp(home: SessionGate()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tu Nombre'),
      'Nery',
    );
    await tester.enterText(
      find.widgetWithText(
        TextFormField,
        'Nickname / Alias para el Ranking',
      ),
      'nery',
    );
    await tester.tap(find.text('¡Comenzar aventura!'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text(networkErrorMessage), findsOneWidget);

    final button = tester.widget<ElevatedButton>(
      find
          .ancestor(
            of: find.text('¡Comenzar aventura!'),
            matching: find.byType(ElevatedButton),
          )
          .first,
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('manual code failure shows snackbar and re-enables button', (
    tester,
  ) async {
    final ds = MockLocalDataSource(seedData: false);
    await ds.initialize();
    final repo = _FlakyRepository(ds)..throwOnGetByCode = true;
    final controller = await _controller(repo);
    addTearDown(controller.dispose);
    await controller.initialize();
    await controller.startParticipant(name: 'Nery', nickname: 'nery');

    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: const MaterialApp(home: ManualCodeScreen()),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'ANDROID-MASTER');
    await tester.tap(find.text('Validar gimnasio'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text(networkErrorMessage), findsOneWidget);

    final button = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton).first,
    );
    expect(button.onPressed, isNotNull);
  });
}
```

- [x] **Step 2: Correr el test para verlo fallar**

Run: `flutter test test/widgets/action_error_feedback_test.dart`
Expected: FAIL — `networkErrorMessage` no existe (el import rompe), y los callbacks no muestran SnackBar.

- [x] **Step 3: Crear el helper**

Crear `lib/core/utils/snack_bar_utils.dart`:

```dart
import 'package:flutter/material.dart';

const networkErrorMessage = 'Sin conexión, intenta de nuevo';

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

void showNetworkError(BuildContext context) =>
    showSnack(context, networkErrorMessage);
```

- [x] **Step 4: Envolver `_start` en welcome_screen.dart**

Sustituir `_start` (líneas 28-36) por:

```dart
  Future<void> _start() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final controller = AppScope.read(context);
    try {
      await controller.startParticipant(
        name: _nameController.text.trim(),
        nickname: _nicknameController.text.trim(),
      );
    } catch (_) {
      if (mounted) showNetworkError(context);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
```

Import nuevo: `import '../../../core/utils/snack_bar_utils.dart';`

- [x] **Step 5: Mismo patrón en participant_setup_screen.dart**

Sustituir `_start` (líneas 26-36) por:

```dart
  Future<void> _start() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final controller = AppScope.read(context);
    try {
      await controller.startParticipant(
        name: _nameController.text.trim(),
        nickname: _nicknameController.text.trim(),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) showNetworkError(context);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
```

Import nuevo: `import '../../../core/utils/snack_bar_utils.dart';`

- [x] **Step 6: Mismo patrón en manual_code_screen.dart**

Sustituir `_submit` (líneas 26-36) por:

```dart
  Future<void> _submit([String? value]) async {
    if (_submitting) return;
    final code = (value ?? _controller.text).trim();
    if (code.isEmpty) return;
    setState(() => _submitting = true);
    final app = AppScope.read(context);
    try {
      final result = await app.discoverByCode(code);
      if (mounted) await handleDiscoveryResult(context, result);
    } catch (_) {
      if (mounted) showNetworkError(context);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
```

Import nuevo: `import '../../../core/utils/snack_bar_utils.dart';`

- [x] **Step 7: Mismo patrón en qr_scanner_screen.dart**

Sustituir `_handleValue` (líneas 43-58) por:

```dart
  Future<void> _handleValue(String value) async {
    if (_handling) return;
    _handling = true;
    final controller = AppScope.read(context);
    try {
      final result = await controller.discoverByQrValue(value);
      if (mounted) await handleDiscoveryResult(context, result);
    } catch (_) {
      if (mounted) showNetworkError(context);
    } finally {
      _handling = false;
    }
    if (mounted && _usingCamera) {
      setState(() {});
    }
  }
```

Import nuevo: `import '../../../core/utils/snack_bar_utils.dart';`

- [x] **Step 8: Correr el test hasta que pase**

Run: `flutter test test/widgets/action_error_feedback_test.dart`
Expected: PASS (2 tests).

- [x] **Step 9: Suite completa**

Run: `flutter test`
Expected: All tests passed.

- [x] **Step 10: Commit**

```bash
git add lib/core/utils/snack_bar_utils.dart lib/ui/screens/welcome/welcome_screen.dart lib/ui/screens/setup/participant_setup_screen.dart lib/ui/screens/discovery/manual_code_screen.dart lib/ui/screens/discovery/qr_scanner_screen.dart test/widgets/action_error_feedback_test.dart
git commit -m "fix: recover participant actions from network failures"
```

---

### Task 6: Submit de reto a prueba de fallos (A7)

**Files:**
- Modify: `lib/ui/screens/challenge/challenge_screen.dart` (`_handleSubmit` + botón)
- Test: agregar caso en `test/widgets/action_error_feedback_test.dart`

- [x] **Step 1: Escribir el test RED**

Agregar al final de `main()` en `test/widgets/action_error_feedback_test.dart` (y el import de `challenge_screen.dart`):

```dart
import 'package:devfest_treasure_hunt/domain/entities/attempt.dart' as attempt_entity show Attempt;
```

No — usar el import de Attempt que ya existe. Agregar import de pantalla:

```dart
import 'package:devfest_treasure_hunt/ui/screens/challenge/challenge_screen.dart';
```

Nuevo repositorio con fallo de escritura — agregar esta clase a la clave del archivo de test:

```dart
class _FlakyAttemptRepository extends MockAppRepository {
  _FlakyAttemptRepository(super.dataSource);

  bool throwOnSaveAttempt = false;

  @override
  Future<void> saveAttempt(Attempt attempt) async {
    if (throwOnSaveAttempt) throw Exception('network down');
    return super.saveAttempt(attempt);
  }
}
```

Nuevo test:

```dart
  testWidgets('challenge submit failure shows snackbar and re-enables form', (
    tester,
  ) async {
    final ds = MockLocalDataSource(seedData: false);
    await ds.initialize();
    final repo = _FlakyAttemptRepository(ds)..throwOnSaveAttempt = true;
    final controller = AppController(
      treasureRepository: repo,
      participantRepository: repo,
      leaderboardRepository: repo,
      eventRepository: repo,
      attemptRepository: repo,
      enableElapsedTicker: false,
    );
    addTearDown(controller.dispose);
    await controller.initialize();
    await controller.startParticipant(name: 'Nery', nickname: 'nery');

    final gym = controller.treasures.firstWhere(
      (t) => t.challenge?.hasOptions == true,
    );
    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: MaterialApp(home: ChallengeScreen(gym: gym)),
      ),
    );
    await tester.pump();

    await tester.tap(find.text(gym.challenge!.options!.first));
    await tester.pump();
    await tester.tap(find.text('Enviar respuesta'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text(networkErrorMessage), findsOneWidget);
    expect(find.text('Enviar respuesta'), findsOneWidget);

    final button = tester.widget<ElevatedButton>(
      find
          .ancestor(
            of: find.text('Enviar respuesta'),
            matching: find.byType(ElevatedButton),
          )
          .first,
    );
    expect(button.onPressed, isNotNull);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
```

- [x] **Step 2: Correr el test para verlo fallar**

Run: `flutter test test/widgets/action_error_feedback_test.dart --plain-name 'challenge submit failure'`
Expected: FAIL — sin SnackBar (la excepción revienta el test o el botón queda bloqueado).

- [x] **Step 3: Hacer `_handleSubmit` async con try/catch y spinner en el botón**

En `lib/ui/screens/challenge/challenge_screen.dart`, sustituir `_handleSubmit` (líneas 59-67) por:

```dart
  Future<void> _handleSubmit() async {
    if (_submitted || _submitting) return;
    _timer?.cancel();
    setState(() {
      _submitted = true;
      _submitting = true;
    });

    final answer = _selectedAnswer ?? _textController.text;
    final controller = AppScope.of(context);
    try {
      await controller.submitChallenge(gym.id, answer);
    } catch (_) {
      if (!mounted) return;
      showNetworkError(context);
      setState(() {
        _submitted = false;
        _submitting = false;
      });
    }
  }
```

Campo nuevo en el estado (junto a `_submitted`, línea 27):

```dart
  bool _submitting = false;
```

Import nuevo:

```dart
import '../../../core/utils/snack_bar_utils.dart';
```

El botón de submit (líneas 329-332) pasa a:

```dart
            ElevatedButton(
              onPressed: canSubmit && !_submitting ? _handleSubmit : null,
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Enviar respuesta'),
            ),
```

- [x] **Step 4: Correr el test hasta que pase**

Run: `flutter test test/widgets/action_error_feedback_test.dart`
Expected: PASS (3 tests).

- [x] **Step 5: Suite completa**

Run: `flutter test`
Expected: All tests passed.

- [x] **Step 6: Commit**

```bash
git add lib/ui/screens/challenge/challenge_screen.dart test/widgets/action_error_feedback_test.dart
git commit -m "fix: recover challenge submit from network failures"
```

---

### Task 7: Feedback del Panel Staff (A7 + resultados `false`)

**Files:**
- Modify: `lib/state/app_controller.dart` (enum `StaffActionResult`, `grantMedal`)
- Modify: `lib/ui/screens/admin/admin_dashboard_screen.dart` (snackbars + reset try/catch)
- Modify: `test/state/admin_controller_test.dart` (expectativas del enum)
- Test: agregar casos en `test/widgets/admin_dashboard_test.dart`

- [x] **Step 1: Escribir el test RED**

Agregar a `test/widgets/admin_dashboard_test.dart`:

```dart
  testWidgets('staff sees reason when granting an inactive gym', (
    tester,
  ) async {
    await controller.setTreasureActive('gym-android', false);

    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: const MaterialApp(home: AdminDashboardScreen()),
      ),
    );
    await tester.pump();

    await tester.scrollUntilVisible(
      find.byKey(const Key('admin-participant-search')),
      500,
    );
    await tester.enterText(
      find.byKey(const Key('admin-participant-search')),
      'admin_ui',
    );
    await tester.pump();
    await tester.tap(find.text('Admin UI (admin_ui)'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Otorgar Android'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.text('No se pudo otorgar: gimnasio inactivo'),
      findsOneWidget,
    );
  });
```

- [x] **Step 2: Correr el test para verlo fallar**

Run: `flutter test test/widgets/admin_dashboard_test.dart --plain-name 'inactive gym'`
Expected: FAIL — sin SnackBar.

- [x] **Step 3: Enum + grantMedal en AppController**

En `lib/state/app_controller.dart`, junto a `const _adminPassword` (línea 22):

```dart
enum StaffActionResult {
  success,
  participantNotFound,
  gymNotFound,
  gymInactive,
  alreadyGranted,
}
```

Reemplazar `grantMedal` (líneas 270-299) por:

```dart
  Future<StaffActionResult> grantMedal({
    required String participantId,
    required String gymId,
  }) async {
    final participant = await _participantRepository.getParticipant(
      participantId,
    );
    if (participant == null) return StaffActionResult.participantNotFound;
    final gym = await _treasureRepository.getTreasure(gymId);
    if (gym == null) return StaffActionResult.gymNotFound;
    if (!gym.isActive) return StaffActionResult.gymInactive;
    if (participant.discoveredTreasureIds.contains(gymId)) {
      return StaffActionResult.alreadyGranted;
    }

    final updatedTreasures = [...participant.discoveredTreasureIds, gymId];
    final allTreasures = await _treasureRepository.getTreasures();
    final completed = updatedTreasures.length >= allTreasures.length;
    final updated = participant.copyWith(
      discoveredTreasureIds: updatedTreasures,
      points: participant.points + (gym.challenge?.points ?? gym.pointValue),
      medals: updatedTreasures.length,
      status: completed ? ParticipantStatus.completed : participant.status,
      completedAt: completed ? DateTime.now() : participant.completedAt,
    );

    await _participantRepository.updateParticipant(updated);
    if (_participant?.id == participantId) {
      _participant = updated;
    }
    await _reloadLeaderboard();
    notifyListeners();
    return StaffActionResult.success;
  }
```

- [x] **Step 4: Actualizar las expectativas existentes**

En `test/state/admin_controller_test.dart`:

Línea 53:
```dart
    expect(granted, StaffActionResult.success);
```

Líneas 71-84:
```dart
    expect(
      await controller.grantMedal(
        participantId: participant.id,
        gymId: 'gym-android',
      ),
      StaffActionResult.success,
    );
    expect(
      await controller.grantMedal(
        participantId: participant.id,
        gymId: 'gym-android',
      ),
      StaffActionResult.alreadyGranted,
    );
```

- [x] **Step 5: Snackbars en admin_dashboard_screen.dart**

Import nuevo:

```dart
import '../../../core/utils/snack_bar_utils.dart';
```

Mensaje de resultado — agregar como método en la clase de pantalla principal (junto a `_confirmReset`):

```dart
  String _staffResultMessage(StaffActionResult result) {
    switch (result) {
      case StaffActionResult.success:
        return 'Medalla otorgada';
      case StaffActionResult.participantNotFound:
        return 'No se pudo otorgar: participante no encontrado';
      case StaffActionResult.gymNotFound:
        return 'No se pudo otorgar: gimnasio no encontrado';
      case StaffActionResult.gymInactive:
        return 'No se pudo otorgar: gimnasio inactivo';
      case StaffActionResult.alreadyGranted:
        return 'La medalla ya estaba otorgada';
    }
  }
```

Nota: `_staffResultMessage` se usa desde el builder de la ficha; si la clase donde cae `_confirmReset` no es la misma que contiene la ficha, colocarlo como función de archivo superior a la clase (fuera de cualquier clase) — verificar el alcance al editar.

Botón "Otorgar ..." (líneas 500-506), sustituir:

```dart
                            OutlinedButton(
                              onPressed: () async {
                                final result = await controller.grantMedal(
                                  participantId: participant.id,
                                  gymId: treasure.id,
                                );
                                if (context.mounted &&
                                    result != StaffActionResult.success) {
                                  showSnack(
                                    context,
                                    _staffResultMessage(result),
                                  );
                                }
                                setSheetState(() {});
                              },
                              child: Text(
                                'Otorgar ${_adminGymLabel(treasure.track, treasure.gymName ?? treasure.title)}',
                              ),
                            ),
```

Community signal — sustituir las líneas 647-651:

```dart
    if (confirmed != true) return;
    if (!context.mounted) return;
    final result = await AppScope.read(context).grantMedal(
      participantId: participantId,
      gymId: 'gym-community',
    );
    if (context.mounted && result != StaffActionResult.success) {
      showSnack(context, _staffResultMessage(result));
    }
    setSheetState(() {});
```

Ajuste de puntos — sustituir el `onPressed` async del diálogo "Aplicar ajuste" (líneas 591-607):

```dart
                onPressed: () async {
                  final parsed = int.tryParse(rawDelta);
                  if (parsed == null) {
                    setDialogState(() {
                      error = 'Introduce un numero entero';
                    });
                    return;
                  }
                  try {
                    final ok = await AppScope.read(
                      context,
                    ).adjustParticipantPoints(
                      participantId: participantId,
                      delta: parsed,
                    );
                    if (!context.mounted) return;
                    showSnack(
                      context,
                      ok
                          ? 'Puntos actualizados'
                          : 'No se pudo actualizar: participante no encontrado',
                    );
                  } catch (_) {
                    if (context.mounted) showNetworkError(context);
                  } finally {
                    setSheetState(() {});
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  }
                },
```

Reset — sustituir líneas 89-96 en `_confirmReset`:

```dart
    if (confirmed == true) {
      if (!context.mounted) return;
      final controller = AppScope.read(context);
      try {
        await controller.resetDemo();
      } catch (_) {
        if (context.mounted) showNetworkError(context);
        return;
      }
      if (context.mounted && !controller.hasParticipant) {
        Navigator.of(context).pop();
      }
    }
```

- [x] **Step 6: Correr todos los tests del admin**

Run: `flutter test test/widgets/admin_dashboard_test.dart test/state/admin_controller_test.dart`
Expected: PASS (incluye el test nuevo de gimnasio inactivo).

- [x] **Step 7: Suite completa**

Run: `flutter test`
Expected: All tests passed.

- [x] **Step 8: Commit**

```bash
git add lib/state/app_controller.dart lib/ui/screens/admin/admin_dashboard_screen.dart test/state/admin_controller_test.dart test/widgets/admin_dashboard_test.dart
git commit -m "feat: give staff actions explicit failure feedback"
```

---

### Task 8: Datos corruptos no tumban la app (M8 + M7)

**Files:**
- Modify: `lib/domain/entities/participant.dart` (`tryFromJson`)
- Modify: `lib/domain/entities/treasure_item.dart` (`tryFromJson`)
- Modify: `lib/domain/entities/attempt.dart` (`tryFromJson`)
- Modify: `lib/domain/entities/discovery.dart` (`tryFromJson`)
- Modify: `lib/data/datasources/firebase_data_source.dart` (parseo tolerante + orden en cliente)
- Modify: `lib/ui/screens/admin/admin_dashboard_screen.dart` (firstWhere → indexWhere)
- Test: `test/data/tolerant_parsing_test.dart`

- [x] **Step 1: Escribir el test RED**

Crear `test/data/tolerant_parsing_test.dart`:

```dart
import 'package:devfest_treasure_hunt/data/datasources/firebase_data_source.dart';
import 'package:devfest_treasure_hunt/domain/entities/participant.dart';
import 'package:devfest_treasure_hunt/domain/entities/treasure_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tryFromJson returns null for malformed participant docs', () {
    expect(Participant.tryFromJson({'id': 'p1', 'nickname': 'x'}), isNull);
    expect(
      Participant.tryFromJson({
        'id': 'p1',
        'name': 'A',
        'nickname': 'a',
        'startedAt': 'not-a-date',
      }),
      isNull,
    );
  });

  test('tryFromJson parses a valid participant', () {
    final p = Participant.tryFromJson({
      'id': 'p1',
      'name': 'A',
      'nickname': 'a',
      'startedAt': '2026-10-07T17:45:11.699',
      'status': 'active',
      'discoveredTreasureIds': <String>[],
      'points': 0,
      'medals': 0,
    });
    expect(p, isNotNull);
    expect(p!.id, 'p1');
  });

  test('tryFromJson returns null for malformed treasure docs', () {
    expect(TreasureItem.tryFromJson({'id': 't1', 'title': 'X'}), isNull);
  });

  test('decodeTreasures skips malformed docs and sorts by order', () {
    Map<String, dynamic> valid(String id, int order) => {
      'id': id,
      'title': id,
      'description': 'desc',
      'code': 'CODE-$id',
      'qrValue': 'QR-$id',
      'clue': 'clue',
      'locationDescription': 'loc',
      'iconKey': 'code',
      'order': order,
    };

    final list = FirebaseDataSource.decodeTreasures([
      valid('b', 2),
      {'id': 'broken'},
      valid('a', 1),
    ]);

    expect(list.map((t) => t.id), ['a', 'b']);
  });
}
```

- [x] **Step 2: Correr el test para verlo fallar**

Run: `flutter test test/data/tolerant_parsing_test.dart`
Expected: FAIL — `tryFromJson`/`decodeTreasures` no existen.

- [x] **Step 3: tryFromJson en las 4 entidades**

En cada entidad, agregar `import 'package:flutter/foundation.dart';` y el método `tryFromJson` + actualizar `listFromJson`.

`participant.dart` (después del factory `fromJson`):

```dart
  static Participant? tryFromJson(Map<String, dynamic> json) {
    try {
      return Participant.fromJson(json);
    } catch (_) {
      debugPrint('Skipping malformed participant doc: ${json['id']}');
      return null;
    }
  }
```

Reemplazar `listFromJson` (líneas 99-101):

```dart
  static List<Participant> listFromJson(String json) => (jsonDecode(json) as List)
      .map((e) => Participant.tryFromJson(e as Map<String, dynamic>))
      .whereType<Participant>()
      .toList();
```

`treasure_item.dart` (después del factory `fromJson`):

```dart
  static TreasureItem? tryFromJson(Map<String, dynamic> json) {
    try {
      return TreasureItem.fromJson(json);
    } catch (_) {
      debugPrint('Skipping malformed treasure doc: ${json['id']}');
      return null;
    }
  }
```

Reemplazar `listFromJson` (líneas 179-182):

```dart
  static List<TreasureItem> listFromJson(String json) =>
      (jsonDecode(json) as List)
          .map((e) => TreasureItem.tryFromJson(e as Map<String, dynamic>))
          .whereType<TreasureItem>()
          .toList();
```

`attempt.dart` (después del factory `fromJson`):

```dart
  static Attempt? tryFromJson(Map<String, dynamic> json) {
    try {
      return Attempt.fromJson(json);
    } catch (_) {
      debugPrint('Skipping malformed attempt doc: ${json['id']}');
      return null;
    }
  }
```

Reemplazar `listFromJson` (líneas 38-39):

```dart
  static List<Attempt> listFromJson(String json) => (jsonDecode(json) as List)
      .map((e) => Attempt.tryFromJson(e as Map<String, dynamic>))
      .whereType<Attempt>()
      .toList();
```

`discovery.dart` (después del factory `fromJson`):

```dart
  static Discovery? tryFromJson(Map<String, dynamic> json) {
    try {
      return Discovery.fromJson(json);
    } catch (_) {
      debugPrint('Skipping malformed discovery doc: ${json['id']}');
      return null;
    }
  }
```

Reemplazar `listFromJson` (líneas 33-35):

```dart
  static List<Discovery> listFromJson(String json) => (jsonDecode(json) as List)
      .map((e) => Discovery.tryFromJson(e as Map<String, dynamic>))
      .whereType<Discovery>()
      .toList();
```

- [x] **Step 4: FirebaseDataSource tolerante + orden en cliente**

Sustituir `loadTreasures` (líneas 64-68) por:

```dart
  @override
  Future<List<TreasureItem>> loadTreasures() async {
    final snapshot = await _treasuresRef.get();
    return decodeTreasures(
      snapshot.docs.map((doc) => doc.data()).toList(),
    );
  }

  /// Malformed docs are skipped; ordering is done client-side so a doc
  /// missing the `order` field cannot silently disappear.
  static List<TreasureItem> decodeTreasures(List<Map<String, dynamic>> raws) {
    final treasures = raws
        .map(TreasureItem.tryFromJson)
        .whereType<TreasureItem>()
        .toList();
    treasures.sort((a, b) => a.order.compareTo(b.order));
    return treasures;
  }
```

Sustituir `loadParticipants` (líneas 80-84):

```dart
  @override
  Future<List<Participant>> loadParticipants() async {
    final snapshot = await _participantsRef.get();
    return snapshot.docs
        .map((doc) => Participant.tryFromJson(doc.data()))
        .whereType<Participant>()
        .toList();
  }
```

Sustituir `loadDiscoveries` (líneas 91-95):

```dart
  @override
  Future<List<Discovery>> loadDiscoveries() async {
    final snapshot = await _discoveriesRef.get();
    return snapshot.docs
        .map((doc) => Discovery.tryFromJson(doc.data()))
        .whereType<Discovery>()
        .toList();
  }
```

Sustituir `loadAttempts` (líneas 124-127):

```dart
  @override
  Future<List<Attempt>> loadAttempts() async {
    final snapshot = await _attemptsRef.get();
    return snapshot.docs
        .map((doc) => Attempt.tryFromJson(doc.data()))
        .whereType<Attempt>()
        .toList();
  }
```

- [x] **Step 5: firstWhere → indexWhere en la ficha del admin**

En `lib/ui/screens/admin/admin_dashboard_screen.dart`, sustituir líneas 418-421:

```dart
            final controller = AppScope.of(context);
            final index = controller.participants.indexWhere(
              (p) => p.id == participantId,
            );
            if (index == -1) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                if (context.mounted) {
                  showSnack(context, 'El participante ya no existe');
                }
              });
              return const SizedBox.shrink();
            }
            final participant = controller.participants[index];
```

- [x] **Step 6: Test del crash del sheet**

Agregar a `test/widgets/admin_dashboard_test.dart`:

```dart
  testWidgets('participant detail sheet closes when the participant disappears', (
    tester,
  ) async {
    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: const MaterialApp(home: AdminDashboardScreen()),
      ),
    );
    await tester.pump();

    await tester.scrollUntilVisible(
      find.byKey(const Key('admin-participant-search')),
      500,
    );
    await tester.enterText(
      find.byKey(const Key('admin-participant-search')),
      'admin_ui',
    );
    await tester.pump();
    await tester.tap(find.text('Admin UI (admin_ui)'));
    await tester.pumpAndSettle();
    expect(find.text('Detalle de participante'), findsOneWidget);

    await controller.resetDemo();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    expect(find.text('Detalle de participante'), findsNothing);
    expect(find.text('El participante ya no existe'), findsOneWidget);
  });
```

- [x] **Step 7: Correr los tests nuevos**

Run: `flutter test test/data/tolerant_parsing_test.dart test/widgets/admin_dashboard_test.dart`
Expected: PASS.

- [x] **Step 8: Suite completa**

Run: `flutter test`
Expected: All tests passed.

- [x] **Step 9: Commit**

```bash
git add lib/domain/entities/participant.dart lib/domain/entities/treasure_item.dart lib/domain/entities/attempt.dart lib/domain/entities/discovery.dart lib/data/datasources/firebase_data_source.dart lib/ui/screens/admin/admin_dashboard_screen.dart test/data/tolerant_parsing_test.dart test/widgets/admin_dashboard_test.dart
git commit -m "fix: tolerate malformed docs and missing participant in sheet"
```

---

### Task 9: Verificación final

- [x] **Step 1: Formato**

Run:
```bash
dart format lib/ test/
```
Expected: sin cambios pendientes relevantes (imprime archivos formateados).

- [x] **Step 2: Análisis estático**

Run: `flutter analyze`
Expected: `No issues found!`

- [x] **Step 3: Suite completa**

Run: `flutter test`
Expected: `All tests passed!` con recuento ≥ 50 tests.

- [x] **Step 4: Build web**

Run: `flutter build web`
Expected: `✓ Built build/web`

- [x] **Step 5: Commit final si quedaron cambios**

```bash
git add -A
git status --short
git commit -m "chore: format and verify robustness changes"
```
(Solo si `git status` muestra cambios; si está limpio, omitir.)

---

## Notas para el ejecutor

- Los tests de `test/widgets/action_error_feedback_test.dart` usan `pump()` + `pump(Duration(milliseconds: 400))` después de las acciones para revelar el SnackBar; NO usen `pumpAndSettle()` ahí porque el timer del SnackBar puede hacerlo esperar.
- El test del reto termina con `pumpWidget(const SizedBox())` para desmontar `ChallengeScreen` y cancelar su timer.
- QR: `_handleValue` sigue el mismo patrón try/catch, pero no tiene test de widget porque `MobileScannerController` depende de plugins de plataforma; se verifica por revisión de código y por el test de código manual (mismo flujo `discoverByCode`/`discoverByQrValue`).
- Si `AppColors.textMuted` no existe al compilar `startup_error_screen.dart`, usar `AppColors.textSecondary`.
