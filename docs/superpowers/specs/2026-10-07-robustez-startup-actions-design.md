# Robustez: Arranque, Acciones y Datos Resilientes Design

## Objetivo

Que la app nunca se rompa ni se quede colgada ante fallos de red o datos malformados antes del evento del viernes. Cubre el bloque 1 de pulido pre-evento.

## Alcance

- Arranque con reintento y elección explícita antes de caer en modo local (A1, A2).
- Todas las acciones con spinner se recuperan de excepciones de red y dan feedback (A7).
- Docs de Firestore malformados no tumban la app (M8, M7).
- Sesión local huérfana se limpia con aviso (B10).

No cubre: refresh en vivo del Panel Staff (bloque 2), copy/typos (bloque 4), credenciales staff con Firebase Auth (post-evento).

## Diseño

### 1. Arranque con reintento y elección explícita

`buildAppDependencies()` (`lib/app/app.dart`) deja de tener `catch (_)` silencioso que cae a mock. Un fallo de `Firebase.initializeApp()` o de `dataSource.initialize()` se propaga al llamador.

El arranque se vuelve una máquina de estados en la raíz de la app:

1. **connecting** — splash actual con spinner.
2. **error** — pantalla de error: "No se pudo conectar con el evento", botón primario **Reintentar** (repite el intento de conexión) y botón secundario **Continuar sin conexión**.
3. **lista** — app normal con datos de Firestore.

"Continuar sin conexión" construye `MockLocalDataSource` de forma explícita y marca `offlineMode = true` en el controller.

`AppController.initialize()` (`lib/state/app_controller.dart:187-199`) se envuelve en try/catch: una excepción deja `_initializing = false` y expone un estado de error con reintento, nunca un splash infinito.

Mientras `offlineMode` sea true, `MaterialApp.builder` muestra un banner persistente arriba: "Sin conexión — datos locales, no se sincronizan".

### 2. Acciones a prueba de fallos de red

Patrón uniforme en todos los callbacks que muestran spinner:

```dart
try { ... } catch (_) {
  mostrarSnackBar('Sin conexión, intenta de nuevo');
} finally { _submitting = false; }
```

Un helper pequeño en `core/` evita repetir el snippet.

Cubiertos:

- Registro: `welcome_screen.dart`, `participant_setup_screen.dart`.
- Descubrimiento: `manual_code_screen.dart`, `qr_scanner_screen.dart`.
- Reto: submit en `challenge_screen.dart`.
- Staff: `grantMedal`, `adjustParticipantPoints`, community signal, reset en `admin_dashboard_screen.dart`.

Las acciones staff además dan feedback cuando el resultado es `false`/failure (hoy fallan en silencio): SnackBar con el motivo ("gimnasio inactivo", "medalla ya otorgada", "participante no encontrado").

### 3. Datos corruptos no tumban la app

- `fromJson` de `Participant`, `TreasureItem` y demás entidades devuelven `null` en vez de lanzar cuando falta un campo obligatorio o `DateTime.parse` falla. Los data sources filtran los `null` con `debugPrint`.
- `FirebaseDataSource.loadTreasures` quita `orderBy('order')` de Firestore y ordena en cliente: un doc editado a mano sin el campo deja de desaparecer silenciosamente.
- `firstWhere` sin `orElse` en la ficha de participante del admin (`admin_dashboard_screen.dart:419-421`) se maneja: si el participante ya no existe se cierra el bottom sheet con aviso.

### 4. Sesión huérfana

Si al restaurar la sesión `getParticipant(currentParticipantId)` devuelve `null`, se limpia `currentParticipantId` y Welcome muestra un breve aviso: "Tu sesión anterior ya no existe — regístrate de nuevo".

## Testing

TDD: un test RED por cada comportamiento nuevo antes de implementar.

- Widget test: fallo de arranque → pantalla de error con Reintentar; reintento → app normal; "Continuar sin conexión" → app local con banner offline.
- Widget/unit test: callback con excepción → SnackBar visible y spinner reiniciado.
- Unit test: `fromJson` con campos faltantes → `null`; data source filtra docs inválidos.
- Unit test: sesión con id huérfano → id limpio y participante null.
- Verificación final: `flutter test` completo y `flutter build web`.
