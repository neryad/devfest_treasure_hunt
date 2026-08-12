import '../../domain/entities/event.dart';
import '../../domain/entities/participant.dart';
import '../../domain/entities/treasure_item.dart';

/// Static seed data for the demo. Nothing here depends on storage or platform.
class MockData {
  static Event buildEvent() => const Event(
        id: 'devfest-2026',
        name: 'DevFest 2026',
        description: 'Encuentra todos los tesoros escondidos durante DevFest.',
        dateLabel: '15 · 16 de mayo — Expo Center',
      );

  static List<String> treasureIds() =>
      buildTreasures().map((t) => t.id).toList();

  static List<TreasureItem> buildTreasures() => const [
        TreasureItem(
          id: 'treasure-001',
          title: 'Tesoro #01 · El Punto de Encuentro',
          description: 'El primer tesoro espera donde empieza tu aventura.',
          code: 'DEVFEST-001',
          qrValue: 'DEVFEST-TREASURE-001',
          clue: 'Tus próximas pistas brillan donde más se aplaude: el escenario principal.',
          locationDescription: 'Registro / zona de bienvenida',
          iconKey: 'badge',
          order: 1,
          isActive: true,
        ),
        TreasureItem(
          id: 'treasure-002',
          title: 'Tesoro #02 · El Escenario Principal',
          description: 'Donde las ideas toman forma y la comunidad aplaude.',
          code: 'DEVFEST-002',
          qrValue: 'DEVFEST-TREASURE-002',
          clue: 'Sigue el aroma del código aliñado con café y snacks.',
          locationDescription: 'Main Stage',
          iconKey: 'mic',
          order: 2,
          isActive: true,
        ),
        TreasureItem(
          id: 'treasure-003',
          title: 'Tesoro #03 · El Rincón del Café',
          description: 'El combustible oficial de toda conferencia tecnológica.',
          code: 'DEVFEST-003',
          qrValue: 'DEVFEST-TREASURE-003',
          clue: 'Las mentes más brillantes se conectan donde hay manos que chocan: el área de networking.',
          locationDescription: 'Área de comida y café',
          iconKey: 'coffee',
          order: 3,
          isActive: false,
        ),
        TreasureItem(
          id: 'treasure-004',
          title: 'Tesoro #04 · El Coliseo de los Stands',
          description: 'Tus patrocinadores favoritos esconden secretos entre sus stands.',
          code: 'DEVFEST-004',
          qrValue: 'DEVFEST-TREASURE-004',
          clue: 'Las ideas crecen donde los teclados nunca descansan: el área de hackathon.',
          locationDescription: 'Zona de expositores',
          iconKey: 'rocket',
          order: 4,
          isActive: true,
        ),
        TreasureItem(
          id: 'treasure-005',
          title: 'Tesoro #05 · El Laboratorio de Código',
          description: 'Donde las mentes construyen durante horas sin mirar el reloj.',
          code: 'DEVFEST-005',
          qrValue: 'DEVFEST-TREASURE-005',
          clue: 'Cada charla guarda una pista; recorre las salas con auriculares puestos.',
          locationDescription: 'Hackathon / sala de labs',
          iconKey: 'code',
          order: 5,
          isActive: true,
        ),
        TreasureItem(
          id: 'treasure-006',
          title: 'Tesoro #06 · Las Salas de Charlas',
          description: 'Las ponencias guardan fragmentos del tesoro mayor.',
          code: 'DEVFEST-006',
          qrValue: 'DEVFEST-TREASURE-006',
          clue: 'Las comunidades cercanas intercambian conocimiento… y tesoros.',
          locationDescription: 'Salas de conferencias',
          iconKey: 'cpu',
          order: 6,
          isActive: true,
        ),
        TreasureItem(
          id: 'treasure-007',
          title: 'Tesoro #07 · El Rincón de la Comunidad',
          description: 'Donde las comunidades muestran lo que construyen juntas.',
          code: 'DEVFEST-007',
          qrValue: 'DEVFEST-TREASURE-007',
          clue: 'Vive la experiencia en primera fila: las demos más brillantes están en directo.',
          locationDescription: 'Community corner',
          iconKey: 'people',
          order: 7,
          isActive: true,
        ),
        TreasureItem(
          id: 'treasure-008',
          title: 'Tesoro #08 · El Escaparate Tecnológico',
          description: 'Las demos en vivo esconden tecnología de otro nivel.',
          code: 'DEVFEST-008',
          qrValue: 'DEVFEST-TREASURE-008',
          clue: 'Llévate un recuerdo de DevFest: la tienda oficial guarda el último hallazgo.',
          locationDescription: 'Zona de demos / expo tech',
          iconKey: 'laptop',
          order: 8,
          isActive: true,
        ),
        TreasureItem(
          id: 'treasure-009',
          title: 'Tesoro #09 · El Bazar del Recuerdo',
          description: 'El merchandising oficial custodia uno de los tesoros.',
          code: 'DEVFEST-009',
          qrValue: 'DEVFEST-TREASURE-009',
          clue: 'El broche de oro espera donde comienza todo: el punto de encuentro.',
          locationDescription: 'Zona de merchandising',
          iconKey: 'gift',
          order: 9,
          isActive: true,
        ),
        TreasureItem(
          id: 'treasure-010',
          title: 'Tesoro #10 · El Hall de los Campeones',
          description: 'El último tesoro corona a quienes completan la aventura.',
          code: 'DEVFEST-010',
          qrValue: 'DEVFEST-TREASURE-010',
          clue: '¡Reclama tu premio con el staff en la zona de registros!',
          locationDescription: 'Hall principal',
          iconKey: 'trophy',
          order: 10,
          isActive: true,
        ),
      ];

