import '../../domain/entities/discovery.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/participant.dart';
import '../../domain/entities/treasure_item.dart';
import '../local/app_local_storage.dart';
import 'app_data_source.dart';
import 'mock_data.dart';

/// Local implementation of [AppDataSource].
///
/// Works fully in memory, and when an [AppLocalStorage] is provided it also
/// persists the demo state (treasures toggles, participants, discoveries,
/// current participant) so the event survives app restarts.
///
/// A future `FirebaseDataSource` replicates this contract against Firestore.
class MockLocalDataSource implements AppDataSource {
  MockLocalDataSource({AppLocalStorage? storage, this.seedData = true})
      : _storage = storage;

  final AppLocalStorage? _storage;

  /// When `false`, starts with no participants/discoveries (used by tests and
  /// demos that want a clean slate while keeping the seeded treasures).
  final bool seedData;

  static const _treasuresKey = 'devfest.treasures.v1';
  static const _participantsKey = 'devfest.participants.v1';
  static const _discoveriesKey = 'devfest.discoveries.v1';
  static const _currentParticipantKey = 'devfest.currentParticipant.v1';

  late Event _event;
  late List<TreasureItem> _treasures;
  late List<Participant> _participants;
  late List<Discovery> _discoveries;
  String? _currentParticipantId;
  bool _loaded = false;

  @override
  Future<void> initialize() async {
    if (_loaded) return;
    _loaded = true;
    _event = MockData.buildEvent();
    _treasures = await _restore(_treasuresKey, MockData.buildTreasures(),
        TreasureItem.listFromJson, TreasureItem.listToJson);
    _participants = await _restore(_participantsKey,
        seedData ? MockData.buildSeedParticipants() : <Participant>[],
        Participant.listFromJson, Participant.listToJson);
    _discoveries = await _restore(
        _discoveriesKey,
        seedData ? _seedDiscoveries(_participants) : <Discovery>[],
        Discovery.listFromJson,
        Discovery.listToJson);
    _currentParticipantId = await _storage?.read(_currentParticipantKey);
  }

  List<Discovery> _seedDiscoveries(List<Participant> participants) {
    final result = <Discovery>[];
    for (final p in participants) {
      for (final t in p.discoveredTreasureIds) {
        result.add(Discovery(
          id: 'discovery-${p.id}-$t',
          participantId: p.id,
          treasureId: t,
          discoveredAt: p.startedAt.add(const Duration(minutes: 1)),
        ));
      }
    }
    return result;
  }

  Future<T> _restore<T>(
    String key,
    T fallback,
    T Function(String) decode,
    String Function(T) encode,
  ) async {
    final storage = _storage;
    if (storage == null) return fallback;
    final raw = await storage.read(key);
    if (raw == null) {
      await storage.write(key, encode(fallback));
      return fallback;
    }
    try {
      return decode(raw);
    } catch (_) {
      return fallback;
    }
  }

  @override
  Future<Event> loadEvent() async => _event;

  @override
  Future<List<TreasureItem>> loadTreasures() async => List.of(_treasures);

  @override
  Future<void> saveTreasures(List<TreasureItem> treasures) async {
    _treasures = List.of(treasures);
    await _persist(_treasuresKey, _treasures, TreasureItem.listToJson);
  }

  @override
  Future<List<Participant>> loadParticipants() async => List.of(_participants);

  @override
  Future<void> saveParticipant(Participant participant) async {
    final index = _participants.indexWhere((p) => p.id == participant.id);
    if (index == -1) {
      _participants.add(participant);
    } else {
      _participants[index] = participant;
    }
    await _persist(_participantsKey, _participants, Participant.listToJson);
  }

  @override
  Future<List<Discovery>> loadDiscoveries() async => List.of(_discoveries);

  @override
  Future<void> saveDiscovery(Discovery discovery) async {
    _discoveries.add(discovery);
    await _persist(_discoveriesKey, _discoveries, Discovery.listToJson);
  }

  @override
  Future<String?> getCurrentParticipantId() async => _currentParticipantId;

  @override
  Future<void> setCurrentParticipantId(String? id) async {
    _currentParticipantId = id;
    final storage = _storage;
    if (storage == null) return;
    if (id == null) {
      await storage.remove(_currentParticipantKey);
    } else {
      await storage.write(_currentParticipantKey, id);
    }
  }

  @override
  Future<void> reset() async {
    _event = MockData.buildEvent();
    _treasures = MockData.buildTreasures();
    _participants = seedData ? MockData.buildSeedParticipants() : <Participant>[];
    _discoveries = seedData ? _seedDiscoveries(_participants) : <Discovery>[];
    _currentParticipantId = null;
    final storage = _storage;
    if (storage == null) return;
    await storage.remove(_treasuresKey);
    await storage.remove(_participantsKey);
    await storage.remove(_discoveriesKey);
    await storage.remove(_currentParticipantKey);
  }

  Future<void> _persist<T>(String key, T value, String Function(T) encode) async {
    final storage = _storage;
    if (storage == null) return;
    await storage.write(key, encode(value));
  }
}