# Panel Staff en vivo — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convertir el Panel Staff en una herramienta de evento real: refresh manual de datos, reset protegido (modo demo + teclear `RESET`) y pausa del evento persistida en Firestore que bloquea descubrimientos y retos.

**Architecture:** La pausa vive en `events/{eventId}.active` (Firestore). Los use cases `DiscoverTreasureUseCase` y `CompleteChallengeUseCase` leen `event.active` **fresco en cada ejecución** y devuelven la nueva falla `eventPaused`; `AppController` expone `refresh()`, `eventActive` y `setEventActive()`. El panel recarga con pull-to-refresh, añade una tarjeta de estado del evento y protege el reset.

**Tech Stack:** Dart/Flutter, Provider-free (AppScope/ChangeNotifier), `cloud_firestore`, `flutter_test`.

**Spec:** `docs/superpowers/specs/2026-10-07-panel-staff-en-vivo-design.md`

---

### Task 1: Persistir el estado activo del evento en la capa de datos

**Files:**
- Modify: `lib/domain/repositories/event_repository.dart`
- Modify: `lib/data/datasources/app_data_source.dart`
- Modify: `lib/data/datasources/mock_local_data_source.dart`
- Modify: `lib/data/datasources/firebase_data_source.dart`
- Modify: `lib/data/repositories/mock_app_repository.dart`
- Create: `test/data/mock_local_data_source_test.dart`

- [x] **Step 1: Write the failing test**

Create `test/data/mock_local_data_source_test.dart`:

```dart
import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('setEventActive persists the event state for subsequent loads', () async {
    final dataSource = MockLocalDataSource();
    await dataSource.initialize();
    final repository = MockAppRepository(dataSource);

    expect((await repository.getEvent()).active, isTrue);

    await repository.setEventActive(false);

    expect((await repository.getEvent()).active, isFalse);
  });
}
```

- [x] **Step 2: Run test to verify it fails**

Run: `flutter test test/data/mock_local_data_source_test.dart`
Expected: FAIL — compile error: `setEventActive` no existe en `EventRepository`.

- [x] **Step 3: Implement the data-layer methods**

`lib/domain/repositories/event_repository.dart` — add to the abstract class:

```dart
  Future<void> setEventActive(bool active);
```

`lib/data/datasources/app_data_source.dart` — add to the abstract class (after `loadEvent()`):

```dart
  Future<void> setEventActive(bool active);
```

`lib/data/datasources/mock_local_data_source.dart` — add after `loadEvent()`:

```dart
  @override
  Future<void> setEventActive(bool active) async {
    _event = Event(
      id: _event.id,
      name: _event.name,
      description: _event.description,
      dateLabel: _event.dateLabel,
      active: active,
    );
  }
```

`lib/data/datasources/firebase_data_source.dart` — add after `loadEvent()`:

```dart
  @override
  Future<void> setEventActive(bool active) async {
    await _eventRef.update({'active': active});
  }
```

`lib/data/repositories/mock_app_repository.dart` — add in the EventRepository section (after `getEvent`):

```dart
  @override
  Future<void> setEventActive(bool active) =>
      _dataSource.setEventActive(active);
```

- [x] **Step 4: Run test to verify it passes**

Run: `flutter test test/data/mock_local_data_source_test.dart`
Expected: PASS

- [x] **Step 5: Commit**

```bash
git add lib/domain/repositories/event_repository.dart lib/data/datasources/app_data_source.dart lib/data/datasources/mock_local_data_source.dart lib/data/datasources/firebase_data_source.dart lib/data/repositories/mock_app_repository.dart test/data/mock_local_data_source_test.dart
git commit -m "feat: persist event active state in the data layer"
```

---

### Task 2: Bloquear descubrimientos y retos mientras el evento está pausado

**Files:**
- Modify: `lib/domain/use_cases/discover_treasure_use_case.dart`
- Modify: `lib/domain/use_cases/complete_challenge_use_case.dart`
- Modify: `lib/state/app_controller.dart` (wiring `eventRepository`)
- Modify: `lib/ui/screens/discovery/treasure_found_modal.dart` (switche exhaustivo obligatorio)
- Test: `test/use_cases/discover_treasure_use_case_test.dart`
- Test: `test/use_cases/complete_challenge_use_case_test.dart`

- [x] **Step 1: Write failing tests**

