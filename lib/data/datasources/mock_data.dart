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
      TreasureItem(
        id: 'gym-android',
        title: 'Gimnasio Android',
        description: 'Demuestra que dominas Android, Kotlin y Jetpack Compose.',
        code: 'ANDROID-MASTER',
        qrValue: 'DEVFEST-GYM-ANDROID',
        clue: 'Busca el QR junto al stand de Android.',
        locationDescription: 'Stand de Android / KMP',
        iconKey: 'android',
        order: 1,
        isActive: true,
        challengeType: ChallengeType.code,
        challenge: GymChallenge(
          type: ChallengeType.code,
          question:
              '¿Qué herramienta de KMP convierte Flow y coroutines en algo idiomático para Swift?',
          options: ['SKIE', 'KotlinNatives', 'SwiftBridge', 'CoroutinesKit'],
          correctAnswer: 'SKIE',
          hint: 'Escuche la charla de KMP para saber la respuesta.',
          codeSnippet: 'fun fetchData(): Flow<Data> = flow { ... }',
          points: 15,
        ),
        gymName: 'Gimnasio Android',
        track: 'android',
        pointValue: 15,
      ),
      TreasureItem(
        id: 'gym-ia',
        title: 'Gimnasio IA & Agentes',
        description: 'Demuestra tu conocimiento de Gemini, ADK y agentes de IA.',
        code: 'IA-AGENT-MASTER',
        qrValue: 'DEVFEST-GYM-IA',
        clue: 'El QR está cerca de la pantalla principal.',
        locationDescription: 'Área de charlas de IA',
        iconKey: 'brain',
        order: 2,
        isActive: true,
        challengeType: ChallengeType.trivia,
        challenge: GymChallenge(
          type: ChallengeType.trivia,
          question:
              '¿Cuál es la diferencia clave entre un LoopAgent y el ruteo dinámico en ADK?',
          options: [
            'LoopAgent ejecuta pasos fijos, ruteo dinámico elige el agente según el contexto',
            'No hay diferencia, son sinónimos',
            'LoopAgent es para producción, ruteo dinámico para testing',
            'Ruteo dinámico solo funciona con Gemini Flash',
          ],
          correctAnswer:
              'LoopAgent ejecuta pasos fijos, ruteo dinámico elige el agente según el contexto',
          timeLimitSeconds: 60,
          points: 20,
        ),
        gymName: 'Gimnasio IA & Agentes',
        track: 'ia',
        pointValue: 20,
      ),
      TreasureItem(
        id: 'gym-cloud',
        title: 'Gimnasio Cloud',
        description:
            'Demuestra que dominas GCP, Firebase y arquitectura cloud.',
        code: 'CLOUD-MASTER',
        qrValue: 'DEVFEST-GYM-CLOUD',
        clue: 'Busca el QR en el área de networking.',
        locationDescription: 'Área de Cloud / Firebase',
        iconKey: 'cloud',
        order: 3,
        isActive: true,
        challengeType: ChallengeType.trivia,
        challenge: GymChallenge(
          type: ChallengeType.trivia,
          question:
              '¿Qué protocolo usa Firebase Realtime Database para sincronización en tiempo real?',
          options: ['WebSocket', 'HTTP/2', 'gRPC', 'MQTT'],
          correctAnswer: 'WebSocket',
          timeLimitSeconds: 60,
          points: 15,
        ),
        gymName: 'Gimnasio Cloud',
        track: 'cloud',
        pointValue: 15,
      ),
      TreasureItem(
        id: 'gym-security',
        title: 'Gimnasio Seguridad',
        description:
            'Resuelve acertijos de seguridad y demuestra conocimiento de DevSecOps.',
        code: 'SECURITY-MASTER',
        qrValue: 'DEVFEST-GYM-SECURITY',
        clue: 'El QR está escondido, como buen acertijo de seguridad.',
        locationDescription: 'Área de seguridad / DevSecOps',
        iconKey: 'shield',
        order: 4,
        isActive: true,
        challengeType: ChallengeType.riddle,
        challenge: GymChallenge(
          type: ChallengeType.riddle,
          question:
              'Soy el ataque que engaña al agente de IA para que revele información confidencial. ¿Qué soy?',
          hint:
              'Piensa en cómo un atacante podría manipular las instrucciones de un sistema de IA.',
          correctAnswer: 'indirect prompt injection',
          points: 20,
        ),
        gymName: 'Gimnasio Seguridad',
        track: 'security',
        pointValue: 20,
      ),
      TreasureItem(
        id: 'gym-web',
        title: 'Gimnasio Web & UX',
        description:
            'Demuestra tu conocimiento de UI generativa y UX post-IA.',
        code: 'WEB-UX-MASTER',
        qrValue: 'DEVFEST-GYM-WEB',
        clue: 'El QR está en la zona de exhibición.',
        locationDescription: 'Área de Web / UI',
        iconKey: 'globe',
        order: 5,
        isActive: true,
        challengeType: ChallengeType.trivia,
        challenge: GymChallenge(
          type: ChallengeType.trivia,
          question:
              '¿Qué es Gemma 4 y por qué importa para el open-source?',
          options: [
            'Un modelo de lenguaje open-source de Google',
            'Un framework de UI para Flutter',
            'Una base de datos relacional',
            'Un sistema operativo móvil',
          ],
          correctAnswer: 'Un modelo de lenguaje open-source de Google',
          timeLimitSeconds: 60,
          points: 15,
        ),
        gymName: 'Gimnasio Web & UX',
        track: 'web',
        pointValue: 15,
      ),
      TreasureItem(
        id: 'gym-startup',
        title: 'Gimnasio Emprendimiento',
        description:
            'Preguntas sobre startups, SaaS y ser full-stack founder.',
        code: 'STARTUP-MASTER',
        qrValue: 'DEVFEST-GYM-STARTUP',
        clue: 'Busca el QR cerca del área de networking.',
        locationDescription: 'Área de emprendimiento',
        iconKey: 'rocket',
        order: 6,
        isActive: true,
        challengeType: ChallengeType.trivia,
        challenge: GymChallenge(
          type: ChallengeType.trivia,
          question:
              '¿Cuál es el primer paso para validar una idea de startup según lean methodology?',
          options: [
            'Crear un MVP y medir traction',
            'Escribir un business plan de 50 páginas',
            'Buscar inversores angel',
            'Registrar la empresa legalmente',
          ],
          correctAnswer: 'Crear un MVP y medir traction',
          timeLimitSeconds: 60,
          points: 10,
        ),
        gymName: 'Gimnasio Emprendimiento',
        track: 'startup',
        pointValue: 10,
      ),
      TreasureItem(
        id: 'gym-speaker',
        title: 'Gimnasio Speaker',
        description:
            'Preguntas sobre las charlas reales del evento. ¡Tiene que escuchar!',
        code: 'SPEAKER-MASTER',
        qrValue: 'DEVFEST-GYM-SPEAKER',
        clue: 'El QR aparece durante las charlas principales.',
        locationDescription: 'Sala principal de charlas',
        iconKey: 'mic',
        order: 7,
        isActive: true,
        challengeType: ChallengeType.trivia,
        challenge: GymChallenge(
          type: ChallengeType.trivia,
          question:
              'Según la charla de hoy, ¿cuántos usuarios soporta la infraestructura de blockchain presentada?',
          options: ['10,000', '100,000', '1,000,000', '10,000,000'],
          correctAnswer: '100,000',
          hint: 'Escuche la charla de Cloud para la respuesta exacta.',
          timeLimitSeconds: 60,
          points: 15,
        ),
        gymName: 'Gimnasio Speaker',
        track: 'speaker',
        pointValue: 15,
      ),
      TreasureItem(
        id: 'gym-community',
        title: 'Gimnasio Comunidad',
        description:
            'Escanea el QR y demuestra que conoces la comunidad GDG.',
        code: 'COMMUNITY-MASTER',
        qrValue: 'DEVFEST-GYM-COMMUNITY',
        clue: 'El QR está en el tablón de la comunidad.',
        locationDescription: 'Área de comunidad / networking',
        iconKey: 'people',
        order: 8,
        isActive: true,
        challengeType: ChallengeType.qr,
        gymName: 'Gimnasio Comunidad',
        track: 'community',
        pointValue: 10,
      ),
    ];
  }

  /// 15 seeded participants with varied progress.
  static List<Participant> buildSeedParticipants() {
    final now = DateTime.now();
    // Completed participants — all 8 gyms.
    final carlos = _p(now, 'participant-101', 'Carlos', 'carlos_dev', 18, 32,
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
        points: 120,
        medals: 8,
        avatarEmoji: '😎');
    final ana = _p(now, 'participant-102', 'Ana', 'ana_builds', 21, 4,
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
        points: 120,
        medals: 8,
        avatarEmoji: '🦊');
    final marco = _p(now, 'participant-103', 'Marco', 'marco_pixel', 25, 47,
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
        points: 120,
        medals: 8,
        avatarEmoji: '🐉');
    // In progress participants.
    final laura = _p(now, 'participant-104', 'Laura', 'laura_ui', 12, 40,
        discovered: [
          'gym-security',
          'gym-android',
          'gym-speaker',
          'gym-ia',
          'gym-web',
          'gym-startup',
        ],
        points: 95,
        medals: 6,
        avatarEmoji: '🎨');
    final pedro = _p(now, 'participant-105', 'Pedro', 'pedro_flutter', 9, 15,
        discovered: [
          'gym-ia',
          'gym-startup',
          'gym-security',
          'gym-community',
          'gym-web',
        ],
        points: 80,
        medals: 5,
        avatarEmoji: '🦋');
    final sofia = _p(now, 'participant-106', 'Sofía', 'sofia_data', 15, 8,
        discovered: [
          'gym-android',
          'gym-web',
          'gym-startup',
          'gym-ia',
          'gym-cloud',
          'gym-security',
          'gym-community',
        ],
        points: 95,
        medals: 7,
        avatarEmoji: '🦊');
    final diego = _p(now, 'participant-107', 'Diego', 'diego_ops', 7, 55,
        discovered: [
          'gym-speaker',
          'gym-cloud',
          'gym-android',
        ],
        points: 50,
        medals: 3,
        avatarEmoji: '🔧');
    final valeria = _p(now, 'participant-108', 'Valeria', 'vale_creative', 6,
        20,
        discovered: [
          'gym-ia',
          'gym-startup',
        ],
        points: 30,
        medals: 2,
        avatarEmoji: '✨');
    final miguel = _p(now, 'participant-109', 'Miguel', 'mig_code', 5, 48,
        discovered: [
          'gym-android',
        ],
        points: 15,
        medals: 1,
        avatarEmoji: '💡');
    final pamela = _p(now, 'participant-110', 'Pamela', 'pamela_k', 4, 33,
        discovered: [
          'gym-web',
          'gym-startup',
        ],
        points: 25,
        medals: 2,
        avatarEmoji: '🌟');
    final isaac = _p(now, 'participant-111', 'Isaac', 'isaac_ml', 3, 12);
    final gaby = _p(now, 'participant-112', 'Gaby', 'gaby_design', 2, 40);
    final roberto = _p(now, 'participant-113', 'Roberto', 'rob_ios', 8, 2,
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
        points: 95,
        medals: 8,
        avatarEmoji: '🚀');
    final camila = _p(now, 'participant-114', 'Camila', 'cami_test', 1, 25);
    final raul = _p(now, 'participant-115', 'Raúl', 'raul_web', 10, 5,
        discovered: [
          'gym-android',
          'gym-security',
          'gym-community',
          'gym-ia',
          'gym-startup',
          'gym-web',
          'gym-cloud',
        ],
        points: 95,
        medals: 7,
        avatarEmoji: '🎧');
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
    final startedAt =
        now.subtract(Duration(minutes: minutesAgo, seconds: offsetSeconds));
    return Participant(
      id: id,
      name: name,
      nickname: nickname,
      startedAt: startedAt,
      completedAt:
          completedAfter != null ? startedAt.add(completedAfter) : null,
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