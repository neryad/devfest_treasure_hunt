import '../entities/discovery.dart';
import '../entities/participant.dart';

/// Abstraction over participant storage. In Firebase this maps to
/// `events/{eventId}/participants/{participantId}` plus the nested
/// `discoveries` sub-collection.
abstract class ParticipantRepository {
  Future<Participant> createParticipant({
    required String id,
    required String name,
    required String nickname,
    required DateTime startedAt,
  });

  Future<Participant?> getParticipant(String id);

  /// Upsert a participant snapshot.
  Future<void> updateParticipant(Participant participant);

  Future<List<Participant>> getParticipants();

  /// Id remembered so the demo can restore the last session on restart.
  Future<String?> getCurrentParticipantId();

  Future<void> setCurrentParticipantId(String id);

  Future<void> recordDiscovery(Discovery discovery);
}