In `test/use_cases/discover_treasure_use_case_test.dart`:
1. Add `eventRepository: repository` to the `useCase` construction in `setUp` (line 16-19):

```dart
    useCase = DiscoverTreasureUseCase(
      treasureRepository: repository,
      participantRepository: repository,
      eventRepository: repository,
    );
```

2. Add this test at the end of `main()`:

```dart
  test('paused event blocks any discovery', () async {
    final pid = await createParticipant('Paused');
    await repository.setEventActive(false);

    final result = await useCase.execute(
      participantId: pid,
      treasureId: 'gym-android',
    );

    expect(result.failure, DiscoverFailure.eventPaused);
    final participant = await repository.getParticipant(pid);
    expect(participant!.discoveredCount, 0);
  });
```

In `test/use_cases/complete_challenge_use_case_test.dart`:
1. Add `eventRepository: repository` to the `useCase` construction in `setUp` (line 16-20):

```dart
    useCase = CompleteChallengeUseCase(
      treasureRepository: repository,
      participantRepository: repository,
      attemptRepository: repository,
      eventRepository: repository,
    );
```

2. Add this test at the end of `main()`:

```dart
  test('paused event blocks challenge completion', () async {
    final participantId = await createParticipant();
    await repository.setEventActive(false);

    final result = await useCase.execute(
      participantId: participantId,
      gymId: 'gym-android',
      answer: 'AndroidManifest.xml',
    );

    expect(result.failure, ChallengeFailure.eventPaused);
    final participant = await repository.getParticipant(participantId);
    expect(participant!.points, 0);
    expect(participant.medals, 0);
  });
```

- [x] **Step 2: Run tests to verify they fail**

Run: `flutter test test/use_cases/discover_treasure_use_case_test.dart test/use_cases/complete_challenge_use_case_test.dart`
Expected: FAIL — compile error: `eventRepository` y `DiscoverFailure.eventPaused`/`ChallengeFailure.eventPaused` no existen.

- [x] **Step 3: Implement use cases, enum values, modal case and controller wiring**

`lib/domain/use_cases/discover_treasure_use_case.dart`:

```dart
import '../../core/utils/id_generator.dart';
import '../../domain/entities/discovery.dart';
import '../../domain/entities/participant.dart';
import '../../domain/entities/treasure_item.dart';
import '../../domain/repositories/event_repository.dart';
import '../../domain/repositories/participant_repository.dart';
import '../../domain/repositories/treasure_repository.dart';
```

Add `eventPaused` to the enum:

```dart
enum DiscoverFailure {
  participantNotFound,
  treasureNotFound,
  notActive,
  alreadyDiscovered,
  eventPaused,
}
```

Constructor — add the new required param and field:

```dart
  DiscoverTreasureUseCase({
    required TreasureRepository treasureRepository,
    required ParticipantRepository participantRepository,
    required EventRepository eventRepository,
  }) : // Keep public constructor names without leading underscores.
       // ignore: prefer_initializing_formals
       _treasureRepository = treasureRepository,
       // ignore: prefer_initializing_formals
       _participantRepository = participantRepository,
       // ignore: prefer_initializing_formals
       _eventRepository = eventRepository;

  final TreasureRepository _treasureRepository;
  final ParticipantRepository _participantRepository;
  final EventRepository _eventRepository;
```

In `execute`, right after the treasure null check (after the block that returns `treasureNotFound`), insert the event check (before `if (!treasure.isActive)`):

```dart
    final event = await _eventRepository.getEvent();
    if (!event.active) {
      return DiscoverTreasureResult.failure(
        DiscoverFailure.eventPaused,
        treasure: treasure,
      );
    }
```

`lib/domain/use_cases/complete_challenge_use_case.dart`:

```dart
import '../../core/utils/id_generator.dart';
import '../entities/attempt.dart';
import '../entities/participant.dart';
import '../entities/treasure_item.dart';
import '../repositories/attempt_repository.dart';
import '../repositories/event_repository.dart';
import '../repositories/participant_repository.dart';
import '../repositories/treasure_repository.dart';
```

Add `eventPaused` to the enum:

```dart
enum ChallengeFailure {
  participantNotFound,
  gymNotFound,
  notActive,
  alreadyCompleted,
  cooldownActive,
  invalidAnswer,
  eventPaused,
}
```

Constructor — add the new required param and field:

