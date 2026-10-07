# Spec: Panel Staff en vivo — refresh, reset protegido y pausa de evento

Fecha: 2026-10-07 · Bloque 2 del plan post-robustez.

## Objetivo

Preparar el panel del staff para el evento real:

1. **A3 — Refresh real**: el pull-to-refresh del Panel Staff recarga datos frescos desde la fuente.
2. **A4 — Reset protegido**: el reset destruye datos; solo debe poder ejecutarse en modo demo/offline y con una confirmación explícita tecleando `RESET`.
3. **B8 — Pausa de evento**: un interrruptor global que frena nuevos descubrimientos (QR/código/reto) para todos los participantes, persistido en Firestore, sin estados UI extra en la app participante.

Decisiones ya tomadas con el usuario:
- Refresh: solo pull-to-refresh manual (sin auto-refresh periódico).
- Reset: teclear `RESET` + bloqueado cuando el panel está conectado (no offline).
- Pausa: bloquea descubrimientos y retos; mensajes puntuales de falla, sin banners ni estados adicionales en la app participante.

## Contexto existente

- `RefreshIndicator.onRefresh` en `lib/ui/screens/admin/admin_dashboard_screen.dart:42` es un no-op (`() async {}`).
- `AppController` cachea `_event` (getter `event`), recarga en `_reloadStaticData()` (evento + tesoros) y `_reloadLeaderboard()` (participantes + ranking). No hay método `refresh()` público.
- El reset actual (`_confirmReset` en `admin_dashboard_screen.dart:66`) muestra un diálogo de confirmación y llama a `controller.resetDemo()`. El `IconButton` del AppBar (`:36`) siempre está activo.
- El doc del evento en Firestore ya persiste `active` (`FirebaseDataSource._eventToJson`), y `loadEvent()` lo lee fresco. `Event.active` existe pero **nadie lo consulta** para bloquear.
- `DiscoverTreasureUseCase.execute` y `CompleteChallengeUseCase.execute` validan `participant` y `treasure.isActive`, pero no el estado del evento.
- `grantMedal` (staff) no pasa por los use cases de descubrimiento: otorga medallas directamente vía repositorio.
- Los switches exhaustivos existentes mapean fallas:
  - `lib/ui/screens/discovery/treasure_found_modal.dart:12` (`DiscoverFailure` → mensaje).
  - `lib/ui/screens/challenge/challenge_screen.dart` `_ResultScreen` muestra "Respuesta Incorrecta" genérico para cualquier falla.

## Alcance

### 1. Capa de datos — `EventRepository.setEventActive`

- Interfaz `EventRepository`: nuevo método `Future<void> setEventActive(bool active)`.
- `AppDataSource`: nuevo método `Future<void> setEventActive(bool active)`.
- `FirebaseDataSource.setEventActive(bool active)`: `await _eventRef.update({'active': active})`.
- `MockLocalDataSource.setEventActive(bool active)`: muta `_event` en memoria (creando un `Event` nuevo con el flag cambiado). Sin persistencia en disco (rol demo).
- `MockAppRepository.setEventActive(...)`: delega al datasource.

### 2. Dominio — bloqueo por evento pausado en los use cases

- `DiscoverTreasureUseCase` gana parámetro `required EventRepository eventRepository`. En `execute`, tras validar el participante y antes de comprobar `treasure.isActive`, lee `(await eventRepository.getEvent()).active`; si es `false` devuelve `DiscoverResult.failure(DiscoverFailure.eventPaused, treasure: treasure)`.
- `CompleteChallengeUseCase` gana parámetro `required EventRepository eventRepository`. En `execute`, tras validar el participante, lee `event.active`; si es `false` devuelve `ChallengeResult.failure(ChallengeFailure.eventPaused)`.
- Nuevos valores: `DiscoverFailure.eventPaused`, `ChallengeFailure.eventPaused`.
- La lectura es **fresca** en cada intento (los participantes consultan Firestore al intentar descubrir), por lo que el estado se aplica en vivo sin necesidad de suscripciones.

### 3. `AppController`

- Pasa `eventRepository: repo` (el `MockAppRepository` implementa `EventRepository`) a ambos use cases.
- `Future<void> refresh()`: `await _reloadStaticData(); await _reloadLeaderboard(); notifyListeners();`.
- `bool get eventActive => _event?.active ?? true`.
- `Future<void> setEventActive(bool active)`: `await _eventRepository.setEventActive(active); await _reloadStaticData(); notifyListeners();`.

