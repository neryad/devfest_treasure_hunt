# Migración a Firebase

Este documento explica **exactamente** qué cambiar para pasar de
`MockLocalDataSource` a un `FirebaseDataSource`. La UI, los viewmodels y la
lógica de negocio **no cambian**.

## Contrato que se mantiene

Toda la app habla con estas interfaces:

- `AppDataSource` (data layer) — `lib/data/datasources/app_data_source.dart`
- `TreasureRepository`, `ParticipantRepository`, `LeaderboardRepository`,
  `EventRepository` (domain) — `lib/domain/repositories/`

La lógica central `DiscoverTreasureUseCase` ya valida en memoria con un
contrato async (`Future`), así que un repositorio Firestore encaja sin
cambios.

## Paso a paso

1. Añadir dependencias

   ```bash
   flutter pub add firebase_core firebase_auth cloud_firestore
   ```

2. Implementar `FirebaseDataSource implements AppDataSource` en
   `lib/data/datasources/firebase_data_source.dart`, mapeando:

   | Método AppDataSource | Firestore |
   |---|---|
   | `loadEvent()` | `events/{eventId}` |
   | `loadTreasures()` | `events/{eventId}/treasures` |
   | `saveTreasures()` | `set` por documento (isActive) |
   | `loadParticipants()` | `events/{eventId}/participants` |
   | `saveParticipant()` | `events/{eventId}/participants/{participantId}` |
   | `recordDiscovery()` | `events/{eventId}/participants/{participantId}/discoveries/{treasureId}` |
   | `getCurrentParticipantId()` | Firebase Auth `uid` |

3. Wire-up en `lib/app/app.dart` (`buildAppDependencies`): sustituir

   ```dart
   final dataSource = MockLocalDataSource(storage: SharedPrefsLocalStorage());
   ```

   por

   ```dart
   final dataSource = FirebaseDataSource();
   ```

   Nada más cambia: `MockAppRepository` cumple las mismas 4 interfaces.

4. (`Opcional`) Repos por dominio `FirebaseTreasureRepository`, etc. si se
   quiere granularidad de permisos/securrules; el router
   `/lib/app/app.dart` es el único punto de composición.

## Estructura Firestore propuesta (futuro)

```
events/{eventId}
├── public   { name, description, dateLabel, active }
├── treasures/{treasureId}
│     { id, title, description, code, qrValue, clue,
│       locationDescription, isActive, order, iconKey }
└── participants/{participantId}
      { id, name, nickname, startedAt, completedAt, status,
        discoveredCount }
      └── discoveries/{treasureId}
            { treasureId, discoveredAt }
```

El **ranking** en producción lo calcularía una Cloud Function sobre el
contador `discoveredCount + discoveredAt` de cada participante y escribiría
`leaderboards/{eventId}/{participantId}` para lectura en tiempo real.

## Qué NO hay que tocar

- Las pantallas (`lib/ui/`).
- `AppController` / `AppScope` (`lib/state/`).
- Los use cases (`lib/domain/use_cases/`).
- `DiscoverTreasureResult` y los códigos de estado.

## Reglas de seguridad (importante para producción)

- Lectura: público para `treasures` y `leaderboards`.
- Escritura de `discoveries`: solo propio UID y **transaccional** para
  impedir duplicados (anti-cheat mínimo).
- `isActive` solo lo modifica el panel admin con roles.