```dart
  CompleteChallengeUseCase({
    required TreasureRepository treasureRepository,
    required ParticipantRepository participantRepository,
    required AttemptRepository attemptRepository,
    required EventRepository eventRepository,
  }) : // Keep public constructor names without leading underscores.
       // ignore: prefer_initializing_formals
       _treasureRepository = treasureRepository,
       // ignore: prefer_initializing_formals
       _participantRepository = participantRepository,
       // ignore: prefer_initializing_formals
       _attemptRepository = attemptRepository,
       // ignore: prefer_initializing_formals
       _eventRepository = eventRepository;

  final TreasureRepository _treasureRepository;
  final ParticipantRepository _participantRepository;
  final AttemptRepository _attemptRepository;
  final EventRepository _eventRepository;
```

In `execute`, right after the participant null check (after the block that returns `participantNotFound`), insert the event check (before the `// 2. Validate gym` section):

```dart
    final event = await _eventRepository.getEvent();
    if (!event.active) {
      return ChallengeResult.failure(ChallengeFailure.eventPaused);
    }
```

`lib/state/app_controller.dart` — pass `eventRepository` to both use cases (they are built in the constructor; `_eventRepository` is already assigned just before):

```dart
    _discoverUseCase = DiscoverTreasureUseCase(
      treasureRepository: treasureRepository,
      participantRepository: participantRepository,
      eventRepository: eventRepository,
    );
```

```dart
    _completeChallengeUseCase = attemptRepository != null
        ? CompleteChallengeUseCase(
            treasureRepository: treasureRepository,
            participantRepository: participantRepository,
            attemptRepository: attemptRepository,
            eventRepository: eventRepository,
          )
        : null;
```

`lib/ui/screens/discovery/treasure_found_modal.dart` — add the case to the exhaustive switch (after `notActive`):

```dart
      DiscoverFailure.eventPaused =>
        'Evento pausado — reintenta en unos minutos.',
```

- [x] **Step 4: Run tests to verify they pass**

Run: `flutter test test/use_cases/ && flutter analyze`
Expected: PASS both files; `flutter analyze` con 0 issues (el switch exhaustivo quedó cubierto).

- [x] **Step 5: Commit**

```bash
git add lib/domain/use_cases/discover_treasure_use_case.dart lib/domain/use_cases/complete_challenge_use_case.dart lib/state/app_controller.dart lib/ui/screens/discovery/treasure_found_modal.dart test/use_cases/discover_treasure_use_case_test.dart test/use_cases/complete_challenge_use_case_test.dart
git commit -m "feat: block discoveries and challenges while the event is paused"
```

---

### Task 3: Exponer `refresh`, `eventActive` y `setEventActive` en el controller

**Files:**
- Modify: `lib/state/app_controller.dart`
- Test: `test/state/app_controller_init_test.dart`

- [x] **Step 1: Write failing tests**

Add to `test/state/app_controller_init_test.dart` `main()`:

```dart
  test('refresh reloads participants and notifies', () async {
    final ds = MockLocalDataSource(seedData: false);
    await ds.initialize();
    final repo = _FlakyRepository(ds);
    await repo.createParticipant(
      id: 'participant-1',
      name: 'Uno',
      nickname: 'uno',
      startedAt: DateTime.now(),
    );
    final controller = _controller(repo, ds);
    addTearDown(controller.dispose);
    await controller.initialize();

    var notifications = 0;
    controller.addListener(() => notifications++);

    await repo.createParticipant(
      id: 'participant-2',
      name: 'Dos',
      nickname: 'dos',
      startedAt: DateTime.now(),
    );
    await controller.refresh();

    expect(controller.participants.length, 2);
    expect(notifications, greaterThan(0));
  });

  test('setEventActive updates eventActive and persists', () async {
    final ds = MockLocalDataSource();
    await ds.initialize();
    final repo = _FlakyRepository(ds);
    final controller = _controller(repo, ds);
    addTearDown(controller.dispose);
    await controller.initialize();

    expect(controller.eventActive, isTrue);

    await controller.setEventActive(false);

    expect(controller.eventActive, isFalse);
    expect((await repo.getEvent()).active, isFalse);
  });

  test('eventActive reflects a paused event loaded at init', () async {
    final ds = MockLocalDataSource();
    await ds.initialize();
    await ds.setEventActive(false);
    final repo = _FlakyRepository(ds);
    final controller = _controller(repo, ds);
    addTearDown(controller.dispose);
    await controller.initialize();

    expect(controller.eventActive, isFalse);
  });
```

