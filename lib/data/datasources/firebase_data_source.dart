import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/attempt.dart';
import '../../domain/entities/discovery.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/participant.dart';
import '../../domain/entities/treasure_item.dart';
import '../local/app_local_storage.dart';
import '../local/shared_prefs_local_storage.dart';
import 'app_data_source.dart';
import 'mock_data.dart';

class FirebaseDataSource implements AppDataSource {
  FirebaseDataSource({
    FirebaseFirestore? firestore,
    AppLocalStorage? storage,
    this.eventId = 'devfest-2026',
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? SharedPrefsLocalStorage();

  static const _currentParticipantKey = 'devfest.currentParticipant.v1';

  final FirebaseFirestore _firestore;
  final AppLocalStorage _storage;
  final String eventId;

  DocumentReference<Map<String, dynamic>> get _eventRef =>
      _firestore.collection('events').doc(eventId);

  CollectionReference<Map<String, dynamic>> get _treasuresRef =>
      _eventRef.collection('treasures');

  CollectionReference<Map<String, dynamic>> get _participantsRef =>
      _eventRef.collection('participants');

  CollectionReference<Map<String, dynamic>> get _discoveriesRef =>
      _eventRef.collection('discoveries');

  CollectionReference<Map<String, dynamic>> get _attemptsRef =>
      _eventRef.collection('attempts');

  @override
  Future<void> initialize() async {
    final eventSnapshot = await _eventRef.get();
    if (!eventSnapshot.exists) {
      final event = MockData.buildEvent();
      await _eventRef.set(_eventToJson(event));
    }

    final treasureSnapshot = await _treasuresRef.limit(1).get();
    if (treasureSnapshot.docs.isEmpty) {
      await saveTreasures(MockData.buildTreasures());
    }
  }

  @override
  Future<Event> loadEvent() async {
    final snapshot = await _eventRef.get();
    final data = snapshot.data();
    if (data == null) return MockData.buildEvent();
    return _eventFromJson(data);
  }

  @override
  Future<void> setEventActive(bool active) async {
    await _eventRef.update({'active': active});
  }

  @override
  Future<List<TreasureItem>> loadTreasures() async {
    final snapshot = await _treasuresRef.get();
    return decodeTreasures(snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Malformed docs are skipped; ordering is done client-side so a doc
  /// missing the `order` field cannot silently disappear.
  static List<TreasureItem> decodeTreasures(List<Map<String, dynamic>> raws) {
    final treasures = raws
        .map(TreasureItem.tryFromJson)
        .whereType<TreasureItem>()
        .toList();
    treasures.sort((a, b) => a.order.compareTo(b.order));
    return treasures;
  }

  @override
  Future<void> saveTreasures(List<TreasureItem> treasures) async {
    final batch = _firestore.batch();
    for (final treasure in treasures) {
      batch.set(_treasuresRef.doc(treasure.id), treasure.toJson());
    }
    await batch.commit();
  }

  @override
  Future<List<Participant>> loadParticipants() async {
    final snapshot = await _participantsRef.get();
    return snapshot.docs
        .map((doc) => Participant.tryFromJson(doc.data()))
        .whereType<Participant>()
        .toList();
  }

  @override
  Future<void> saveParticipant(Participant participant) async {
    await _participantsRef.doc(participant.id).set(participant.toJson());
  }

  @override
  Future<List<Discovery>> loadDiscoveries() async {
    final snapshot = await _discoveriesRef.get();
    return snapshot.docs
        .map((doc) => Discovery.tryFromJson(doc.data()))
        .whereType<Discovery>()
        .toList();
  }

  @override
  Future<void> saveDiscovery(Discovery discovery) async {
    await _discoveriesRef.doc(discovery.id).set(discovery.toJson());
  }

  @override
  Future<String?> getCurrentParticipantId() =>
      _storage.read(_currentParticipantKey);

  @override
  Future<void> setCurrentParticipantId(String? id) async {
    if (id == null) {
      await _storage.remove(_currentParticipantKey);
      return;
    }
    await _storage.write(_currentParticipantKey, id);
  }

  @override
  Future<void> reset() async {
    await _deleteCollection(_participantsRef);
    await _deleteCollection(_discoveriesRef);
    await _deleteCollection(_attemptsRef);
    await saveTreasures(MockData.buildTreasures());
    await _storage.remove(_currentParticipantKey);
  }

  @override
  Future<List<Attempt>> loadAttempts() async {
    final snapshot = await _attemptsRef.get();
    return snapshot.docs
        .map((doc) => Attempt.tryFromJson(doc.data()))
        .whereType<Attempt>()
        .toList();
  }

  @override
  Future<void> saveAttempt(Attempt attempt) async {
    await _attemptsRef.doc(attempt.id).set(attempt.toJson());
  }

  Future<void> _deleteCollection(
    CollectionReference<Map<String, dynamic>> collection,
  ) async {
    const batchSize = 100;
    while (true) {
      final snapshot = await collection.limit(batchSize).get();
      if (snapshot.docs.isEmpty) return;
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  Map<String, dynamic> _eventToJson(Event event) => {
    'id': event.id,
    'name': event.name,
    'description': event.description,
    'dateLabel': event.dateLabel,
    'active': event.active,
  };

  Event _eventFromJson(Map<String, dynamic> json) => Event(
    id: json['id'] as String? ?? eventId,
    name: json['name'] as String? ?? 'DevFest Master',
    description: json['description'] as String? ?? '',
    dateLabel: json['dateLabel'] as String?,
    active: json['active'] as bool? ?? true,
  );
}
