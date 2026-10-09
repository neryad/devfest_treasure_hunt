// import '../../domain/entities/event.dart';
// import '../../domain/entities/gym_challenge.dart';
// import '../../domain/entities/participant.dart';
// import '../../domain/entities/treasure_item.dart';
// import '../../domain/entities/challenge_question.dart';

// /// Static seed data for the demo. Nothing here depends on storage or platform.
// class MockData {
//   static Event buildEvent() => const Event(
//     id: 'devfest-2026',
//     name: 'DevFest Master',
//     description: 'Conquista los 8 Gimnasios Tecnológicos del DevFest.',
//     dateLabel: '9 · 10 de octubre — Biblioteca Nacional',
//   );

//   static List<String> treasureIds() =>
//       buildTreasures().map((t) => t.id).toList();

//   static List<TreasureItem> buildTreasures() {
//     return [
//       const TreasureItem(
//         id: 'gym-android',
//         title: 'Gimnasio Android',
//         description: 'Debug Droid: demuestra dominio de Android y Kotlin.',
//         code: 'ANDROID-MASTER',
//         clue:
//             'Debug Droid conquistado. El siguiente lider espera en otro track.',
//         locationDescription: 'Stand Android / KMP',
//         iconKey: 'android',
//         order: 1,
//         challengeType: ChallengeType.code,
//         challenge: GymChallenge(
//           type: ChallengeType.code,
//           question:
//               'Que archivo declara permisos como CAMERA o INTERNET en Android?',
//           options: [
//             'AndroidManifest.xml',
//             'pubspec.yaml',
//             'MainActivity.kt',
//             'settings.gradle',
//           ],
//           correctAnswer: 'AndroidManifest.xml',
//           codeSnippet:
//               '<uses-permission android:name="android.permission.CAMERA" />',
//           points: 100,
//           questionBank: [
//             ChallengeQuestion(
//               id: 'android-permission',
//               question:
//                   'Puedo ver lo que está frente al teléfono, pero Android no me deja abrir los ojos. ¿Qué palabra falta?',
//               options: ['CAMERA', 'SCREEN', 'PHOTO', 'VISION'],
//               correctAnswer: 'CAMERA',
//               hint: 'Es el permiso necesario para escanear códigos QR.',
//               codeSnippet:
//                   '<uses-permission\n    android:name="android.permission._____" />',
//             ),
//             ChallengeQuestion(
//               id: 'android-variable',
//               question:
//                   'El jugador recibe daño, pero continúa teniendo tres vidas. ¿Cómo se corrige?',
//               options: ['vidas = 1', 'vidas -= 1', 'vidas + 1', 'vidas == 1'],
//               correctAnswer: 'vidas -= 1',
//               hint: 'La operación actual calcula un valor, pero no lo guarda.',
//               codeSnippet:
//                   'var vidas = 3\n\nfun perderVida() {\n  vidas - 1\n}',
//             ),
//             ChallengeQuestion(
//               id: 'android-null',
//               question:
//                   'El programa intenta medir algo que posiblemente no existe. ¿Qué expresión lo hace de forma segura?',
//               options: [
//                 'nombre?.length',
//                 'nombre!.length',
//                 'nombre++',
//                 'nombre:length',
//               ],
//               correctAnswer: 'nombre?.length',
//               hint:
//                   'Kotlin utiliza un operador especial para valores que pueden ser nulos.',
//               codeSnippet: 'val nombre: String? = null\nprintln(nombre.length)',
//             ),
//             ChallengeQuestion(
//               id: 'android-lifecycle',
//               question:
//                   'Una pantalla Android se crea, se hace visible y finalmente queda lista para interactuar. ¿Cuál es el orden correcto?',
//               options: [
//                 'onCreate → onStart → onResume',
//                 'onResume → onCreate → onStart',
//                 'onStart → onResume → onCreate',
//                 'onCreate → onResume → onStart',
//               ],
//               correctAnswer: 'onCreate → onStart → onResume',
//               hint:
//                   'Primero se crea, después comienza y finalmente se reanuda.',
//             ),
//           ],
//         ),
//         gymName: 'Debug Droid',
//         track: 'android',
//         pointValue: 100,
//       ),
//       const TreasureItem(
//         id: 'gym-ia',
//         title: 'Gimnasio IA',
//         description:
//             'Prompt Master: resuelve desafíos prácticos de inteligencia artificial.',
//         code: 'IA-MASTER',
//         clue:
//             'Prompt Master conquistado. La IA premia prompts claros y respuestas confiables.',
//         locationDescription: 'Área IA / Gemini',
//         iconKey: 'brain',
//         order: 2,
//         challengeType: ChallengeType.trivia,
//         challenge: GymChallenge(
//           type: ChallengeType.trivia,
//           question:
//               'Segun la charla, que diferencia mejor describe un flujo agentic frente a un prompt simple?',
//           options: [
//             'Puede planificar pasos y usar herramientas',
//             'Siempre responde mas rapido',
//             'No necesita contexto',
//             'Solo funciona sin internet',
//           ],
//           correctAnswer: 'Puede planificar pasos y usar herramientas',
//           timeLimitSeconds: 60,
//           points: 100,
//           questionBank: [
//             ChallengeQuestion(
//               id: 'ia-prompt',
//               question:
//                   'Una IA debe clasificar comentarios y solo puede responder POSITIVO o NEGATIVO. ¿Cuál es el mejor prompt?',
//               options: [
//                 'Analiza este comentario.',
//                 'Dime qué piensas.',
//                 'Clasifica el comentario como POSITIVO o NEGATIVO. Responde con una sola palabra.',
//                 'Háblame sobre sentimientos.',
//               ],
//               correctAnswer:
//                   'Clasifica el comentario como POSITIVO o NEGATIVO. Responde con una sola palabra.',
//               hint: 'Un buen prompt especifica la tarea y el formato esperado.',
//             ),
//             ChallengeQuestion(
//               id: 'ia-hallucination',
//               question:
//                   'La IA no tiene acceso a la agenda del evento. ¿Cuál respuesta es más confiable?',
//               options: [
//                 'La próxima charla comienza exactamente a las 3:17.',
//                 'No tengo la agenda disponible, así que no puedo confirmar la hora.',
//                 'Seguro comienza después del almuerzo.',
//                 'Todas las charlas comienzan a la misma hora.',
//               ],
//               correctAnswer:
//                   'No tengo la agenda disponible, así que no puedo confirmar la hora.',
//               hint:
//                   'Una IA confiable reconoce cuando no posee suficiente información.',
//             ),
//             ChallengeQuestion(
//               id: 'ia-few-shot',
//               question:
//                   'Antes de hacerle una pregunta a una IA, le muestras dos entradas con sus respuestas correctas para enseñarle el formato. ¿Qué técnica utilizas?',
//               options: [
//                 'Few-shot prompting',
//                 'Compresión de imágenes',
//                 'Balanceo de carga',
//                 'Cifrado simétrico',
//               ],
//               correctAnswer: 'Few-shot prompting',
//               hint:
//                   'La IA recibe unos pocos ejemplos antes de resolver la tarea.',
//             ),
//             ChallengeQuestion(
//               id: 'ia-context',
//               question:
//                   'Si entregas demasiado texto y el modelo deja fuera las primeras instrucciones, ¿qué límite alcanzaste?',
//               options: [
//                 'Ventana de contexto',
//                 'Resolución de pantalla',
//                 'Velocidad de internet',
//                 'Memoria del teléfono',
//               ],
//               correctAnswer: 'Ventana de contexto',
//               hint:
//                   'Es la cantidad de información que el modelo puede considerar a la vez.',
//             ),
//           ],
//         ),
//         gymName: 'Prompt Master',
//         track: 'ia',
//         pointValue: 100,
//       ),
//       const TreasureItem(
//         id: 'gym-security',
//         title: 'Gimnasio Security',
//         description:
//             'The Hidden Exploit: encuentra pistas fisicas y descifra el codigo final.',
//         code: 'SECURE2026',
//         clue: 'The Hidden Exploit conquistado. El codigo final fue SECURE2026.',
//         locationDescription: 'QRs escondidos en el venue',
//         iconKey: 'shield',
//         order: 3,
//         challengeType: ChallengeType.riddle,
//         challenge: GymChallenge(
//           type: ChallengeType.riddle,
//           question:
//               'Une los fragmentos encontrados en los QR fisicos e introduce el codigo final.',
//           hint: 'Los fragmentos forman una sola palabra con el ano del evento.',
//           correctAnswer: 'SECURE2026',
//           points: 100,
//         ),
//         gymName: 'The Hidden Exploit',
//         track: 'security',
//         pointValue: 100,
//       ),
//       const TreasureItem(
//         id: 'gym-web',
//         title: 'Gimnasio Web',
//         description:
//             'Pixel Perfect: resuelve un reto visual de UI y accesibilidad.',
//         code: 'WEB-MASTER',
//         clue:
//             'Pixel Perfect conquistado. Una buena UI tambien se mide por accesibilidad.',
//         locationDescription: 'Area Web / UX',
//         iconKey: 'globe',
//         order: 4,
//         challengeType: ChallengeType.miniGame,
//         challenge: GymChallenge(
//           type: ChallengeType.miniGame,
//           question:
//               'Memoriza el color de referencia y encuentra el tono idéntico.',
//           correctAnswer: 'PIXEL-PERFECT',
//           points: 100,
//           targetScore: 100,
//         ),
//         gymName: 'Pixel Perfect',
//         track: 'web',
//         pointValue: 100,
//       ),
//       const TreasureItem(
//         id: 'gym-startup',
//         title: 'Gimnasio Startup',
//         description: 'Runway Rush: sobrevive al caos de una startup.',
//         code: 'STARTUP-MASTER',
//         clue:
//             'Runway Rush conquistado. Llegaste al millon narrativo antes de quedarte sin runway.',
//         locationDescription: 'Area emprendimiento / networking',
//         iconKey: 'rocket',
//         order: 5,
//         challengeType: ChallengeType.miniGame,
//         challenge: GymChallenge(
//           type: ChallengeType.miniGame,
//           question:
//               'Evita bugs, churn y errores de deploy hasta alcanzar la meta.',
//           correctAnswer: 'RUNWAY-CLEARED',
//           points: 100,
//           targetScore: 100,
//         ),
//         gymName: 'Runway Rush',
//         track: 'startup',
//         pointValue: 100,
//       ),
//       const TreasureItem(
//         id: 'gym-cloud',
//         title: 'Gimnasio Cloud',
//         description: 'Scale the Cloud: responde arquitectura cloud y Firebase.',
//         code: 'CLOUD-MASTER',
//         clue:
//             'Scale the Cloud conquistado. La arquitectura escala mejor cuando es simple.',
//         locationDescription: 'Area Cloud / Firebase',
//         iconKey: 'cloud',
//         order: 6,
//         challengeType: ChallengeType.trivia,
//         challenge: GymChallenge(
//           type: ChallengeType.trivia,
//           question:
//               'Que servicio de Firebase usarias para guardar datos sincronizados de participantes?',
//           options: [
//             'Firestore',
//             'Crashlytics',
//             'Remote Config',
//             'Cloud Messaging',
//           ],
//           correctAnswer: 'Firestore',
//           timeLimitSeconds: 60,
//           points: 100,
//           questionBank: [
//             ChallengeQuestion(
//               id: 'cloud-persistence',
//               question:
//                   'El ranking se guarda solamente en la memoria del servidor. El servidor se reinicia y todos los puntos desaparecen. ¿Qué necesita la aplicación?',
//               options: [
//                 'Almacenamiento persistente',
//                 'Una pantalla más grande',
//                 'Más animaciones',
//                 'Un nuevo nombre de dominio',
//               ],
//               correctAnswer: 'Almacenamiento persistente',
//               hint:
//                   'Los datos importantes deben sobrevivir después de apagar el servidor.',
//             ),
//             ChallengeQuestion(
//               id: 'cloud-capacity',
//               question:
//                   'Un servidor puede atender 500 participantes. Llegan 2,000 participantes simultáneamente. ¿Cuántos servidores iguales hacen falta como mínimo?',
//               options: ['2', '3', '4', '5'],
//               correctAnswer: '4',
//               hint:
//                   'Divide la cantidad de participantes entre la capacidad de un servidor.',
//             ),
//             ChallengeQuestion(
//               id: 'cloud-load-balancer',
//               question:
//                   'Recibo una petición y decido a cuál de varios servidores enviarla para evitar que uno solo cargue con todo. ¿Qué soy?',
//               options: [
//                 'Balanceador de carga',
//                 'Base de datos',
//                 'Editor de código',
//                 'Sistema operativo',
//               ],
//               correctAnswer: 'Balanceador de carga',
//               hint: 'Su trabajo es distribuir el tráfico.',
//             ),
//             ChallengeQuestion(
//               id: 'cloud-storage',
//               question:
//                   'Los usuarios suben fotografías del evento. ¿Qué tipo de servicio conviene utilizar para almacenarlas?',
//               options: [
//                 'Almacenamiento de objetos',
//                 'Servicio de autenticación',
//                 'Sistema de notificaciones',
//                 'Balanceador de carga',
//               ],
//               correctAnswer: 'Almacenamiento de objetos',
//               hint:
//                   'Está diseñado para guardar imágenes, videos y otros archivos.',
//             ),
//           ],
//         ),
//         gymName: 'Scale the Cloud',
//         track: 'cloud',
//         pointValue: 100,
//       ),
//       const TreasureItem(
//         id: 'gym-speaker',
//         title: 'Gimnasio Speaker',
//         description:
//             'Hall of Voices: demuestra que estuviste atento a las charlas.',
//         code: 'SPEAKER-MASTER',
//         clue:
//             'Hall of Voices conquistado. Las mejores pistas salieron del escenario.',
//         locationDescription: 'Sala principal',
//         iconKey: 'mic',
//         order: 7,
//         challengeType: ChallengeType.trivia,
//         challenge: GymChallenge(
//           type: ChallengeType.trivia,
//           question:
//               'Que debes hacer para responder mejor las preguntas del Gimnasio Speaker?',
//           options: [
//             'Escuchar las charlas',
//             'Adivinar rapido',
//             'Buscar el QR mas cercano',
//             'Cerrar la app',
//           ],
//           correctAnswer: 'Escuchar las charlas',
//           timeLimitSeconds: 60,
//           points: 100,
//         ),
//         gymName: 'Hall of Voices',
//         track: 'speaker',
//         pointValue: 100,
//       ),
//       const TreasureItem(
//         id: 'gym-community',
//         title: 'Gimnasio Comunidad',
//         description:
//             'Community Signal: únete a GDG Santo Domingo, obtén tu entrada y valida con el staff.',
//         code: 'COMMUNITY-SIGNAL',
//         clue:
//             'Community Signal conquistado. La comunidad tambien se construye compartiendo.',
//         locationDescription: 'Booth de comunidad',
//         iconKey: 'people',
//         order: 8,
//         challengeType: ChallengeType.social,
//         challenge: GymChallenge(
//           type: ChallengeType.social,
//           question:
//               'Únete a GDG Santo Domingo, obtén tu entrada al DevFest y escanea el QR privado del staff.',
//           hint:
//               'Muestra al staff las dos confirmaciones para acceder al QR de validación.',
//           correctAnswer: 'COMMUNITY-SIGNAL',
//           points: 100,
//         ),
//         gymName: 'Community Signal',
//         track: 'community',
//         pointValue: 100,
//       ),
//     ];
//   }