- [x] **Step 2: Run tests to verify they fail**

Run: `flutter test test/state/app_controller_init_test.dart`
Expected: FAIL — `refresh`, `eventActive` y `setEventActive` no existen en `AppController`.

- [x] **Step 3: Implement the controller API**

`lib/state/app_controller.dart` — add near the other getters (after `bool get adminSignedIn`):

```dart
  bool get eventActive => _event?.active ?? true;
```

Add near the other public actions (after `setTreasureActive`):

```dart
  /// Re-reads event, treasures, participants and ranking from the source.
  Future<void> refresh() async {
    await _reloadStaticData();
    await _reloadLeaderboard();
    notifyListeners();
  }

  Future<void> setEventActive(bool active) async {
    await _eventRepository.setEventActive(active);
    await _reloadStaticData();
    notifyListeners();
  }
```

`_eventRepository` es `late final EventRepository _eventRepository;` — ya existe (línea 68) y soporta el nuevo método porque `MockAppRepository` lo implementa desde Task 1.

- [x] **Step 4: Run tests to verify they pass**

Run: `flutter test test/state/app_controller_init_test.dart`
Expected: PASS (3 tests nuevos + los existentes)

- [x] **Step 5: Commit**

```bash
git add lib/state/app_controller.dart test/state/app_controller_init_test.dart
git commit -m "feat: add refresh, setEventActive and eventActive to controller"
```

---

### Task 4: Panel Staff — refresh real, reset protegido y toggle de pausa

**Files:**
- Modify: `lib/ui/screens/admin/admin_dashboard_screen.dart`
- Test: `test/widgets/admin_dashboard_test.dart`

- [x] **Step 1: Write failing tests**

Add to `test/widgets/admin_dashboard_test.dart` `main()` (el `setUp` existente crea un controller con `offline: false` por defecto):

```dart
  testWidgets('pull to refresh reloads participants and metrics', (
    tester,
  ) async {
    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: const MaterialApp(home: AdminDashboardScreen()),
      ),
    );
    await tester.pump();

    await repository.createParticipant(
      id: 'participant-refresh',
      name: 'Nuevo',
      nickname: 'nuevo',
      startedAt: DateTime.now(),
    );

    await tester.widget<RefreshIndicator>(
      find.byType(RefreshIndicator),
    ).onRefresh();
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Nuevo (nuevo)'),
      500,
    );
    expect(find.text('Nuevo (nuevo)'), findsOneWidget);
  });

  testWidgets('staff can pause and resume the event from the panel', (
    tester,
  ) async {
    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: const MaterialApp(home: AdminDashboardScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Estado del evento'), findsOneWidget);

    await tester.tap(find.byKey(const Key('admin-event-paused')));
    await tester.pumpAndSettle();
    expect(find.text('¿Pausar el evento?'), findsOneWidget);
    await tester.tap(find.text('Pausar'));
    await tester.pumpAndSettle();

    expect(controller.eventActive, isFalse);

    await tester.tap(find.byKey(const Key('admin-event-paused')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reanudar'));
    await tester.pumpAndSettle();

    expect(controller.eventActive, isTrue);
  });

  testWidgets('reset button is disabled when connected to Firestore', (
    tester,
  ) async {
    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: const MaterialApp(home: AdminDashboardScreen()),
      ),
    );
    await tester.pump();

    final button = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.restart_alt_rounded),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('reset stays disabled in offline mode until RESET is typed', (
    tester,
  ) async {
    final ds = MockLocalDataSource(seedData: false);
    await ds.initialize();
    final repo = MockAppRepository(ds);
    await repo.createParticipant(
      id: 'participant-offline',
      name: 'Offline',
      nickname: 'offline',
      startedAt: DateTime.now(),
    );
    final offlineController = AppController(
      treasureRepository: repo,
      participantRepository: repo,
      leaderboardRepository: repo,
      eventRepository: repo,
      resetStore: ds.reset,
      attemptRepository: repo,
      enableElapsedTicker: false,
      offline: true,
    );
    addTearDown(offlineController.dispose);
    await offlineController.initialize();

    await tester.pumpWidget(
      AppScope(
        controller: offlineController,
        child: const MaterialApp(home: AdminDashboardScreen()),
      ),
    );
    await tester.pump();

    final resetButton = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.restart_alt_rounded),
    );
    expect(resetButton.onPressed, isNotNull);

    await tester.tap(find.byIcon(Icons.restart_alt_rounded));
    await tester.pumpAndSettle();

    var confirmButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Resetear'),
    );
    expect(confirmButton.onPressed, isNull);

    await tester.enterText(
      find.byKey(const Key('admin-reset-confirm')),
      'reset',
    );
    await tester.pump();
    confirmButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Resetear'),
    );
    expect(confirmButton.onPressed, isNull);

    await tester.enterText(
      find.byKey(const Key('admin-reset-confirm')),
      'RESET',
    );
    await tester.pump();
    confirmButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Resetear'),
    );
    expect(confirmButton.onPressed, isNotNull);
  });
```

