# Gimnasio Desactivado — Gateo UI Participante, Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bloquear que un participante abra o vea el contenido de un gimnasio que el staff desactivó, y permitir refrescar manualmente "Mis Gimnasios".

**Architecture:** La capa de dominio ya re-lee el gimnasio fresco (`isActive`) y bloquea el puntaje. Este plan cierra la UI: un helper `openChallenge` re-lee el estado fresco antes de navegar (los dos puntos de entrada lo usan) y `TreasuresScreen` gana un `RefreshIndicator` manual. `ChallengeScreen` no cambia.

**Tech Stack:** Flutter/Dart, ChangeNotifier (`AppController`), widget tests con `flutter_test`.

**Referencia:** Spec `docs/superpowers/specs/2026-10-07-gym-desactivado-ui-participante-design.md`.

**Resultado:** Implementado — los gimnasios desactivados no se abren desde la
UI del participante (gateo fresco en DevDex/tiles) y "Mis Gimnasios" gana
pull-to-refresh manual (pantalla actualmente no cableada; ver nota en la spec).

---

### Task 1: `AppController.fetchTreasure` — lectura fresca del gimnasio

**Files:**
- Create: (ninguno)
- Modify: `lib/state/app_controller.dart` (tras `treasureById`, ~línea 179)
- Test: `test/state/app_controller_init_test.dart` (`main()`)

- [x] **Step 1: Write the failing test**

Agrega este test a `main()` en `test/state/app_controller_init_test.dart`:

```dart
  test('fetchTreasure reads fresh state from the repository', () async {
    final ds = MockLocalDataSource(seedData: false);
    await ds.initialize();
    final repo = _FlakyRepository(ds);
    final controller = _controller(repo, ds);
    addTearDown(controller.dispose);
    await controller.initialize();

    expect(controller.treasureById('gym-android')?.isActive, isTrue);

    await repo.setTreasureActive('gym-android', false);

    expect((await controller.fetchTreasure('gym-android'))?.isActive, isFalse);
    expect(controller.treasureById('gym-android')?.isActive, isTrue);
  });
```

Nota: `_FlakyRepository` (líneas 11-28 del archivo) extiende `MockAppRepository`, así que hereda `setTreasureActive`. `_controller` (líneas 30-39) ya existe. Los seeds tienen el gimnasio `gym-android` (mock_data.dart).

- [x] **Step 2: Run test to verify it fails**

Run: `flutter test test/state/app_controller_init_test.dart --plain-name 'fetchTreasure'`
Expected: FAIL con "no member" / "fetchTreasure is not defined".

- [x] **Step 3: Write minimal implementation**

En `lib/state/app_controller.dart`, justo después de `treasureById` (línea ~179):

```dart
  /// Reads the current treasure state straight from the source instead of the
  /// cached snapshot, so availability checks reflect staff changes.
  Future<TreasureItem?> fetchTreasure(String id) =>
      _treasureRepository.getTreasure(id);
```

- [x] **Step 4: Run test to verify it passes**

Run: `flutter test test/state/app_controller_init_test.dart`
Expected: PASS (todos los tests del archivo).

- [x] **Step 5: Commit**

```bash
git add lib/state/app_controller.dart test/state/app_controller_init_test.dart
git commit -m "feat: expose fetchTreasure fresh read on controller"
```

---

### Task 2: Helper `openChallenge` y gateo de los puntos de entrada

**Files:**
- Create: `lib/ui/screens/challenge/challenge_navigation.dart`
- Modify: `lib/ui/screens/treasures/treasures_screen.dart:86-93` (onTap del tile)
- Modify: `lib/ui/screens/pokedex/pokedex_screen.dart:267-274` (botón "Desafiar este Gimnasio")
- Test: `test/widgets/treasures_screen_test.dart` (archivo nuevo)

- [x] **Step 1: Write the failing widget tests**