//   /// 15 seeded participants with varied progress.
//   static List<Participant> buildSeedParticipants() {
//     final now = DateTime.now();
//     // Completed participants — all 8 gyms.
//     final carlos = _p(
//       now,
//       'participant-101',
//       'Carlos',
//       'carlos_dev',
//       18,
//       32,
//       discovered: [
//         'gym-android',
//         'gym-ia',
//         'gym-cloud',
//         'gym-security',
//         'gym-web',
//         'gym-startup',
//         'gym-speaker',
//         'gym-community',
//       ],
//       completedAfter: Duration(minutes: 18, seconds: 32),
//       points: 900,
//       medals: 8,
//       avatarEmoji: '😎',
//     );
//     final ana = _p(
//       now,
//       'participant-102',
//       'Ana',
//       'ana_builds',
//       21,
//       4,
//       discovered: [
//         'gym-android',
//         'gym-ia',
//         'gym-cloud',
//         'gym-security',
//         'gym-web',
//         'gym-startup',
//         'gym-speaker',
//         'gym-community',
//       ],
//       completedAfter: Duration(minutes: 21, seconds: 4),
//       points: 900,
//       medals: 8,
//       avatarEmoji: '🦊',
//     );
//     final marco = _p(
//       now,
//       'participant-103',
//       'Marco',
//       'marco_pixel',
//       25,
//       47,
//       discovered: [
//         'gym-android',
//         'gym-ia',
//         'gym-cloud',
//         'gym-security',
//         'gym-web',
//         'gym-startup',
//         'gym-speaker',
//         'gym-community',
//       ],
//       completedAfter: Duration(minutes: 25, seconds: 47),
//       points: 900,
//       medals: 8,
//       avatarEmoji: '🐉',
//     );
//     // In progress participants.
//     final laura = _p(
//       now,
//       'participant-104',
//       'Laura',
//       'laura_ui',
//       12,
//       40,
//       discovered: [
//         'gym-security',
//         'gym-android',
//         'gym-speaker',
//         'gym-ia',
//         'gym-web',
//         'gym-startup',
//       ],
//       points: 645,
//       medals: 6,
//       avatarEmoji: '🎨',
//     );
//     final pedro = _p(
//       now,
//       'participant-105',
//       'Pedro',
//       'pedro_flutter',
//       9,
//       15,
//       discovered: [
//         'gym-ia',
//         'gym-startup',
//         'gym-security',
//         'gym-community',
//         'gym-web',
//       ],
//       points: 515,
//       medals: 5,
//       avatarEmoji: '🦋',
//     );
//     final sofia = _p(
//       now,
//       'participant-106',
//       'Sofía',
//       'sofia_data',
//       15,
//       8,
//       discovered: [
//         'gym-android',
//         'gym-web',
//         'gym-startup',
//         'gym-ia',
//         'gym-cloud',
//         'gym-security',
//         'gym-community',
//       ],
//       points: 730,
//       medals: 7,
//       avatarEmoji: '🦊',
//     );
//     final diego = _p(
//       now,
//       'participant-107',
//       'Diego',
//       'diego_ops',
//       7,
//       55,
//       discovered: ['gym-speaker', 'gym-cloud', 'gym-android'],
//       points: 315,
//       medals: 3,
//       avatarEmoji: '🔧',
//     );
//     final valeria = _p(
//       now,
//       'participant-108',
//       'Valeria',
//       'vale_creative',
//       6,
//       20,
//       discovered: ['gym-ia', 'gym-startup'],
//       points: 215,
//       medals: 2,
//       avatarEmoji: '✨',
//     );
//     final miguel = _p(
//       now,
//       'participant-109',
//       'Miguel',
//       'mig_code',
//       5,
//       48,
//       discovered: ['gym-android'],
//       points: 130,
//       medals: 1,
//       avatarEmoji: '💡',
//     );
//     final pamela = _p(
//       now,
//       'participant-110',
//       'Pamela',
//       'pamela_k',
//       4,
//       33,
//       discovered: ['gym-web', 'gym-startup'],
//       points: 205,
//       medals: 2,
//       avatarEmoji: '🌟',
//     );
//     final isaac = _p(now, 'participant-111', 'Isaac', 'isaac_ml', 3, 12);
//     final gaby = _p(now, 'participant-112', 'Gaby', 'gaby_design', 2, 40);
//     final roberto = _p(
//       now,
//       'participant-113',
//       'Roberto',
//       'rob_ios',
//       8,
//       2,
//       discovered: [
//         'gym-security',
//         'gym-android',
//         'gym-startup',
//         'gym-community',
//         'gym-ia',
//         'gym-speaker',
//         'gym-web',
//         'gym-cloud',
//       ],
//       points: 900,
//       medals: 8,
//       avatarEmoji: '🚀',
//     );
//     final camila = _p(now, 'participant-114', 'Camila', 'cami_test', 1, 25);
//     final raul = _p(
//       now,
//       'participant-115',
//       'Raúl',
//       'raul_web',
//       10,
//       5,
//       discovered: [
//         'gym-android',
//         'gym-security',
//         'gym-community',
//         'gym-ia',
//         'gym-startup',
//         'gym-web',
//         'gym-cloud',
//       ],
//       points: 730,
//       medals: 7,
//       avatarEmoji: '🎧',
//     );
//     return [
//       carlos,
//       ana,
//       marco,
//       laura,
//       pedro,
//       sofia,
//       roberto,
//       raul,
//       diego,
//       valeria,
//       pamela,
//       miguel,
//       isaac,
//       gaby,
//       camila,
//     ];
//   }