- [x] **Step 2: Run tests to verify they fail**

Run: `flutter test test/widgets/admin_dashboard_test.dart`
Expected: FAIL — no existe `find.byKey(Key('admin-event-paused'))`, el refresh no recarga (`() async {}`), el reset online está habilitado y el diálogo no tiene el campo `admin-reset-confirm`.

- [x] **Step 3: Implement the panel changes**

`lib/ui/screens/admin/admin_dashboard_screen.dart`:

1. AppBar reset button — conditionally enabled (line 34-38):

```dart
          IconButton(
            tooltip: controller.offline
                ? 'Resetear datos demo'
                : 'Solo disponible en modo demo',
            icon: const Icon(Icons.restart_alt_rounded),
            onPressed: controller.offline
                ? () => _confirmReset(context)
                : null,
          ),
```

2. `RefreshIndicator.onRefresh` (line 41-42):

```dart
      body: RefreshIndicator(
        onRefresh: () async {
          try {
            await controller.refresh();
          } catch (_) {
            if (context.mounted) showNetworkError(context);
          }
        },
```

3. Add `_EventStatusCard` as the first child of the `ListView`, before `SectionHeader(title: 'Métricas del evento')` (line 46):

```dart
            const _EventStatusCard(),
            const SectionHeader(title: 'Métricas del evento'),
```

4. Add the pause toggle + confirm dialog methods to the `AdminDashboardScreen` class (after `_confirmReset`):

```dart
  Future<void> _toggleEventPaused(BuildContext context) async {
    final controller = AppScope.read(context);
    final pausing = controller.eventActive;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          pausing ? '¿Pausar el evento?' : '¿Reanudar el evento?',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          pausing
              ? 'Los participantes no podrán descubrir gimnasios mientras esté pausado.'
              : 'Los participantes volverán a descubrir gimnasios.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(pausing ? 'Pausar' : 'Reanudar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    try {
      await AppScope.read(context).setEventActive(!pausing);
    } catch (_) {
      if (context.mounted) showNetworkError(context);
    }
  }
```

5. Replace the dialog in `_confirmReset` (lines 66-104) so the destructivo button requires typing `RESET`:

```dart
  Future<void> _confirmReset(BuildContext context) async {
    var typed = '';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            '¿Resetear la demo?',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Se restaurarán los datos de ejemplo del evento.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('admin-reset-confirm'),
                decoration: const InputDecoration(labelText: 'Escribe RESET'),
                onChanged: (value) => setDialogState(() => typed = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: typed.trim() == 'RESET'
                  ? () => Navigator.of(dialogContext).pop(true)
                  : null,
              child: const Text('Resetear'),
            ),
          ],
        ),
      ),
    );
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
  }
```

6. Add the `_EventStatusCard` widget at the end of the file (after the `AdminDashboardScreen` class, before `_MetricsGrid`):

```dart
class _EventStatusCard extends StatelessWidget {
  const _EventStatusCard();

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final active = controller.eventActive;
    return Card(
      child: ListTile(
        leading: StatusPill(
          label: active ? 'Activo' : 'Pausado',
          color: active ? AppColors.success : AppColors.danger,
          icon: active
              ? Icons.play_circle_rounded
              : Icons.pause_circle_rounded,
        ),
        title: const Text(
          'Estado del evento',
          style: TextStyle(fontSize: 14),
        ),
        trailing: Switch(
          key: const Key('admin-event-paused'),
          value: !active,
          onChanged: (_) => _toggleEventPaused(context),
          activeTrackColor: AppColors.primary,
        ),
      ),
    );
  }
}
```

Note: `AdminDashboardScreen` es `StatelessWidget`; `_EventStatusCard.build` lee `controller.eventActive`, y la pausa dispara `notifyListeners()` → `AppScope` reconstruye todo el árbol (incluida esta tarjeta) con el nuevo valor.