Comportamiento: con el evento pausado, los participantes no pueden descubrir (QR/código) ni completar retos; el staff sí puede `grantMedal`, ajustar puntos y resetear (si procede).

### 4. UI — Panel Staff (`admin_dashboard_screen.dart`)

**A3 Refresh:**
- `RefreshIndicator.onRefresh`:
  ```dart
  onRefresh: () async {
    try {
      await controller.refresh();
    } catch (_) {
      if (context.mounted) showNetworkError(context);
    }
  },
  ```

**A4 Reset protegido:**
- El `IconButton` de reset se habilita solo cuando `controller.offline == true`. En vivo (conectado a Firestore) queda deshabilitado (`onPressed: null`) con tooltip "Solo disponible en modo demo".
- El diálogo `_confirmReset` gana un `TextField`; el botón destructivo `Resetear` permanece deshabilitado hasta que el texto tecleado sea exactamente `RESET` (comparación trim).
- El resto del flujo (pop al panel si no hay participante, `showNetworkError` en errores) se mantiene.

**B8 Pausa de evento:**
- Nueva tarjeta "Estado del evento" al inicio del panel (antes de "Métricas del evento") con `StatusPill` (`Activo`/`Pausado`) y un `Switch`.
- Al cambiar el `Switch`, diálogo de confirmación:
  - Pausar: "¿Pausar el evento?" / "Los participantes no podrán descubrir gimnasios mientras esté pausado."
  - Reanudar: "¿Reanudar el evento?" / "Los participantes volverán a descubrir gimnasios."
- Confirmado → `controller.setEventActive(v)` (con try/catch → `showNetworkError`).

**Mensajes en la app participante (puntuales, sin banners):**
- `treasure_found_modal.dart` switch: `DiscoverFailure.eventPaused => 'Evento pausado — reintenta en unos minutos.'`.
- `challenge_screen.dart` `_ResultScreen`: cuando `result.isSuccess == false` y `result.failure == ChallengeFailure.eventPaused`, titular "Evento Pausado" y subtítulo "Los descubrimientos están pausados temporalmente." en lugar del texto genérico de respuesta incorrecta.

## Fuera de alcance

- Auto-refresh periódico / suscripciones (snapshot listeners) a Firestore.
- Banners o pantallas de estado "pausado" en la app participante.
- Cambios en `grantMedal`/`resetDemo`/ranking.
- Reglas de Firestore (se tratan por separado antes del evento).

## Estrategia de pruebas (TDD)

- `test/use_cases/discover_treasure_use_case_test.dart`: evento pausado → `DiscoverFailure.eventPaused`; evento activo → comportamiento actual intacto.
- `test/use_cases/complete_challenge_use_case_test.dart`: idem para `ChallengeFailure.eventPaused`.
- `test/state/app_controller_init_test.dart` (o nuevo de controller): `refresh()` recarga y notifica; `setEventActive()` persiste (repo fake) y actualiza `eventActive`; `eventActive` refleja evento pausado cargado.
- `test/widgets/admin_dashboard_test.dart`:
  - Pull-to-refresh invoca `refresh()` y repinta datos cambiados.
  - Toggle de pausa pide confirmación y llama `setEventActive` (y apply no re-pinta nada raro).
  - Modo online (`offline: false`): icono de reset deshabilitado.
  - Modo offline (`offline: true`): reset habilitado, pero `Resetear` deshabilitado hasta teclear `RESET`.
- Unitario de datos: `MockLocalDataSource.setEventActive` cambia el estado (y que `getEvent` posterior lo refleja).

## Criterios de aceptación

- En el panel, arrastrar hacia abajo actualiza ranking/participantes y métricas desde la fuente.
- En modo conectado, no hay forma de ejecutar el reset desde la UI del panel.
- En modo offline, reset requiere teclear `RESET` en el diálogo.
- Pausar el evento (panel) hace que un QR/código/reto devuelva el mensaje de evento pausado en un dispositivo participante (dato fresco en Firestore).
- Reanudar el evento restaura el descubrimiento normal.
- `flutter analyze` sin issues; todos los tests en verde (incluidos los existentes).