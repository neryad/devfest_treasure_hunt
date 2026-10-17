# Firebase Firestore MVP Design

## Objetivo

Conectar la app a Firebase/Firestore para que participantes, descubrimientos, intentos, activacion de gimnasios y operaciones staff puedan sincronizarse en una base centralizada antes del evento.

## Alcance MVP

Se implementara un `FirebaseDataSource implements AppDataSource` que usa el mismo contrato que `MockLocalDataSource`. La UI, repositorios y use cases deben seguir funcionando sin cambios de comportamiento.

Firestore usara el proyecto `devfest-master` y el evento fijo `devfest-2026`.

No se agregara edicion de preguntas/respuestas desde staff. Las preguntas y respuestas se siembran desde `MockData` y quedan como datos de evento, no como panel editable.

## Configuracion Firebase

Cada instalacion debe configurar su propio proyecto Firebase localmente; no
guardar configuracion de proyecto en este documento.

Firestore:

- Database ID: `(default)`
- Location: `nam5`
- Edition: Standard
- Mode inicial: test mode para desarrollo/demo rapido.

## Estructura Firestore

```text
events/devfest-2026
events/devfest-2026/treasures/{treasureId}
events/devfest-2026/participants/{participantId}
events/devfest-2026/discoveries/{discoveryId}
events/devfest-2026/attempts/{attemptId}
events/devfest-2026/meta/currentParticipant/{device}
```

Para `currentParticipant`, se mantendra local en `SharedPreferences` si es necesario. No hace falta sincronizarlo entre dispositivos porque representa la sesion local del participante.

## Seed Inicial

Al inicializar Firebase:

1. Leer `events/devfest-2026`.
2. Si no existe, crear el evento desde `MockData.buildEvent()`.
3. Leer `treasures`.
4. Si esta vacio, crear los 8 gimnasios desde `MockData.buildTreasures()`.
5. No sembrar participantes demo por defecto en Firebase.

## Modo de Activacion

La app usara Firebase por defecto en esta rama. Para reducir riesgo, el wiring tendra fallback local si la inicializacion Firebase falla.

## Reglas Operativas

- Staff no edita preguntas ni respuestas desde el panel.
- QR se generan fuera de la app usando los `qrValue` existentes.
- Ranking se calcula en cliente desde participantes, igual que ahora.
- Cloud Functions y Auth quedan fuera de este MVP.

## Testing

Se mantendran tests existentes sobre mock/local. Se agregaran tests unitarios pequenos para validar conversion de `Event` a mapa si se introduce helper. La verificacion principal sera `flutter test` y, si las dependencias lo permiten, `flutter build web`.