  /// 15 seeded participants with varied progress. `treasure-003` is inactive,
  /// but some early completions still own it (deactivation only blocks NEW
  /// discoveries) — a nice point to explain during the demo.
  static List<Participant> buildSeedParticipants() {
    final ids = treasureIds();
    final now = DateTime.now();
    // Completed participants.
    final carlos = _p(now, 'participant-101', 'Carlos', 'carlos_dev', 18, 32,
        discovered: ids, completedAfter: Duration(minutes: 18, seconds: 32));
    final ana = _p(now, 'participant-102', 'Ana', 'ana_builds', 21, 4,
        discovered: ids, completedAfter: Duration(minutes: 21, seconds: 4));
    final marco = _p(now, 'participant-103', 'Marco', 'marco_pixel', 25, 47,
        discovered: ids, completedAfter: Duration(minutes: 25, seconds: 47));
    // In progress participants (out-of-order discovery subsets).
    final laura = _p(now, 'participant-104', 'Laura', 'laura_ui', 12, 40,
        discovered: [
      'treasure-004',
      'treasure-001',
      'treasure-007',
      'treasure-002',
      'treasure-005',
      'treasure-009'
    ]);
    final pedro = _p(now, 'participant-105', 'Pedro', 'pedro_flutter', 9, 15,
        discovered: [
      'treasure-002',
      'treasure-006',
      'treasure-004',
      'treasure-008',
      'treasure-010'
    ]);
    final sofia = _p(now, 'participant-106', 'Sofía', 'sofia_data', 15, 8,
        discovered: [
      'treasure-001',
      'treasure-005',
      'treasure-009',
      'treasure-002',
      'treasure-006',
      'treasure-004',
      'treasure-008'
    ]);
    final diego = _p(now, 'participant-107', 'Diego', 'diego_ops', 7, 55,
        discovered: ['treasure-007', 'treasure-003', 'treasure-001']);
    final valeria = _p(now, 'participant-108', 'Valeria', 'vale_creative', 6, 20,
        discovered: ['treasure-002', 'treasure-006']);
    final miguel = _p(now, 'participant-109', 'Miguel', 'mig_code', 5, 48,
        discovered: ['treasure-001']);
    final pamela = _p(now, 'participant-110', 'Pamela', 'pamela_k', 4, 33,
        discovered: ['treasure-005', 'treasure-009']);
    final isaac = _p(now, 'participant-111', 'Isaac', 'isaac_ml', 3, 12);
    final gaby = _p(now, 'participant-112', 'Gaby', 'gaby_design', 2, 40);
    final roberto = _p(now, 'participant-113', 'Roberto', 'rob_ios', 8, 2,
        discovered: [
      'treasure-004',
      'treasure-001',
      'treasure-006',
      'treasure-008',
      'treasure-002',
      'treasure-007',
      'treasure-009',
      'treasure-005'
    ]);
    final camila = _p(now, 'participant-114', 'Camila', 'cami_test', 1, 25);
    final raul = _p(now, 'participant-115', 'Raúl', 'raul_web', 10, 5,
        discovered: [
      'treasure-001',
      'treasure-004',
      'treasure-008',
      'treasure-002',
      'treasure-006',
      'treasure-010',
      'treasure-005'
    ]);
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
  }) {
    final startedAt = now.subtract(Duration(minutes: minutesAgo, seconds: offsetSeconds));
    return Participant(
      id: id,
      name: name,
      nickname: nickname,
      startedAt: startedAt,
      completedAt: completedAfter != null ? startedAt.add(completedAfter) : null,
      status: completedAfter != null
          ? ParticipantStatus.completed
          : ParticipantStatus.active,
      discoveredTreasureIds: discovered,
    );
  }
}