//   static Participant _p(
//     DateTime now,
//     String id,
//     String name,
//     String nickname,
//     int minutesAgo,
//     int offsetSeconds, {
//     List<String> discovered = const [],
//     Duration? completedAfter,
//     int points = 0,
//     int medals = 0,
//     String? avatarEmoji,
//   }) {
//     final startedAt = now.subtract(
//       Duration(minutes: minutesAgo, seconds: offsetSeconds),
//     );
//     return Participant(
//       id: id,
//       name: name,
//       nickname: nickname,
//       startedAt: startedAt,
//       completedAt: completedAfter != null
//           ? startedAt.add(completedAfter)
//           : null,
//       status: completedAfter != null
//           ? ParticipantStatus.completed
//           : ParticipantStatus.active,
//       discoveredTreasureIds: discovered,
//       points: points,
//       medals: medals,
//       avatarEmoji: avatarEmoji,
//     );
//   }
// }
import '../../domain/entities/event.dart';
import '../../domain/entities/gym_challenge.dart';
import '../../domain/entities/participant.dart';
import '../../domain/entities/treasure_item.dart';
import '../../domain/entities/challenge_question.dart';

/// Static seed data for the demo. Nothing here depends on storage or platform.
class MockData {
  static Event buildEvent() => const Event(
    id: 'devfest-2026',
    name: 'DevFest Master',
    description: 'Conquista los 8 Gimnasios Tecnológicos del DevFest.',
    dateLabel: '9 · 10 de octubre — Biblioteca Nacional',
  );