Create `test/widgets/treasures_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
import 'package:devfest_treasure_hunt/state/app_controller.dart';
import 'package:devfest_treasure_hunt/state/app_scope.dart';
import 'package:devfest_treasure_hunt/ui/screens/challenge/challenge_screen.dart';
import 'package:devfest_treasure_hunt/ui/screens/treasures/treasures_screen.dart';

const _unavailableMessage =
    'No disponible todavía: este gimnasio está desactivado.';

AppController _controller(MockAppRepository repo, MockLocalDataSource ds) =>
    AppController(
      treasureRepository: repo,
      participantRepository: repo,
      leaderboardRepository: repo,
      eventRepository: repo,
      resetStore: ds.reset,
      attemptRepository: repo,
      enableElapsedTicker: false,
    );

Future<void> _pumpScreen(WidgetTester tester, AppController controller) async {
  await tester.pumpWidget(
    AppScope(
      controller: controller,
      child: const MaterialApp(home: TreasuresScreen()),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('tap on a deactivated gym shows snackbar without navigating', (
    tester,
  ) async {
    final ds = MockLocalDataSource(seedData: false);
    await ds.initialize();
    final repo = MockAppRepository(ds);
    final controller = _controller(repo, ds);
    addTearDown(controller.dispose);
    await controller.initialize();

    await repo.setTreasureActive('gym-android', false);

    await _pumpScreen(tester, controller);

    await tester.tap(find.text('Gimnasio #01'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text(_unavailableMessage), findsOneWidget);
    expect(find.byType(ChallengeScreen), findsNothing);
  });

  testWidgets('tap on an active gym opens the challenge screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final ds = MockLocalDataSource(seedData: false);
    await ds.initialize();
    final repo = MockAppRepository(ds);
    final controller = _controller(repo, ds);
    addTearDown(controller.dispose);
    await controller.initialize();

    await _pumpScreen(tester, controller);

    await tester.tap(find.text('Gimnasio #01'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(ChallengeScreen), findsOneWidget);
  });
}
```

- [x] **Step 2: Run tests to verify the first fails and the second passes**

Run: `flutter test test/widgets/treasures_screen_test.dart`
Expected:
- "tap on a deactivated gym..." → FAIL (hoy ese tap NAVEGA: `find.byType(ChallengeScreen)` es 1 y no hay snackbar).
- "tap on an active gym..." → PASS (regresión, ya navega).

`gym-android` (order 1) no tiene timer (`timeLimitSeconds`), así que
`ChallengeScreen` no arranca un `Timer.periodic` y no hay timers pendientes al
terminar el test. El test de navegación fija `tester.view.physicalSize =
const Size(1080, 2400)` (mismo patrón que `action_error_feedback_test.dart`)
para que `ChallengeScreen` no desborde en el viewport por defecto de 800x600.

- [x] **Step 3: Write the helper and wire the entry points**

Create `lib/ui/screens/challenge/challenge_navigation.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../core/utils/snack_bar_utils.dart';
import '../../../domain/entities/treasure_item.dart';
import '../../../state/app_scope.dart';
import 'challenge_screen.dart';

const gymUnavailableMessage =
    'No disponible todavía: este gimnasio está desactivado.';

/// Opens [ChallengeScreen] only when the gym is still active, reading the
/// latest state instead of trusting a possibly stale cached snapshot.
Future<void> openChallenge(BuildContext context, TreasureItem gym) async {
  final app = AppScope.read(context);
  TreasureItem? fresh;
  try {
    fresh = await app.fetchTreasure(gym.id);
  } catch (_) {
    if (context.mounted) showNetworkError(context);
    return;
  }
  if (!context.mounted) return;
  if (fresh == null || !fresh.isActive) {
    showSnack(context, gymUnavailableMessage);
    return;
  }
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => ChallengeScreen(gym: fresh)),
  );
}
```

En `lib/ui/screens/treasures/treasures_screen.dart`:

1. Agrega el import del helper (junto a los imports de `challenge_screen.dart`):

```dart
import '../challenge/challenge_navigation.dart';
```

2. Reemplaza el `onTap` de `_TreasureTile` (líneas 88-93):

```dart
        onTap: () {
          if (revealed) return;
          openChallenge(context, treasure);
        },
```

En `lib/ui/screens/pokedex/pokedex_screen.dart`:

1. Agrega el import `import '../challenge/challenge_navigation.dart';`
2. Reemplaza el `onPressed` del botón "Desafiar este Gimnasio" (líneas 267-274):

```dart
                onPressed: () {
                  Navigator.of(bottomSheetContext).pop();
                  openChallenge(context, gym);
                },
```

- [x] **Step 4: Run tests to verify they pass**

Run: `flutter test test/widgets/treasures_screen_test.dart`
Expected: PASS (2 tests).

- [x] **Step 5: Confirm no regressions**

Run: `flutter analyze` y `flutter test test/widgets/action_error_feedback_test.dart`
Expected: analyze limpio; los 4 tests del archivo pasan (ChallengeScreen no cambió).

- [x] **Step 6: Commit**

```bash
git add lib/ui/screens/challenge/challenge_navigation.dart lib/ui/screens/treasures/treasures_screen.dart lib/ui/screens/pokedex/pokedex_screen.dart test/widgets/treasures_screen_test.dart
git commit -m "fix: block opening deactivated gyms from participant UI"
```

---

### Task 3: Pull-to-refresh manual en "Mis Gimnasios"

