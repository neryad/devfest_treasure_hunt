# Diseño: Gimnasio desactivado no accesible para el participante

Fecha: 2026-10-07
Estado: Aprobado

## Problema

Cuando el staff desactiva un gimnasio (`setTreasureActive(id, false)`), el
participante sigue pudiendo *acceder* a él:

- En "Mis Gimnasios" el gimnasio se muestra como disponible (pill del tipo de
  reto, no "No disponible").
- Tocar el gimnasio abre `ChallengeScreen`, que renderiza el contenido del reto
  (pregunta, opciones, timer) sin comprobar `isActive`.

## Causa raíz

La lista de gimnasios del participante es un snapshot cargado una única vez en
`AppController.initialize()` y nunca se refresca cuando el staff cambia
`isActive`. Las pantallas confían en ese valor cacheado para el gateo visual y
la navegación.

La capa de dominio ya está correcta: `DiscoverTreasureUseCase`
(`discover_treasure_use_case.dart:92`) y `CompleteChallengeUseCase`
(`complete_challenge_use_case.dart:112`) re-leen el gimnasio **fresco** desde el
repositorio y rechazan `isActive == false`. Por eso el participante **no
consigue puntos/medallas**, pero sí ve el contenido del reto.

Nótese que esto solo ocurre en **modo conectado (Firestore)**. En modo demo
offline cada pestaña tiene su propio store en memoria, por lo que el toggle del
staff nunca alcanza al participante (comportamiento esperado, no es un bug).

## Decisión

Aplicar el enfoque recomendado A + B (defensa en profundidad):

- **A (núcleo): gatear la navegación al reto con una lectura fresca.** Los dos
  puntos de entrada a `ChallengeScreen` comprueban `isActive` re-leyendo del
  repositorio antes de navegar; si el gimnasio no está activo, se muestra un
  snackbar y NO se navega (no hay fuga de contenido).
- **B (pulido): pull-to-refresh manual en "Mis Gimnasios".** La lista gana un
  `RefreshIndicator` que re-lee datos frescos, de modo que el pill pasa a
  "No disponible" cuando el participante lo pide. No es auto-refresh en loop
  (respetamos la decisión previa de refresh exclusivamente manual).

## Componentes

### 1. `AppController.fetchTreasure(String id)`

`lib/state/app_controller.dart`. Nuevo método público que envuelve la lectura
fresca del repositorio de tesoros:

```dart
Future<TreasureItem?> fetchTreasure(String id) =>
    _treasureRepository.getTreasure(id);
```

Sigue el patrón de `grantMedal` y de los use cases: leer fresco a través del
repositorio, no del snapshot `_treasures`.

### 2. Helper compartido `openChallenge`

Nuevo archivo `lib/ui/screens/challenge/challenge_navigation.dart`:

