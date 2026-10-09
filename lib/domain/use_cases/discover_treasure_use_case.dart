import '../../core/utils/id_generator.dart';
import '../../domain/entities/discovery.dart';
import '../../domain/entities/participant.dart';
import '../../domain/entities/treasure_item.dart';
import '../../domain/repositories/event_repository.dart';
import '../../domain/repositories/participant_repository.dart';
import '../../domain/repositories/treasure_repository.dart';

enum DiscoverFailure {
  participantNotFound,
  treasureNotFound,
  notActive,
  alreadyDiscovered,
  requiresChallenge,
  eventPaused,
}

class DiscoverTreasureResult {
  const DiscoverTreasureResult.success({
    required this.treasure,
    required this.participant,
    this.completed = false,
  }) : failure = null;

  const DiscoverTreasureResult.failure(
    this.failure, {
    this.treasure,
    this.participant,
    this.completed = false,
  });

  final DiscoverFailure? failure;
  final TreasureItem? treasure;
  final Participant? participant;
  final bool completed;

  bool get isSuccess => failure == null;

  String? get clue => treasure?.clue;
}

/// Single, centralized discovery rule. Every path — QR scan or manual code —
/// ends here.
///
/// No ordering rule exists: any active treasure can be discovered at any time.
/// The only hard blocks are `isActive == false`, a paused event,
/// and duplicate discoveries.
class DiscoverTreasureUseCase {
  DiscoverTreasureUseCase({
    required TreasureRepository treasureRepository,
    required ParticipantRepository participantRepository,
    required EventRepository eventRepository,
  }) : // Keep public constructor names without leading underscores.
       // ignore: prefer_initializing_formals
       _treasureRepository = treasureRepository,
       // ignore: prefer_initializing_formals
       _participantRepository = participantRepository,
       // ignore: prefer_initializing_formals
       _eventRepository = eventRepository;

  final TreasureRepository _treasureRepository;
  final ParticipantRepository _participantRepository;
  final EventRepository _eventRepository;

  Future<DiscoverTreasureResult> execute({
    required String participantId,
    required String treasureId,
  }) async {
    final participant = await _participantRepository.getParticipant(
      participantId,
    );
    if (participant == null) {
      return const DiscoverTreasureResult.failure(
        DiscoverFailure.participantNotFound,
      );
    }

    final treasure = await _treasureRepository.getTreasure(treasureId);
    if (treasure == null) {
      return const DiscoverTreasureResult.failure(
        DiscoverFailure.treasureNotFound,
      );
    }

    final event = await _eventRepository.getEvent();
    if (!event.active) {
      return DiscoverTreasureResult.failure(
        DiscoverFailure.eventPaused,
        treasure: treasure,
      );
    }

    if (!treasure.isActive) {
      return DiscoverTreasureResult.failure(
        DiscoverFailure.notActive,
        treasure: treasure,
      );
    }

    if (participant.discoveredTreasureIds.contains(treasure.id)) {
      return DiscoverTreasureResult.failure(
        DiscoverFailure.alreadyDiscovered,
        treasure: treasure,
        participant: participant,
      );
    }

    if (treasure.challenge != null) {
      return DiscoverTreasureResult.failure(
        DiscoverFailure.requiresChallenge,
        treasure: treasure,
        participant: participant,
      );
    }

    final now = DateTime.now();
    final discoveredIds = [...participant.discoveredTreasureIds, treasure.id];
    final total = (await _treasureRepository.getTreasures()).length;
    final completed = discoveredIds.length >= total;

    final updated = participant.copyWith(
      discoveredTreasureIds: discoveredIds,
      points: participant.points + treasure.pointValue,
      medals: discoveredIds.length,
      status: completed ? ParticipantStatus.completed : participant.status,
      completedAt: completed ? now : participant.completedAt,
    );

    await _participantRepository.updateParticipant(updated);
    await _participantRepository.recordDiscovery(
      Discovery(
        id: IdGenerator.discoveryId(),
        participantId: participant.id,
        treasureId: treasure.id,
        discoveredAt: now,
      ),
    );

    return DiscoverTreasureResult.success(
      treasure: treasure,
      participant: updated,
      completed: completed,
    );
  }
}