**Files:**
- Modify: `lib/ui/screens/treasures/treasures_screen.dart:29-45` (build de `TreasuresScreen`)
- Test: `test/widgets/treasures_screen_test.dart` (agregar un test)

- [x] **Step 1: Write the failing widget test**

Agrega a `main()` en `test/widgets/treasures_screen_test.dart` (reutilizando `_controller` y `_pumpScreen` del archivo):

```dart
  testWidgets('pull to refresh marks a deactivated gym as unavailable', (
    tester,
  ) async {
    final ds = MockLocalDataSource(seedData: false);
    await ds.initialize();
    final repo = MockAppRepository(ds);
    final controller = _controller(repo, ds);
    addTearDown(controller.dispose);
    await controller.initialize();

    await _pumpScreen(tester, controller);

    await repo.setTreasureActive('gym-android', false);
    await tester
        .widget<RefreshIndicator>(find.byType(RefreshIndicator))
        .onRefresh();
    await tester.pumpAndSettle();

    expect(find.text('No disponible'), findsOneWidget);
  });
```

- [x] **Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/treasures_screen_test.dart --plain-name 'pull to refresh'`
Expected: FAIL — no existe `RefreshIndicator` (`find.byType` lanza "zero widgets") y el pill sigue mostrando el tipo de reto.

- [x] **Step 3: Wrap the list in a RefreshIndicator**

En `lib/ui/screens/treasures/treasures_screen.dart`, `build` de `TreasuresScreen`
declara `final controller = AppScope.of(context);` al inicio (ya existe) y luego
devuelve `ListView(...)` (líneas 29-45). Reemplaza únicamente ese `return
ListView(...)` por un `return RefreshIndicator(...)` que lo envuelva — NO
vuelvas a declarar `controller`:

```dart
    return RefreshIndicator(
      onRefresh: () async {
        try {
          await controller.refresh();
        } catch (_) {
          if (context.mounted) showNetworkError(context);
        }
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
        children: [
          _Summary(
            found: found.length,
            total: treasures.length,
            pending: pending.length,
          ),
          Text('Conquistados', style: _sectionStyle),
          if (found.isEmpty) _EmptyFoundCard(),
          for (final t in found) _TreasureTile(treasure: t, revealed: true),
          const SizedBox(height: 20),
          Text('Por conquistar', style: _sectionStyle),
          for (final t in pending) _TreasureTile(treasure: t, revealed: false),
          const SizedBox(height: 20),
        ],
      ),
    );
```

Agrega el import de snackbars en `treasures_screen.dart` (el `controller` y el
`context` del `onRefresh` vienen del scope ya existente del build):

```dart
import '../../../core/utils/snack_bar_utils.dart';
```

- [x] **Step 4: Run tests to verify they pass**

Run: `flutter test test/widgets/treasures_screen_test.dart`
Expected: PASS (3 tests).

- [x] **Step 5: Commit**

```bash
git add lib/ui/screens/treasures/treasures_screen.dart test/widgets/treasures_screen_test.dart
git commit -m "feat: manual pull to refresh on mis gimnasios"
```

---

### Task 4: Verificación final y cierre del plan

**Files:**
- Modify: `docs/superpowers/plans/2026-10-07-gym-desactivado-ui-participante.md` (checkboxes a `[x]`)

- [x] **Step 1: Format**

```bash
dart format --output=none --set-exit-if-changed lib test
```

Si reporta archivos, corre `dart format lib test` e incluye esos cambios en el
commit de este task.

- [x] **Step 2: Analyze**

```bash
flutter analyze
```
Expected: "No issues found!".

- [x] **Step 3: Full suite**

```bash
flutter test
```
Expected: todos en verde (70 previos + 4 nuevos = ~74).

- [x] **Step 4: Web build**

```bash
flutter build web
```
Expected: "✓ Built build/web".

- [x] **Step 5: Marcar el plan completo**

Cambia todos los checkboxes `- [ ]` de este archivo a `- [x]` (los 4 tasks).
Agrega una línea final bajo el encabezado del plan confirmando:
`**Resultado:** Implementado — los gimnasios desactivados no se abren desde la
UI del participante y "Mis Gimnasios" se puede refrescar manualmente.`

- [x] **Step 6: Commit**

```bash
git add -A
git commit -m "chore: final verification and complete gym gating plan"
```

Verifica antes del commit: `git status` solo debe mostrar este plan,
`treasures_screen.dart`, y `treasures_screen_test.dart` (si `dart format`
cambió otros archivos, revísalo y stagia exclusivamente lo intencional;
NO subas artefactos de `build/` ni `.dart_tool/`).