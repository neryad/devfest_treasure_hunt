import '../../domain/entities/discovery.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/participant.dart';
import '../../domain/entities/treasure_item.dart';

/// Storage level of the app.
///
/// `MockLocalDataSource` implements this today. A future
/// `FirebaseDataSource` implements exactly the same contract, so
/// repositories and the UI do not change.
///
/// Future Firestore mapping:
/// - event          -> `events/{eventId}`
/// - treasures      -> `events/{eventId}/treasures`
/// - participants   -> `events/{eventId}/participants`
/// - discoveries    -> `events/{eventId}/participants/{id}/discoveries`
abstract class AppDataSource {
  Future<void> initialize();

  Future<Event> loadEvent();

  Future<List<TreasureItem>> loadTreasures();

  Future<void> saveTreasures(List<TreasureItem> treasures);

  Future<List<Participant>> loadParticipants();

  Future<void> saveParticipant(Participant participant);

  Future<List<Discovery>> loadDiscoveries();

  Future<void> saveDiscovery(Discovery discovery);

  Future<String?> getCurrentParticipantId();

  Future<void> setCurrentParticipantId(String? id);

  /// Wipes persisted demo state so the event starts from scratch.
  Future<void> reset();
}