# Configurar Firebase para una instancia propia

Esta guía describe la integración Firebase que existe actualmente y su modelo
de datos. El modo predeterminado del repositorio es el demo local: no requiere
Firebase ni se conecta al proyecto usado para el evento.

> **Importante:** la integracion Firebase actual es un MVP para desarrollo. El
> cliente lee y escribe datos directamente, los participantes no inician
> sesión con Firebase Authentication y el panel de staff no tiene roles
> aplicados por Firestore Rules. No publiques una instancia con datos
> personales o permisos de escritura abiertos. Antes de usarla en producción,
> implementa autorización real y reglas probadas para cada operación.

## Requisitos

- Flutter y Dart compatibles con `pubspec.yaml`.
- Un proyecto Firebase propio.
- Una base de datos Cloud Firestore creada con el ID `(default)`, que es la
  única base que usa el código actual.
- Firebase Authentication con el proveedor correo/contraseña habilitado si se
  usará el inicio de sesión del panel Staff.
- Una app Firebase registrada por cada plataforma destino.
- Los application ID y bundle ID existentes de Android/iOS, para registrar
  las plataformas con los identificadores correctos.

## Configuración cliente

1. En Firebase Console, abre **Project settings > General** y registra las
   aplicaciones web, Android o Apple que realmente vayas a compilar. Usa los
   application ID/bundle ID existentes en el proyecto.
2. Copia `firebase-config.example.json` a `firebase-config.json`.
3. Sustituye los valores de ejemplo por la configuración de tu proyecto. Copia
   `apiKey`, `projectId`, `messagingSenderId`, `authDomain` y `storageBucket`
   de **Project settings > General**; usa el `appId` de la plataforma destino.
4. El archivo `firebase-config.json` está excluido de Git.
5. Activa Firebase explicitamente al ejecutar o compilar:

   ```bash
   flutter run -d chrome --dart-define-from-file=firebase-config.json
   flutter build web --release \
     --dart-define-from-file=firebase-config.json
   ```

El archivo debe incluir `"USE_FIREBASE": "true"`. Sin esta opción, la app
arranca con el demo local. Los valores de Firebase cliente identifican el
proyecto y la app; no son contraseñas ni sustituyen Firestore Rules.

Para compilar Android o iOS, usa los mismos defines y configura el SDK nativo
correspondiente. Prueba cada plataforma por separado antes de publicar.

## Inicialización y datos sembrados

Al arrancar, `FirebaseDataSource.initialize()` usa el identificador fijo
`devfest-2026`:

1. Lee `events/devfest-2026`; si falta, crea el documento desde
   `MockData.buildEvent()`.
2. Si `treasures` está vacía, crea los ocho gimnasios de
   `MockData.buildTreasures()`.
3. Aplica la versión de contenido de retos `11`, conservando el estado
   `isActive` de gimnasios existentes.
4. No copia el ranking, participantes, descubrimientos ni intentos del JSON
   local de demo a Firestore.

Las cuentas de Authentication tampoco se crean automáticamente: crea tus
propias cuentas Staff en Firebase Console. El registro de participantes sigue
siendo sin cuenta y guarda los participantes en Firestore.

## Esquema de Firestore

Las fechas se serializan como cadenas ISO 8601, no como Firestore `Timestamp`.
En cada colección, el ID del documento coincide con el campo `id`.

```text
events/{eventId}
  treasures/{treasureId}
  participants/{participantId}
  discoveries/{discoveryId}
  attempts/{attemptId}
```

### `events/{eventId}`

Documento de evento. El ID usado actualmente es `devfest-2026`.

| Campo | Tipo | Descripcion |
|---|---|---|
| `id` | string | Identificador del evento |
| `name` | string | Nombre visible |
| `description` | string | Descripción |
| `dateLabel` | string o null | Fecha/lugar para mostrar |
| `active` | boolean | Estado del evento |
| `challengeContentVersion` | integer | Versión interna de migración de retos |

### `events/{eventId}/treasures/{treasureId}`

Un documento por gimnasio. El campo `challenge` es un mapa anidado opcional.