  static List<String> treasureIds() =>
      buildTreasures().map((t) => t.id).toList();

  static List<TreasureItem> buildTreasures() {
    return [
      const TreasureItem(
        id: 'gym-android',
        title: 'Gimnasio Android',
        description: 'Debug Droid: demuestra dominio de Android y Kotlin.',
        code: 'ANDROID-MASTER',
        clue:
            'Debug Droid conquistado. El siguiente líder espera en otro track.',
        locationDescription: 'Stand Android / KMP',
        iconKey: 'android',
        order: 1,
        challengeType: ChallengeType.code,
        challenge: GymChallenge(
          type: ChallengeType.code,
          question:
              '¿Qué archivo declara permisos como CAMERA o INTERNET en Android?',
          options: [
            'AndroidManifest.xml',
            'pubspec.yaml',
            'MainActivity.kt',
            'settings.gradle',
          ],
          correctAnswer: 'AndroidManifest.xml',
          codeSnippet:
              '<uses-permission android:name="android.permission.CAMERA" />',
          points: 100,
          questionsRequired: 4,
          questionBank: [
            ChallengeQuestion(
              id: 'android-permission',
              question:
                  'Tu app necesita leer códigos QR con la cámara. ¿Qué palabra falta en el permiso?',
              options: ['MICROPHONE', 'CAMERA', 'LOCATION', 'BLUETOOTH'],
              correctAnswer: 'CAMERA',
              hint: 'Es el permiso de hardware que usa el escáner.',
              codeSnippet:
                  '<uses-permission\n    android:name="android.permission._____" />',
            ),
            ChallengeQuestion(
              id: 'android-variable',
              question:
                  'El jugador recibe daño y debe perder una vida. ¿Qué línea actualiza correctamente la variable?',
              options: ['vidas == 1', 'vidas + 1', 'vidas = 0', 'vidas -= 1'],
              correctAnswer: 'vidas -= 1',
              hint: 'Necesitas una asignación que guarde el nuevo valor.',
              codeSnippet:
                  'var vidas = 3\n\nfun perderVida() {\n  vidas - 1\n}',
            ),
            ChallengeQuestion(
              id: 'android-null',
              question:
                  'La variable nombre puede ser null. ¿Qué expresión evita un crash al medir su longitud?',
              options: [
                'nombre!.length',
                'nombre.length()',
                'nombre?.length',
                'nombre:length',
              ],
              correctAnswer: 'nombre?.length',
              hint:
                  'Kotlin tiene un operador para acceder de forma segura a valores nulos.',
              codeSnippet: 'val nombre: String? = null\nprintln(nombre.length)',
            ),
            ChallengeQuestion(
              id: 'android-lifecycle',
              question:
                  'Una Activity se crea, se muestra y queda lista para interactuar. ¿Cuál es el orden de sus callbacks?',
              options: [
                'onResume → onCreate → onStart',
                'onStart → onResume → onCreate',
                'onCreate → onResume → onStart',
                'onCreate → onStart → onResume',
              ],
              correctAnswer: 'onCreate → onStart → onResume',
              hint:
                  'Revisa el ciclo de vida: crear, mostrar y luego interactuar.',
            ),
          ],
        ),
        gymName: 'Debug Droid',
        track: 'android',
        pointValue: 100,
      ),
      const TreasureItem(
        id: 'gym-ia',
        title: 'Gimnasio IA',
        description:
            'Prompt Master: resuelve desafíos prácticos de inteligencia artificial.',
        code: 'IA-MASTER',
        clue:
            'Prompt Master conquistado. La IA premia prompts claros y respuestas confiables.',
        locationDescription: 'Área IA / Gemini',
        iconKey: 'brain',
        order: 2,
        challengeType: ChallengeType.trivia,
        challenge: GymChallenge(
          type: ChallengeType.trivia,
          question:
              'Según la charla, ¿qué diferencia mejor describe un flujo agentic frente a un prompt simple?',
          options: [
            'Puede planificar pasos y usar herramientas',
            'Siempre responde más rápido',
            'No necesita contexto',
            'Solo funciona sin internet',
          ],
          correctAnswer: 'Puede planificar pasos y usar herramientas',
          timeLimitSeconds: 60,
          points: 100,
          questionsRequired: 4,
          questionBank: [
            ChallengeQuestion(
              id: 'ia-prompt',
              question:
                  'Una IA debe clasificar comentarios y solo puede responder POSITIVO o NEGATIVO. ¿Cuál es el mejor prompt?',
              options: [
                'Lee el comentario, analiza su tono con cuidado y responde lo que consideres adecuado.',
                'Clasifica el comentario como POSITIVO o NEGATIVO. Responde solo con esa palabra.',
                'Analiza este comentario y dime cómo te hace sentir en detalle sobre el evento.',
                'Háblame del sentimiento general que el público tiene sobre el evento completo.',
              ],
              correctAnswer:
                  'Clasifica el comentario como POSITIVO o NEGATIVO. Responde solo con esa palabra.',
              hint: 'Un buen prompt especifica la tarea y el formato esperado.',
            ),
            ChallengeQuestion(
              id: 'ia-hallucination',
              question:
                  'La IA no tiene acceso a la agenda del evento. ¿Cuál respuesta es más confiable?',
              options: [
                'La próxima charla comienza exactamente a las 3:17 p.m. en el Salón Principal.',
                'Seguramente comienza después del almuerzo, así que no hay de qué preocuparse.',
                'No tengo la agenda disponible, por eso no puedo confirmar la hora exacta.',
                'Todas las charlas comienzan a la misma hora según el programa oficial.',
              ],
              correctAnswer:
                  'No tengo la agenda disponible, por eso no puedo confirmar la hora exacta.',
              hint:
                  'Una IA confiable reconoce cuando no tiene suficiente información.',
            ),
            ChallengeQuestion(
              id: 'ia-few-shot',
              question:
                  'Antes de hacerle una pregunta a una IA, le muestras dos ejemplos con sus respuestas para enseñarle el formato. ¿Qué técnica usas?',
              options: [
                'Zero-shot prompting',
                'Few-shot prompting',
                'Fine-tuning del modelo',
                'Chain-of-thought',
              ],
              correctAnswer: 'Few-shot prompting',
              hint:
                  'La IA recibe unos pocos ejemplos antes de resolver la tarea.',
            ),
            ChallengeQuestion(
              id: 'ia-context',
              question:
                  'Entregas un texto muy largo y el modelo olvida las primeras instrucciones. ¿Qué límite alcanzaste?',
              options: [
                'Temperatura del modelo',
                'Tasa de aprendizaje',
                'Ventana de contexto',
                'Tamaño del lote de entrenamiento',
              ],
              correctAnswer: 'Ventana de contexto',
              hint:
                  'Es la cantidad máxima de tokens que el modelo puede considerar a la vez.',
            ),
            ChallengeQuestion(
              id: 'ia-rag',
              question:
                  'Quieres que la IA responda con datos actualizados de tu documentación interna sin reentrenarla. ¿Qué enfoque usas?',
              options: [
                'Reentrenar el modelo desde cero',
                'Aumentar la temperatura',
                'Comprimir el modelo',
                'Generación aumentada con recuperación (RAG)',
              ],
              correctAnswer: 'Generación aumentada con recuperación (RAG)',
              hint: 'Busca fragmentos relevantes y los incluye en el prompt.',
            ),
            ChallengeQuestion(
              id: 'ia-temperature',
              question:
                  'Necesitas que el modelo responda igual para la misma entrada, sin variaciones creativas. ¿Qué parámetro bajas?',
              options: [
                'Ventana de contexto',
                'Número de capas',
                'Temperatura',
                'Tamaño del vocabulario',
              ],
              correctAnswer: 'Temperatura',
              hint: 'Controla qué tan aleatorias son las respuestas.',
            ),
            ChallengeQuestion(
              id: 'ia-verify',
              question:
                  '¿Qué práctica reduce más el riesgo de usar una respuesta de IA incorrecta?',
              options: [
                'Confiar en el tono seguro de la respuesta',
                'Verificarla con una fuente confiable antes de usarla',
                'Pedir una respuesta más larga',
                'Subir la temperatura al máximo',
              ],
              correctAnswer:
                  'Verificarla con una fuente confiable antes de usarla',
              hint:
                  'La seguridad con la que suena una respuesta no garantiza que sea correcta.',
            ),
            ChallengeQuestion(
              id: 'ia-role',
              question:
                  'Quieres que la IA responda como experta en seguridad. ¿Qué parte del prompt define ese rol?',
              options: [
                'La longitud de la respuesta',
                'El nombre del archivo guardado',
                'Las instrucciones de rol al inicio del prompt',
                'La cantidad de emojis permitidos',
              ],
              correctAnswer: 'Las instrucciones de rol al inicio del prompt',
              hint:
                  'Se define en las instrucciones, antes de la pregunta del usuario.',
            ),
          ],
        ),
        gymName: 'Prompt Master',
        track: 'ia',
        pointValue: 100,
      ),
      const TreasureItem(
        id: 'gym-security',
        title: 'Gimnasio Security',
        description:
            'The Hidden Exploit: encuentra pistas físicas y descifra el código final.',
        code: 'SECURE2026',
        clue: 'The Hidden Exploit conquistado. El código final fue SECURE2026.',
        locationDescription: 'QRs escondidos en el venue',
        iconKey: 'shield',
        order: 3,
        challengeType: ChallengeType.riddle,
        challenge: GymChallenge(
          type: ChallengeType.riddle,
          question:
              'Escanea los QR físicos: la app colocará cada fragmento y reconstruirá el código final.',
          hint: 'Los fragmentos forman una sola palabra con el año del evento.',
          correctAnswer: 'SECURE2026',
          points: 100,
        ),
        gymName: 'The Hidden Exploit',
        track: 'security',
        pointValue: 100,
      ),
      const TreasureItem(
        id: 'gym-web',
        title: 'Gimnasio Web',
        description:
            'Pixel Perfect: memoriza colores, acierta 5 de 10 y suma puntos extra por precisión.',
        code: 'WEB-MASTER',
        clue:
            'Pixel Perfect conquistado. Una buena UI también se mide por accesibilidad.',
        locationDescription: 'Área Web / UX',
        iconKey: 'globe',
        order: 4,
        challengeType: ChallengeType.miniGame,
        challenge: GymChallenge(
          type: ChallengeType.miniGame,
          question:
              'Memoriza cada color y encuentra el tono idéntico. Necesitas 5 aciertos de 10.',
          correctAnswer: 'PIXEL-PERFECT',
          points: 100,
          targetScore: 100,
        ),
        gymName: 'Pixel Perfect',
        track: 'web',
        pointValue: 100,
      ),
      const TreasureItem(
        id: 'gym-startup',
        title: 'Gimnasio Startup',
        description: 'Runway Rush: sobrevive al caos de una startup.',
        code: 'STARTUP-MASTER',
        clue:
            'Runway Rush conquistado. Llegaste a la meta antes de quedarte sin runway.',
        locationDescription: 'Área emprendimiento / networking',
        iconKey: 'rocket',
        order: 5,
        challengeType: ChallengeType.miniGame,
        challenge: GymChallenge(
          type: ChallengeType.miniGame,
          question:
              'Evita bugs, churn y errores de deploy hasta alcanzar la meta.',
          correctAnswer: 'RUNWAY-CLEARED',
          points: 100,
          targetScore: 100,
        ),
        gymName: 'Runway Rush',
        track: 'startup',
        pointValue: 100,
      ),
      const TreasureItem(
        id: 'gym-cloud',
        title: 'Gimnasio Cloud',
        description: 'Scale the Cloud: responde arquitectura cloud y Firebase.',
        code: 'CLOUD-MASTER',
        clue:
            'Scale the Cloud conquistado. La arquitectura escala mejor cuando es simple.',
        locationDescription: 'Área Cloud / Firebase',
        iconKey: 'cloud',
        order: 6,
        challengeType: ChallengeType.trivia,
        challenge: GymChallenge(
          type: ChallengeType.trivia,
          question:
              '¿Qué servicio de Firebase usarías para guardar datos sincronizados de participantes?',
          options: [
            'Firestore',
            'Crashlytics',
            'Remote Config',
            'Cloud Messaging',
          ],
          correctAnswer: 'Firestore',
          timeLimitSeconds: 60,
          points: 100,
          questionsRequired: 4,
          questionBank: [
            ChallengeQuestion(
              id: 'cloud-persistence',
              question:
                  'El ranking se guarda solamente en la memoria del servidor. El servidor se reinicia y todos los puntos desaparecen. ¿Qué necesita la aplicación?',
              options: [
                'Caché en el navegador',
                'Almacenamiento persistente',
                'Más réplicas de la app',
                'Un balanceador de carga',
              ],
              correctAnswer: 'Almacenamiento persistente',
              hint:
                  'Los datos importantes deben sobrevivir después de apagar el servidor.',
            ),
            ChallengeQuestion(
              id: 'cloud-capacity',
              question:
                  'Un servidor atiende 500 participantes. Llegan 2,100 al mismo tiempo. ¿Cuántos servidores iguales hacen falta como mínimo?',
              options: ['3', '4', '5', '6'],
              correctAnswer: '5',
              hint:
                  'Divide y redondea hacia arriba: no puedes usar medio servidor.',
            ),
            ChallengeQuestion(
              id: 'cloud-load-balancer',
              question:
                  'Recibo una petición y decido a cuál de varios servidores enviarla para que ninguno cargue con todo. ¿Qué soy?',
              options: [
                'Base de datos',
                'Balanceador de carga',
                'Editor de código',
                'Sistema operativo',
              ],
              correctAnswer: 'Balanceador de carga',
              hint: 'Su trabajo es distribuir el tráfico.',
            ),
            ChallengeQuestion(
              id: 'cloud-storage',
              question:
                  'Los usuarios suben fotos del evento. ¿Qué tipo de servicio conviene para guardarlas?',
              options: [
                'Servicio de autenticación',
                'Sistema de notificaciones',
                'Cola de mensajes',
                'Almacenamiento de objetos',
              ],
              correctAnswer: 'Almacenamiento de objetos',
              hint:
                  'Está diseñado para guardar imágenes, videos y otros archivos.',
            ),
          ],
        ),
        gymName: 'Scale the Cloud',
        track: 'cloud',
        pointValue: 100,
      ),
      const TreasureItem(
        id: 'gym-speaker',
        title: 'Gimnasio Speaker',
        description:
            'Hall of Voices: descubre quién está detrás de cada charla usando pistas de la agenda.',
        code: 'SPEAKER-MASTER',
        clue:
            'Hall of Voices conquistado. Ya reconoces algunas de las voces del DevFest.',
        locationDescription: 'Agenda de los dos días',
        iconKey: 'mic',
        order: 7,
        challengeType: ChallengeType.riddle,
        challenge: GymChallenge(
          type: ChallengeType.riddle,
          question: 'Adivina quién es el speaker y escribe su nombre.',
          points: 100,
          questionsRequired: 2,
          questionBank: [
            ChallengeQuestion(
              id: 'speaker-lowell-abbott',
              question:
                  '¿Quién soy?\n\n• Mi sistema debe seguir vivo más allá de una sola región.\n• Trabajo con bloques, confianza distribuida y operaciones.\n• Mi verdadero enemigo no es solo una caída: también es una factura fuera de control.',
              options: [],
              correctAnswer: 'Lowell Abbott',
              hint:
                  'Su sesión une infraestructura global, blockchain y presupuesto.',
            ),
            ChallengeQuestion(
              id: 'speaker-wagner-luciano',
              question:
                  '¿Quién soy?\n\n• En mi propuesta, una pantalla puede sobrar.\n• Delego tareas a colaboradores que razonan y actúan.\n• Mi escenario no es experimental: pienso en procesos de empresa.',
              options: [],
              correctAnswer: 'Wagner Luciano',
              hint:
                  'Habla de automatización empresarial impulsada por agentes.',
            ),
            ChallengeQuestion(
              id: 'speaker-carlos-alarcon',
              question:
                  '¿Quién soy?\n\n• Defiendo que el poder de un modelo también puede venir con transparencia.\n• Me interesa que desarrolladores y organizaciones puedan adaptarlo y desplegarlo con mayor control.\n• Mi revolución no ocurre detrás de una puerta cerrada.',
              options: [],
              correctAnswer: 'Carlos Alarcón',
              hint:
                  'Su taller explora una nueva generación de Gemma y la IA de código abierto.',
            ),
            ChallengeQuestion(
              id: 'speaker-jose-aquino-cepeda',
              question:
                  '¿Quién soy?\n\n• Conozco proyectos brillantes que nunca salieron de beta por un error que no estaba en el código.\n• Para mí, una conversación y una imagen profesional también forman parte del stack.\n• Quiero llevar a los fundadores desde el IDE hasta una empresa formal.',
              options: [],
              correctAnswer: 'José Aquino Cepeda',
              hint:
                  'Su sesión traduce ventas, networking y formalización al lenguaje de un fundador técnico.',
            ),
            ChallengeQuestion(
              id: 'speaker-victor-leonardo',
              question:
                  '¿Quién soy?\n\n• Las herramientas cambian, pero mi brújula permanece.\n• Sé que revisar todo es imposible, así que priorizo según riesgo y contexto.\n• No considero que “pasó las pruebas” sea sinónimo de calidad.',
              options: [],
              correctAnswer: 'Victor Leonardo',
              hint: 'Su charla vuelve a los principios que guían el testing.',
            ),
            ChallengeQuestion(
              id: 'speaker-maria-shrayber',
              question:
                  '¿Quién soy?\n\n• Descubrí que el activo más valioso de una carrera no vive en documentos ni hojas de cálculo.\n• Una vez, un formulario convirtió un detalle pequeño en una pérdida enorme.\n• Ahora convierto años de criterio profesional en sistemas repetibles.',
              options: [],
              correctAnswer: 'Maria Shrayber',
              hint:
                  'Su historia conecta experiencia comercial, licitaciones e inteligencia artificial.',
            ),
            ChallengeQuestion(
              id: 'speaker-julio-quinteros',
              question:
                  '¿Quién soy?\n\n• Para comparar dos formas de coordinar agentes, elegí un problema donde las respuestas no admiten opiniones.\n• Me preocupan las transferencias que gastan tiempo y tokens sin resolver nada.\n• Entre flexibilidad y secuencia, busco una decisión medible.',
              options: [],
              correctAnswer: 'Julio Quinteros P.',
              hint:
                  'Compara ruteo multiagente y loops usando un evaluador matemático.',
            ),
            ChallengeQuestion(
              id: 'speaker-aneudy-vargas',
              question:
                  '¿Quién soy?\n\n• No creo que compartir código signifique compartirlo todo.\n• Dejo el trabajo pesado en un lenguaje y la experiencia visual nativa en otro.\n• Un puente convierte flujos y corrutinas en algo natural al cruzar de plataforma.',
              options: [],
              correctAnswer: 'Aneudy Vargas Almanzar',
              hint:
                  'Su arquitectura conecta Kotlin Multiplatform, Swift y SKIE.',
            ),
            ChallengeQuestion(
              id: 'speaker-ayesha-yege',
              question:
                  '¿Quién soy?\n\n• Intento anticipar resultados mientras todavía están ocurriendo.\n• Una pieza de IA funciona como fuente de verdad para el sistema.\n• Cada cambio debe viajar automáticamente hasta Google Cloud.',
              options: [],
              correctAnswer: 'Ayesha Yege',
              hint: 'Su arquitectura combina predicciones, un oráculo y CI/CD.',
            ),
            ChallengeQuestion(
              id: 'speaker-alberto-castillo',
              question:
                  '¿Quién soy?\n\n• Para mí, la disponibilidad puede tener consecuencias humanas.\n• No construyo solo para el día perfecto, sino para responder durante una crisis.\n• Mi historia conecta código, resiliencia y comunidad.',
              options: [],
              correctAnswer: 'Alberto Castillo',
              hint: 'Su charla gira alrededor de Google Crisis Resilience.',
            ),
            ChallengeQuestion(
              id: 'speaker-victor-recio',
              question:
                  '¿Quién soy?\n\n• En mi mesa conviven una ballena y un gopher.\n• Los organizo para que varios agentes trabajen con una arquitectura clara.\n• El kit que uso viene del ecosistema de Google.',
              options: [],
              correctAnswer: 'Victor S. Recio',
              hint: 'La ballena representa Docker y el gopher representa Go.',
            ),
            ChallengeQuestion(
              id: 'speaker-hector-terrero',
              question:
                  '¿Quién soy?\n\n• Explico una tecnología moderna usando tres imágenes del campo.\n• Una representa la fuerza, otra el control y otra el combustible.\n• Mi interés está en cómo los agentes sobreviven fuera de una demo.',
              options: [],
              correctAnswer: 'Hector Terrero',
              hint: 'Su metáfora incluye un caballo, un arnés y heno.',
            ),
            ChallengeQuestion(
              id: 'speaker-karla-aquino',
              question:
                  '¿Quién soy?\n\n• Antes de proteger, invito a encontrar por dónde se rompe.\n• Mi recorrido tiene tres movimientos: atacar, reparar y asegurar.\n• La aplicación es al mismo tiempo laboratorio y objetivo.',
              options: [],
              correctAnswer: 'Karla Aquino',
              hint:
                  'Su sesión convierte una app en un ejercicio práctico de seguridad.',
            ),
            ChallengeQuestion(
              id: 'speaker-harys-vizcaino',
              question:
                  '¿Quién soy?\n\n• Prefiero que la inteligencia artificial viva cerca de mí.\n• Mi laboratorio puede estar en casa.\n• Persigo la sensación de poder usar tokens sin mirar constantemente el contador.',
              options: [],
              correctAnswer: 'Harys Vizcaino',
              hint: 'Combina IA local con home labs.',
            ),
            ChallengeQuestion(
              id: 'speaker-edgardo-panchana',
              question:
                  '¿Quién soy?\n\n• Llevo el modelo al dispositivo en lugar de depender siempre de la nube.\n• Construyo una interfaz reactiva dentro del ecosistema Android.\n• Una tecnología de Google pequeña y una UI declarativa son mis herramientas.',
              options: [],
              correctAnswer: 'Edgardo Panchana',
              hint: 'Las herramientas son Gemini Nano y Jetpack Compose.',
            ),
            ChallengeQuestion(
              id: 'speaker-angel-jose',
              question:
                  '¿Quién soy?\n\n• Mi problema comienza cuando un modelo obedece más de lo debido.\n• No basta con que el agente sea útil; también debe conocer sus límites.\n• Diseño barreras para que sus acciones no excedan su permiso.',
              options: [],
              correctAnswer: 'Angel Jose',
              hint: 'Su tema central es construir agentes de IA seguros.',
            ),
          ],
        ),
        gymName: 'Hall of Voices',
        track: 'speaker',
        pointValue: 100,
      ),
      const TreasureItem(
        id: 'gym-community',
        title: 'Gimnasio Comunidad',
        description:
            'Community Signal: únete a GDG Santo Domingo, obtén tu entrada y valida con el staff.',
        code: 'COMMUNITY-SIGNAL',
        clue:
            'Community Signal conquistado. La comunidad también se construye compartiendo.',
        locationDescription: 'Booth de comunidad',
        iconKey: 'people',
        order: 8,
        challengeType: ChallengeType.social,
        challenge: GymChallenge(
          type: ChallengeType.social,
          question:
              'Únete a GDG Santo Domingo, obtén tu entrada al DevFest y escanea el QR privado del staff.',
          hint:
              'Muestra al staff las dos confirmaciones para acceder al QR de validación.',
          correctAnswer: 'COMMUNITY-SIGNAL',
          points: 100,
        ),
        gymName: 'Community Signal',
        track: 'community',
        pointValue: 100,
      ),
    ];
  }

