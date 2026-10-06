import '../../domain/entities/event.dart';
import '../../domain/entities/gym_challenge.dart';
import '../../domain/entities/participant.dart';
import '../../domain/entities/treasure_item.dart';

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
        qrValue: 'DEVFEST-GYM-ANDROID',
        clue:
            'Debug Droid conquistado. El siguiente lider espera en otro track.',
        locationDescription: 'Stand Android / KMP',
        iconKey: 'android',
        order: 1,
        challengeType: ChallengeType.code,
        challenge: GymChallenge(
          type: ChallengeType.code,
          question:
              'Que archivo declara permisos como CAMERA o INTERNET en Android?',
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
        ),
        gymName: 'Debug Droid',
        track: 'android',
        pointValue: 100,
      ),
      const TreasureItem(
        id: 'gym-ia',
        title: 'Gimnasio IA',
        description:
            'Prompt Master: responde preguntas de la charla de Carmelo.',
        code: 'IA-MASTER',
        qrValue: 'DEVFEST-GYM-IA',
        clue:
            'Prompt Master conquistado. La IA premia a quien escucha con atencion.',
        locationDescription: 'Sala principal / charla IA',
        iconKey: 'brain',
        order: 2,
        challengeType: ChallengeType.trivia,
        challenge: GymChallenge(
          type: ChallengeType.trivia,
          question:
              'Segun la charla, que diferencia mejor describe un flujo agentic frente a un prompt simple?',
          options: [
            'Puede planificar pasos y usar herramientas',
            'Siempre responde mas rapido',
            'No necesita contexto',
            'Solo funciona sin internet',
          ],
          correctAnswer: 'Puede planificar pasos y usar herramientas',
          timeLimitSeconds: 60,
          points: 100,
        ),
        gymName: 'Prompt Master',
        track: 'ia',
        pointValue: 100,
      ),
      const TreasureItem(
        id: 'gym-security',
        title: 'Gimnasio Security',
        description:
            'The Hidden Exploit: encuentra pistas fisicas y descifra el codigo final.',
        code: 'SECURE2026',
        qrValue: 'DEVFEST-GYM-SECURITY',
        clue: 'The Hidden Exploit conquistado. El codigo final fue SECURE2026.',
        locationDescription: 'QRs escondidos en el venue',
        iconKey: 'shield',
        order: 3,
        challengeType: ChallengeType.riddle,
        challenge: GymChallenge(
          type: ChallengeType.riddle,
          question:
              'Une los fragmentos encontrados en los QR fisicos e introduce el codigo final.',
          hint: 'Los fragmentos forman una sola palabra con el ano del evento.',
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
            'Pixel Perfect: resuelve un reto visual de UI y accesibilidad.',
        code: 'WEB-MASTER',
        qrValue: 'DEVFEST-GYM-WEB',
        clue:
            'Pixel Perfect conquistado. Una buena UI tambien se mide por accesibilidad.',
        locationDescription: 'Area Web / UX',
        iconKey: 'globe',
        order: 4,
        challengeType: ChallengeType.trivia,
        challenge: GymChallenge(
          type: ChallengeType.trivia,
          question:
              'Que opcion es mas semantica para una navegacion principal en HTML?',
          options: ['<nav>', '<div>', '<span>', '<section>'],
          correctAnswer: '<nav>',
          timeLimitSeconds: 60,
          points: 100,
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
        qrValue: 'DEVFEST-GYM-STARTUP',
        clue:
            'Runway Rush conquistado. Llegaste al millon narrativo antes de quedarte sin runway.',
        locationDescription: 'Area emprendimiento / networking',
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
        qrValue: 'DEVFEST-GYM-CLOUD',
        clue:
            'Scale the Cloud conquistado. La arquitectura escala mejor cuando es simple.',
        locationDescription: 'Area Cloud / Firebase',
        iconKey: 'cloud',
        order: 6,
        challengeType: ChallengeType.trivia,
        challenge: GymChallenge(
          type: ChallengeType.trivia,
          question:
              'Que servicio de Firebase usarias para guardar datos sincronizados de participantes?',
          options: [
            'Firestore',
            'Crashlytics',
            'Remote Config',
            'Cloud Messaging',
          ],
          correctAnswer: 'Firestore',
          timeLimitSeconds: 60,
          points: 100,
        ),
        gymName: 'Scale the Cloud',
        track: 'cloud',
        pointValue: 100,
      ),
      const TreasureItem(
        id: 'gym-speaker',
        title: 'Gimnasio Speaker',
        description:
            'Hall of Voices: demuestra que estuviste atento a las charlas.',
        code: 'SPEAKER-MASTER',
        qrValue: 'DEVFEST-GYM-SPEAKER',
        clue:
            'Hall of Voices conquistado. Las mejores pistas salieron del escenario.',
        locationDescription: 'Sala principal',
        iconKey: 'mic',
        order: 7,
        challengeType: ChallengeType.trivia,
        challenge: GymChallenge(
          type: ChallengeType.trivia,
          question:
              'Que debes hacer para responder mejor las preguntas del Gimnasio Speaker?',
          options: [
            'Escuchar las charlas',
            'Adivinar rapido',
            'Buscar el QR mas cercano',
            'Cerrar la app',
          ],
          correctAnswer: 'Escuchar las charlas',
          timeLimitSeconds: 60,
          points: 100,
        ),
        gymName: 'Hall of Voices',
        track: 'speaker',
        pointValue: 100,
      ),
      const TreasureItem(
        id: 'gym-community',
        title: 'Gimnasio Comunidad',
        description:
            'Community Signal: completa el reto social y canjea el codigo recibido por DM.',
        code: 'COMMUNITY-SIGNAL',
        qrValue: 'DEVFEST-GYM-COMMUNITY',
        clue:
            'Community Signal conquistado. La comunidad tambien se construye compartiendo.',
        locationDescription: 'Instagram / area comunidad',
        iconKey: 'people',
        order: 8,
        challengeType: ChallengeType.social,
        challenge: GymChallenge(
          type: ChallengeType.social,
          question:
              'Sube una selfie o story del evento, etiqueta a GDG Santo Domingo y envia evidencia por DM. Escribe aqui el codigo que recibas.',
          hint:
              'Si Instagram falla, staff puede validar presencialmente y darte el codigo.',
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