| Campo | Tipo | Descripcion |
|---|---|---|
| `id` | string | ID del gimnasio |
| `title`, `description` | string | Textos visibles |
| `code`, `clue` | string | Codigo y pista |
| `locationDescription` | string | Ubicación |
| `iconKey` | string | Clave de icono de la app |
| `order` | integer | Orden mostrado |
| `isActive` | boolean | Disponibilidad |
| `createdAt` | string ISO o null | Fecha de creación |
| `challengeType` | string | Nombre del tipo de reto |
| `challenge` | map o null | Configuracion del reto |
| `gymName`, `track` | string o null | Nombre y track |
| `pointValue` | integer | Puntos base |

El mapa `challenge` puede contener `type`, `question`, `options`,
`correctAnswer`, `hint`, `codeSnippet`, `timeLimitSeconds`, `points`,
`targetScore`, `questionBank` y `questionsRequired`. Cada elemento de
`questionBank` incluye `id`, `question`, `options`, `correctAnswer` y, de forma
opcional, `hint` y `codeSnippet`.

### `events/{eventId}/participants/{participantId}`

| Campo | Tipo | Descripcion |
|---|---|---|
| `id` | string | ID local del participante |
| `name`, `nickname` | string | Nombre y alias |
| `startedAt` | string ISO | Inicio de la sesión |
| `completedAt` | string ISO o null | Finalizacion |
| `status` | string | `active` o `completed` |
| `discoveredTreasureIds` | array de strings | IDs de gimnasios descubiertos |
| `points`, `medals` | integer | Puntuacion y medallas |
| `avatarEmoji` | string o null | Avatar opcional |

### `events/{eventId}/discoveries/{discoveryId}`

| Campo | Tipo | Descripcion |
|---|---|---|
| `id` | string | ID del descubrimiento |
| `participantId` | string | ID del participante |
| `treasureId` | string | ID del gimnasio |
| `discoveredAt` | string ISO | Fecha del descubrimiento |

El código actual usa una colección superior `discoveries`, no subcolecciones
bajo participantes.

### `events/{eventId}/attempts/{attemptId}`

| Campo | Tipo | Descripcion |
|---|---|---|
| `id` | string | ID del intento |
| `participantId` | string | ID del participante |
| `gymId` | string | ID del gimnasio |
| `answeredAt` | string ISO | Fecha del intento |
| `correct` | boolean | Resultado marcado |
| `answer` | string o null | Respuesta guardada, si aplica |
| `questionId` | string o null | ID de pregunta, si aplica |

## Permisos y seguridad

La app consulta las colecciones completas de participantes, descubrimientos e
intentos para construir ranking y paneles. También crea/actualiza participantes
y intentos, administra descubrimientos, actualiza `active` en el evento y
restablece datos. El acceso a estas operaciones no está separado actualmente
por rol de staff y participante.

Firebase Authentication valida correo/contraseña al entrar al panel, pero el
cliente no usa roles o claims para autorizar escrituras de Firestore. Ocultar
botones en la interfaz no es control de acceso. Las preguntas y respuestas
correctas incluidas en `treasures` también son descargables por clientes que
puedan leer esos documentos.

Por ello:

- No uses reglas de prueba o acceso global de lectura/escritura en una
  instancia publica.
- No asumas que iniciar sesión en Staff protege Firestore por sí solo.
- No guardes datos personales o contenido sensible hasta implementar reglas y
  autorización adecuadas; para un evento real, considera mover operaciones
  privilegiadas a un backend confiable o Cloud Functions.
- Valida las reglas con Firebase Emulator Suite antes de publicar.
- El repositorio no incluye `firestore.rules`; las reglas deben diseñarse
  según la política de acceso que implementes.

## Migrar los datos historicos del demo

La app no importa el JSON de demo a Firebase. Si necesitas cargar una
instantánea, prepara una migración administrativa aparte: valida y transforma
los documentos, elimina campos personales que no deban compartirse y carga
colecciones con una herramienta privilegiada como Firebase Admin SDK. Nunca
incluyas una service account ni una llave privada en Flutter, en el cliente web
ni en Git.

## Referencias de implementacion

- Composicion y seleccion demo/Firebase: `lib/app/app.dart`.
- Opciones cliente leidas de `--dart-define`: `lib/firebase_options.dart`.
- Mapeo de colecciones y operaciones: `lib/data/datasources/firebase_data_source.dart`.
- Entidades y serializacion: `lib/domain/entities/`.
- Datos base de gimnasios: `lib/data/datasources/mock_data.dart`.