  /// 15 seeded participants with varied progress.
  static List<Participant> buildSeedParticipants() {
    final now = DateTime.now();
    // Completed participants — all 8 gyms.
    final carlos = _p(
      now,
      'participant-101',
      'Carlos',
      'carlos_dev',
      18,
      32,
      discovered: [
        'gym-android',
        'gym-ia',
        'gym-cloud',
        'gym-security',
        'gym-web',
        'gym-startup',
        'gym-speaker',
        'gym-community',
      ],
      completedAfter: Duration(minutes: 18, seconds: 32),
      points: 900,
      medals: 8,
      avatarEmoji: '😎',
    );
    final ana = _p(
      now,
      'participant-102',
      'Ana',
      'ana_builds',
      21,
      4,
      discovered: [
        'gym-android',
        'gym-ia',
        'gym-cloud',
        'gym-security',
        'gym-web',
        'gym-startup',
        'gym-speaker',
        'gym-community',
      ],
      completedAfter: Duration(minutes: 21, seconds: 4),
      points: 900,
      medals: 8,
      avatarEmoji: '🦊',
    );
    final marco = _p(
      now,
      'participant-103',
      'Marco',
      'marco_pixel',
      25,
      47,
      discovered: [
        'gym-android',
        'gym-ia',
        'gym-cloud',
        'gym-security',
        'gym-web',
        'gym-startup',
        'gym-speaker',
        'gym-community',
      ],
      completedAfter: Duration(minutes: 25, seconds: 47),
      points: 900,
      medals: 8,
      avatarEmoji: '🐉',
    );
    // In progress participants.
    final laura = _p(
      now,
      'participant-104',
      'Laura',
      'laura_ui',
      12,
      40,
      discovered: [
        'gym-security',
        'gym-android',
        'gym-speaker',
        'gym-ia',
        'gym-web',
        'gym-startup',
      ],
      points: 645,
      medals: 6,
      avatarEmoji: '🎨',
    );
    final pedro = _p(
      now,
      'participant-105',
      'Pedro',
      'pedro_flutter',
      9,
      15,
      discovered: [
        'gym-ia',
        'gym-startup',
        'gym-security',
        'gym-community',
        'gym-web',
      ],
      points: 515,
      medals: 5,
      avatarEmoji: '🦋',
    );
    final sofia = _p(
      now,
      'participant-106',
      'Sofía',
      'sofia_data',
      15,
      8,
      discovered: [
        'gym-android',
        'gym-web',
        'gym-startup',
        'gym-ia',
        'gym-cloud',
        'gym-security',
        'gym-community',
      ],
      points: 730,
      medals: 7,
      avatarEmoji: '🦊',
    );
    final diego = _p(
      now,
      'participant-107',
      'Diego',
      'diego_ops',
      7,
      55,
      discovered: ['gym-speaker', 'gym-cloud', 'gym-android'],
      points: 315,
      medals: 3,
      avatarEmoji: '🔧',
    );
    final valeria = _p(
      now,
      'participant-108',
      'Valeria',
      'vale_creative',
      6,
      20,
      discovered: ['gym-ia', 'gym-startup'],
      points: 215,
      medals: 2,
      avatarEmoji: '✨',
    );
    final miguel = _p(
      now,
      'participant-109',
      'Miguel',
      'mig_code',
      5,
      48,
      discovered: ['gym-android'],
      points: 130,
      medals: 1,
      avatarEmoji: '💡',
    );
    final pamela = _p(
      now,
      'participant-110',
      'Pamela',
      'pamela_k',
      4,
      33,
      discovered: ['gym-web', 'gym-startup'],
      points: 205,
      medals: 2,
      avatarEmoji: '🌟',
    );
    final isaac = _p(now, 'participant-111', 'Isaac', 'isaac_ml', 3, 12);
    final gaby = _p(now, 'participant-112', 'Gaby', 'gaby_design', 2, 40);
    final roberto = _p(
      now,
      'participant-113',
      'Roberto',
      'rob_ios',
      8,
      2,
      discovered: [
        'gym-security',
        'gym-android',
        'gym-startup',
        'gym-community',
        'gym-ia',
        'gym-speaker',
        'gym-web',
        'gym-cloud',
      ],
      points: 900,
      medals: 8,
      avatarEmoji: '🚀',
    );
    final camila = _p(now, 'participant-114', 'Camila', 'cami_test', 1, 25);
    final raul = _p(
      now,
      'participant-115',
      'Raúl',
      'raul_web',
      10,
      5,
      discovered: [
        'gym-android',
        'gym-security',
        'gym-community',
        'gym-ia',
        'gym-startup',
        'gym-web',
        'gym-cloud',
      ],
      points: 730,
      medals: 7,
      avatarEmoji: '🎧',
    );
    return [
      carlos,
      ana,
      marco,
      laura,
      pedro,
      sofia,
      roberto,
      raul,
      diego,
      valeria,
      pamela,
      miguel,
      isaac,
      gaby,
      camila,
    ];
  }

  static Participant _p(
    DateTime now,
    String id,
    String name,
    String nickname,
    int minutesAgo,
    int offsetSeconds, {
    List<String> discovered = const [],
    Duration? completedAfter,
    int points = 0,
    int medals = 0,
    String? avatarEmoji,
  }) {
    final startedAt = now.subtract(
      Duration(minutes: minutesAgo, seconds: offsetSeconds),
    );
    return Participant(
      id: id,
      name: name,
      nickname: nickname,
      startedAt: startedAt,
      completedAt: completedAfter != null
          ? startedAt.add(completedAfter)
          : null,
      status: completedAfter != null
          ? ParticipantStatus.completed
          : ParticipantStatus.active,
      discoveredTreasureIds: discovered,
      points: points,
      medals: medals,
      avatarEmoji: avatarEmoji,
    );
  }
}