- [x] **Step 4: Run tests to verify they pass**

Run: `flutter test test/widgets/admin_dashboard_test.dart`
Expected: PASS (todos los tests, nuevos y existentes)

- [x] **Step 5: Commit**

```bash
git add lib/ui/screens/admin/admin_dashboard_screen.dart test/widgets/admin_dashboard_test.dart
git commit -m "feat: staff panel refresh, protected reset and event pause toggle"
```

---

### Task 5: Mensaje de evento pausado en la pantalla de reto

**Files:**
- Modify: `lib/ui/screens/challenge/challenge_screen.dart`
- Test: `test/widgets/action_error_feedback_test.dart`

- [x] **Step 1: Write failing test**

Add to `test/widgets/action_error_feedback_test.dart` `main()`:

```dart
  testWidgets('paused event shows Evento Pausado in the challenge result', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final ds = MockLocalDataSource();
    await ds.initialize();
    await ds.setEventActive(false);
    final repo = _FlakyRepository(ds);
    final controller = _controller(repo, ds);
    addTearDown(controller.dispose);
    await controller.initialize();
    await controller.startParticipant(name: 'Nery', nickname: 'nery_paused');

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

    expect(find.text('Evento Pausado'), findsOneWidget);
    expect(
      find.text('Los descubrimientos están pausados temporalmente.'),
      findsOneWidget,
    );
  });
```

- [x] **Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/action_error_feedback_test.dart --plain-name 'paused event'`
Expected: FAIL — el resultado muestra "Respuesta Incorrecta" porque `_ResultScreen` no distingue `eventPaused`. (El `expect(find.text('Evento Pausado'), findsOneWidget)` no encuentra el texto.)

- [x] **Step 3: Implement the result screen message**

`lib/ui/screens/challenge/challenge_screen.dart` — in `_ResultScreen.build` (line 410), add:

```dart
    final success = result.isSuccess;
    final paused = !success &&
        result.failure == ChallengeFailure.eventPaused;
```

Line 501, change the title `Text`:

```dart
                    Text(
                      success
                          ? '¡Medalla Conquistada!'
                          : paused
                          ? 'Evento Pausado'
                          : 'Respuesta Incorrecta',
```

In the `else` branch of the success/failure section (lines 527-543, the `else ...[` block), replace the two inner `Text`s with this split so the paused case shows its own copy:

```dart
                    if (paused)
                      const Text(
                        'Los descubrimientos están pausados temporalmente.',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                        ),
                      )
                    else ...[
                      const Text(
                        'La respuesta no es correcta.',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Puedes intentarlo de nuevo inmediatamente.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
```

- [x] **Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/action_error_feedback_test.dart`
Expected: PASS (todos los tests del archivo)

- [x] **Step 5: Commit**

```bash
git add lib/ui/screens/challenge/challenge_screen.dart test/widgets/action_error_feedback_test.dart
git commit -m "fix: show paused event message in challenge result"
```

---

### Task 6: Verificación final

**Files:** ninguno (solo comandos)

- [x] **Step 1: Format, analyze y suite completa**

Run:
```bash
dart format lib/ test/
flutter analyze
flutter test
```
Expected: format sin cambios pendientes o solo de estilo; `flutter analyze` con **0 issues**; **todos los tests en verde** (58 existentes + nuevos del Bloque 2).

- [x] **Step 2: Build web**

Run: `flutter build web`
Expected: `✓ Built build/web`

- [x] **Step 3: Commit si hubo cambios de formato**

```bash
git add -A
git status --short
# Si hay archivos modificados:
git commit -m "chore: format and verify panel staff en vivo changes"
```

- [x] **Step 4: Marcar el plan como completado**

```bash
sed -i '' 's/- \[ \]/- [x]/g' docs/superpowers/plans/2026-10-07-panel-staff-en-vivo.md
git add docs/superpowers/plans/2026-10-07-panel-staff-en-vivo.md
git commit -m "docs: mark panel staff en vivo plan tasks as completed"
```

---

## Resultado

Plan completado el 2026-10-07: las 6 tareas están marcadas como completadas. Verificación final: `dart format` sin cambios pendientes, `flutter analyze` sin issues, `flutter test` con 70 tests en verde y `flutter build web` exitoso (`✓ Built build/web`).