```dart
const gymUnavailableMessage =
    'No disponible todavía: este gimnasio está desactivado.';

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

- Reutiliza `showSnack` / `showNetworkError` de `snack_bar_utils.dart`.
- El copy del snackbar es idéntico al que ya usa `treasure_found_modal.dart`
  para `DiscoverFailure.notActive`.
- `ChallengeScreen(gym: fresh)` recibe la copia **fresca**, no la cacheada.

### 3. Puntos de entrada que usan el helper

- `lib/ui/screens/treasures/treasures_screen.dart:88-93` — `_TreasureTile.onTap`
  reemplaza el `Navigator.push(...)` directo por `openChallenge(context, treasure)`.
  `TreasuresScreen` se mantiene como `StatelessWidget`.
- `lib/ui/screens/pokedex/pokedex_screen.dart:267-274` — el botón "Desafiar este
  Gimnasio" reemplaza el `Navigator.push(...)` por `openChallenge(context, gym)`
  (tras el `Navigator.pop(bottomSheetContext)`).

`ChallengeScreen` NO cambia: seguirá recibiendo un `TreasureItem` por constructor.
Los tests que lo pumpean directamente (p.ej. `action_error_feedback_test.dart`)
quedan intactos.

### 4. Pull-to-refresh en "Mis Gimnasios"

`lib/ui/screens/treasures/treasures_screen.dart` — el `build` de
`TreasuresScreen` devuelve directamente el `ListView` (el `Scaffold` lo provee
`home_shell`). Se envuelve ese `ListView` raíz en un `RefreshIndicator`:

```dart
return RefreshIndicator(
  onRefresh: () async {
    try {
      await controller.refresh();
    } catch (_) {
      if (context.mounted) showNetworkError(context);
    }
  },
  child: ListView(...),
);
```

El patrón exacto del try/catch + `showNetworkError` ya existe en
`admin_dashboard_screen.dart:45-52`.
`TreasuresScreen` vive dentro de un `IndexedStack` en `home_shell.dart`, así que
`initState` no se re-dispara al cambiar de tab; el pull manual es la garantía
consistente (misma decisión que en el panel staff: solo refresh manual, sin
auto-refresh).

## Manejo de errores

- La lectura fresca puede fallar (red): try/catch en `openChallenge` →
  `showNetworkError`. No se navega.
- El refresco de la lista puede fallar (red): try/catch → `showNetworkError`.
- Gimnasio `null` en la lectura fresca (fue eliminado): tratar igual que
  inactivo (snackbar "no disponible").

## Datos / flujo de datos

Sin cambios en el modelo de datos. Nuevo flujo del gate:

```
tap → fetchTreasure(id) [fresco]
        ├─ error → showNetworkError, no navega
        ├─ null o !isActive → snackbar gymUnavailableMessage, no navega
        └─ activo → push ChallengeScreen(gym: fresco)
```

## Pruebas (TDD)

### Controller (`test/state/app_controller_init_test.dart`)

- `fetchTreasure` devuelve el estado fresco: se desactiva un gimnasio vía
  `repository.setTreasureActive` después de `initialize()` y `fetchTreasure`
  devuelve la copia con `isActive == false` (mientras que `treasureById`, el
  snapshot, sigue devolviendo activo).

### Widget (`test/widgets/treasures_screen_test.dart`, archivo nuevo)

- **Tap en gimnasio desactivado:** controller inicializado con gimnasios
  activos; se desactiva uno vía repositorio; se pumpea `TreasuresScreen` en un
  `MaterialApp` con `AppScope`; tap en el tile pendiente → aparece el snackbar
  "No disponible todavía: este gimnasio está desactivado." y `find.byType(
  ChallengeScreen)` es `findsNothing`.
- **Tap en gimnasio activo (regresión):** con gimnasio activo, el tap sí
  navega a `ChallengeScreen`.
- **Pull-to-refresh actualiza la lista:** con la lista activa y stale, se
  desactiva un gimnasio en el repo y se invoca
  `tester.widget<RefreshIndicator>(...).onRefresh()` → tras `pumpAndSettle` el
  tile del gimnasio muestra la pill "No disponible".

### Criterios de aceptación

1. Un gimnasio desactivado por el staff **no se puede abrir** desde "Mis
   Gimnasios" ni desde "Desafiar este Gimnasio" (pokedex): snackbar + sin
   navegación a `ChallengeScreen`, en modo conectado.
2. Tras un pull-to-refresh en "Mis Gimnasios", el gimnasio desactivado muestra
   la pill "No disponible".
3. `ChallengeScreen` permanece sin cambios funcionales.
4. Suite completa en verde + `flutter analyze` limpio.

## Fuera de alcance

- Pantalla "No disponible" estatal dentro de `ChallengeScreen` (innecesaria:
  la fuga queda cerrada en la navegación y la capa de dominio bloquea el
  puntaje).
- Cambios en el modo demo offline (stores separadas por pestaña).
- Auto-refresh / polling.
- Refactorizar las rutas de tesoros de `AppController`.