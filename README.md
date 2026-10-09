# DevMaster: DevFest Quest

Experiencia gamificada creada para **DevFest Santo Domingo 2026**. Los
participantes recorren ocho gimnasios tecnológicos, completan trivias,
acertijos y minijuegos, coleccionan medallas y compiten en un ranking en vivo.

[Abrir demo](https://demo-dev-tesoros.netlify.app/) ·
[Agenda día 1](https://devfest.gdgsantodomingo.org/schedule?day=1) ·
[Agenda día 2](https://devfest.gdgsantodomingo.org/schedule?day=2) ·
[Enviar feedback](https://docs.google.com/forms/d/e/1FAIpQLSeKLBT0vCD3AFrohM0BsSczxC-WicESU04z3HLXInMmx4YCng/viewform?usp=publish-editor)

![DevFest Master — conquista los ocho gimnasios tecnológicos](assets/images/devfest_master_banner.png)

## La experiencia

- Registro simple mediante nombre y alias, sin contraseña para participantes.
- Panel **DevMaster** con rango, puntos, tiempo, medallas y los ocho gimnasios.
- Preguntas asignadas dinámicamente para que los participantes no reciban
  siempre el mismo reto.
- Minijuegos táctiles adaptados a teléfonos y navegador.
- Ranking en vivo por puntos, medallas y tiempo.
- Panel de staff para administrar el evento, participantes, medallas y puntos.
- Modo local explícito para continuar una demostración cuando Firebase no está
  disponible.
- Aplicación web instalable como PWA.
- Diseño oscuro, responsive y medallas propias para cada track.

## Gimnasios

| Gimnasio | Track | Mecánica | Cómo se completa |
|---|---|---|---|
| **Debug Droid** | Android / KMP | Reto de código | Responder correctamente 4 preguntas de Android y Kotlin. |
| **Prompt Master** | IA | Trivia | Resolver 4 preguntas aleatorias sobre IA generativa, agentes y prompting. |
| **The Hidden Exploit** | Security | Búsqueda con QR | Encontrar 5 QR físicos y reconstruir el código de seguridad dentro de la app. |
| **Pixel Perfect** | Web / UI | Minijuego visual | Memorizar colores y acertar al menos 5 de 10 rondas; los aciertos adicionales otorgan puntos extra. |
| **Runway Rush** | Startup | Minijuego arcade | Mover la startup entre carriles y lanzar MVPs contra oleadas aleatorias antes de perder el runway. |
| **Scale the Cloud** | Cloud / Firebase | Trivia | Resolver 4 preguntas sobre arquitectura cloud y servicios de Firebase. |
| **Hall of Voices** | Speakers | Adivina quién | Identificar por escrito a 2 speakers aleatorios usando pistas basadas en la agenda. |
| **Community Signal** | Comunidad | Misión social | Unirse a GDG Santo Domingo, obtener la entrada del evento y validar ambas acciones con el staff. |

Los códigos y payloads operativos de los QR se mantienen fuera de este README
para no revelar las soluciones durante el evento.

## Stack

- Flutter y Dart.
- Material 3.
- Firebase Core y Cloud Firestore.
- `mobile_scanner` para los retos con QR.
- `shared_preferences` para conservar la sesión local del dispositivo.
- `url_launcher` para agenda, comunidad, redes y feedback.
- Web/PWA desplegable en Netlify.

## Arquitectura

El proyecto usa una separación por capas:

```text
UI → AppController/AppScope → casos de uso → repositorios → fuente de datos
```

```text
lib/
├── app/                  # composición de dependencias y arranque
├── core/                 # tema, utilidades y widgets compartidos
├── data/
│   ├── datasources/      # Firestore y fuente local para modo offline
│   ├── local/            # persistencia de sesión en el dispositivo
│   └── repositories/     # implementación de los contratos del dominio
├── domain/
│   ├── entities/         # evento, participante, gimnasio, intento, etc.
│   ├── repositories/     # interfaces de datos
│   └── use_cases/        # registro, retos, descubrimiento y ranking
├── state/                # controlador central e inyección hacia la UI
└── ui/screens/           # participante, gimnasios, retos, ranking y admin
```

En producción, `DevFestRoot` inicializa `FirebaseDataSource`. Si la conexión
falla, la pantalla de inicio permite reintentar o entrar conscientemente en
modo local; el cambio no ocurre de forma silenciosa.

## Requisitos

- Flutter 3.44 o una versión compatible con Dart 3.12.
- Chrome para desarrollo web.
- Android SDK o Xcode para ejecutar en dispositivos móviles.
- Un proyecto Firebase configurado para usar la persistencia compartida.

## Ejecutar localmente

```bash
git clone https://github.com/neryad/devfest_treasure_hunt.git
cd devfest_treasure_hunt
flutter pub get
flutter run
```

Para elegir un destino específico:

```bash
flutter devices
flutter run -d chrome
flutter run -d <device-id>
```

Para probar en un teléfono físico, la opción recomendada es conectarlo por USB,
habilitar el modo de desarrollo y ejecutarlo directamente con `flutter run`.
El acceso a la cámara desde una web requiere un contexto seguro (`https` o
`localhost`), por lo que los QR deben validarse desde el build publicado o una
instalación móvil.

## Firebase y persistencia

La fuente activa normal es Firestore, bajo el evento `devfest-2026`:

```text
events/devfest-2026
├── treasures
├── participants
├── discoveries
└── attempts
```

La definición base de los ocho gimnasios se encuentra en
`lib/data/datasources/mock_data.dart` y se utiliza para inicializar o migrar el
contenido del evento. La identificación de la sesión actual se conserva en el
dispositivo mediante `SharedPreferences`.

El repositorio incluye reglas mínimas en `firestore.rules`. Estas mantienen las
lecturas requeridas por la aplicación, validan la estructura de los datos de
juego y bloquean modificaciones públicas de la configuración y los gimnasios.
Antes de desplegarlas deben probarse con Firebase Emulator Suite:

```bash
firebase login
firebase deploy --only firestore:rules
```

Estas reglas son una protección transitoria. Como la aplicación todavía no usa
Firebase Authentication, no pueden comprobar que cada participante sea dueño
de su documento. La solución definitiva debe asociar cada participante con un
UID y mover las acciones administrativas a un backend confiable.

## Pruebas

```bash
flutter analyze
flutter test
```

La suite cubre casos de uso, persistencia, selección de preguntas, respuestas
incorrectas, administración y los principales flujos de widgets y minijuegos.

## Build web y Netlify

Genera la versión de producción con:

```bash
flutter build web --release
```

Publica el contenido de `build/web`. Para evitar mostrar una versión anterior
después de reemplazar el deploy, realiza una recarga completa o limpia los datos
de la PWA instalada.

## Enlaces

- [Repositorio](https://github.com/neryad/devfest_treasure_hunt)
- [DevFest Santo Domingo](https://devfest.gdgsantodomingo.org/)
- [GDG Santo Domingo en Instagram](https://www.instagram.com/gdgsantodomingo/)
- [GDG Santo Domingo en LinkedIn](https://www.linkedin.com/company/gdgsantodomingo/)
- [Código de conducta](https://devfest.gdgsantodomingo.org/code-of-conduct)

## Créditos

Creado con amor por y para la comunidad por **Dayern Gomez (Neryad)**, Mobile
Developer — “Edad de senior, corazón de junior y curiosidad de trainee”.

Gracias al equipo de **GDG Santo Domingo** y a **Eury Pérez** por la oportunidad
de convertir esta idea en una experiencia para DevFest Santo Domingo 2026.

[GitHub](https://github.com/neryad) ·
[LinkedIn](https://www.linkedin.com/in/dayern-gomez) ·
[YouTube](https://www.youtube.com/@neryad) ·
[X / Twitter](https://x.com/NeryadG) ·
[Instagram](https://www.instagram.com/neryad_dev/)
