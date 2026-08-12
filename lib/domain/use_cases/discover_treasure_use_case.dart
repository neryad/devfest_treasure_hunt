import '../../core/utils/id_generator.dart';
import '../../domain/entities/discovery.dart';
import '../../domain/entities/participant.dart';
import '../../domain/entities/treasure_item.dart';
import '../../domain/repositories/participant_repository.dart';
import '../../domain/repositories/treasure_repository.dart';

enum DiscoverFailure {
  participantNotFound,
  treasureNotFound,
  notActive,
  alreadyDiscovered,
}

class DiscoverTreasureResult {
  const DiscoverTreasureResult.success({
    required this.treasure,
    required this.participant,
    this.completed = false,
  }) : failure = null;

  const DiscoverTreasureResult.failure(this.failure,
      {this.treasure, this.participant, this.completed = false});

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
/// The only hard blocks are `isActive == false` and duplicate discoveries.
class DiscoverTreasureUseCase {
  DiscoverTreasureUseCase({
    required TreasureRepository treasureRepository,
    required ParticipantRepository participantRepository,
  })  : _treasureRepository = treasureRepository,
        _participantRepository = participantRepository;

  final TreasureRepository _treasureRepository;
  final ParticipantRepository _participantRepository;

  Future<DiscoverTreasureResult> execute({
    required String participantId,
    required String treasureId,
  }) async {
    final participant = await _participantRepository.getParticipant(participantId);
    if (participant == null) {
      return const DiscoverTreasureResult.failure(
          DiscoverFailure.participantNotFound);
    }

    final treasure = await _treasureRepository.getTreasure(treasureId);
    if (treasure == null) {
      return const DiscoverTreasureResult.failure(
          DiscoverFailure.treasureNotFound);
    }

    if (!treasure.isActive) {
      return DiscoverTreasureResult.failure(DiscoverFailure.notActive,
          treasure: treasure);
    }

    if (participant.discoveredTreasureIds.contains(treasure.id)) {
      return DiscoverTreasureResult.failure(
        DiscoverFailure.alreadyDiscovered,
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
      status: completed ? ParticipantStatus.completed : participant.status,
      completedAt: completed ? now : participant.completedAt,
    );

    await _participantRepository.updateParticipant(updated);
    await _participantRepository.recordDiscovery(Discovery(
      id: IdGenerator.discoveryId(),
      participantId: participant.id,
      treasureId: treasure.id,
      discoveredAt: now,
    ));

    return DiscoverTreasureResult.success(
      treasure: treasure,
      participant: updated,
      completed: completed,
    );
  }
}