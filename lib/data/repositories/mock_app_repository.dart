import '../../domain/entities/discovery.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/entities/participant.dart';
import '../../domain/entities/treasure_item.dart';
import '../../domain/repositories/event_repository.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../../domain/repositories/participant_repository.dart';
import '../../domain/repositories/treasure_repository.dart';
import '../datasources/app_data_source.dart';

/// Single class implementing every repository contract against the local
/// data source. In production these become separate Firebase repositories
/// (`FirebaseTreasureRepository`, ...) that the UI knows nothing about.
class MockAppRepository
    implements
        TreasureRepository,
        ParticipantRepository,
        LeaderboardRepository,
        EventRepository {
  MockAppRepository(this._dataSource);

  final AppDataSource _dataSource;

  // ---------- TreasureRepository ----------

  @override
  Future<List<TreasureItem>> getTreasures() => _dataSource.loadTreasures();

  @override
  Future<TreasureItem?> getTreasure(String id) async {
    final treasures = await _dataSource.loadTreasures();
    for (final t in treasures) {
      if (t.id == id) return t;
    }
    return null;
  }

  @override
  Future<TreasureItem?> getByCode(String code) async {
    final normalized = code.trim().toUpperCase();
    final treasures = await _dataSource.loadTreasures();
    for (final t in treasures) {
      if (t.code.trim().toUpperCase() == normalized) return t;
    }
    return null;
  }

  @override
  Future<TreasureItem?> getByQrValue(String value) async {
    final normalized = value.trim().toUpperCase();
    final treasures = await _dataSource.loadTreasures();
    for (final t in treasures) {
      if (t.qrValue.trim().toUpperCase() == normalized) return t;
    }
    return null;
  }

  @override
  Future<void> setTreasureActive(String id, bool active) async {
    final treasures = await _dataSource.loadTreasures();
    final updated =
        treasures.map((t) => t.id == id ? t.copyWith(isActive: active) : t).toList();
    await _dataSource.saveTreasures(updated);
  }

  // ---------- ParticipantRepository ----------

  @override
  Future<Participant> createParticipant({
    required String id,
    required String name,
    required String nickname,
    required DateTime startedAt,
  }) async {
    final participant = Participant(
      id: id,
      name: name,
      nickname: nickname,
      startedAt: startedAt,
    );
    await _dataSource.saveParticipant(participant);
    return participant;
  }

  @override
  Future<Participant?> getParticipant(String id) async {
    final participants = await _dataSource.loadParticipants();
    for (final p in participants) {
      if (p.id == id) return p;
    }
    return null;
  }

  @override
  Future<void> updateParticipant(Participant participant) =>
      _dataSource.saveParticipant(participant);

  @override
  Future<List<Participant>> getParticipants() =>
      _dataSource.loadParticipants();

  @override
  Future<String?> getCurrentParticipantId() =>
      _dataSource.getCurrentParticipantId();

  @override
  Future<void> setCurrentParticipantId(String id) =>
      _dataSource.setCurrentParticipantId(id);

  @override
  Future<void> recordDiscovery(Discovery discovery) =>
      _dataSource.saveDiscovery(discovery);

  // ---------- LeaderboardRepository ----------

  @override
  Future<List<LeaderboardEntry>> getLeaderboard() async {
    final participants = await _dataSource.loadParticipants();
    final treasures = await _dataSource.loadTreasures();
    final totalTreasures = treasures.length;

    final entries = participants.map((p) {
      final elapsed = p.isCompleted
          ? p.completedAt!.difference(p.startedAt)
          : DateTime.now().difference(p.startedAt);
      return LeaderboardEntry(
        participantId: p.id,
        name: p.name,
        nickname: p.nickname,
        discoveredCount: p.discoveredCount,
        totalTreasures: totalTreasures,
        elapsed: elapsed,
        status: p.status,
      );
    }).toList();

    entries.sort((a, b) {
      if (a.discoveredCount != b.discoveredCount) {
        return b.discoveredCount.compareTo(a.discoveredCount);
      }
      return a.elapsed.compareTo(b.elapsed);
    });

    for (var i = 0; i < entries.length; i++) {
      entries[i] = LeaderboardEntry(
        participantId: entries[i].participantId,
        name: entries[i].name,
        nickname: entries[i].nickname,
        discoveredCount: entries[i].discoveredCount,
        totalTreasures: entries[i].totalTreasures,
        elapsed: entries[i].elapsed,
        status: entries[i].status,
        position: i + 1,
      );
    }
    return entries;
  }

  // ---------- EventRepository ----------

  @override
  Future<Event> getEvent() => _dataSource.loadEvent();
}