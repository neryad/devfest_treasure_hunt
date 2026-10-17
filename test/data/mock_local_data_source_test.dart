import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/datasources/mock_data.dart';
import 'package:devfest_treasure_hunt/data/datasources/demo_data_seed.dart';
import 'package:devfest_treasure_hunt/data/local/app_local_storage.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
import 'package:devfest_treasure_hunt/domain/entities/gym_challenge.dart';
import 'package:devfest_treasure_hunt/domain/entities/treasure_item.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryStorage implements AppLocalStorage {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> remove(String key) async {
    values.remove(key);
  }

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads and restores the bundled event snapshot in local mode', () async {
    final fixture = await rootBundle.loadString(
      'assets/demo/devfest-2026.json',
    );
    final seed = DemoDataSeed.fromJson(fixture);
    final storage = _MemoryStorage();
    final dataSource = MockLocalDataSource(storage: storage, initialData: seed);
    await dataSource.initialize();

    final participants = await dataSource.loadParticipants();
    final participantIds = participants.map((item) => item.id).toSet();
    final attempts = await dataSource.loadAttempts();

    expect(seed.treasures, hasLength(8));
    expect(participants, hasLength(183));
    expect(
      participants.every(
        (participant) =>
            participant.name.startsWith('Participante demo ') &&
            participant.nickname.startsWith('explorador_'),
      ),
      isTrue,
    );
    expect(attempts, hasLength(1706));
    expect(
      attempts.every(
        (attempt) => participantIds.contains(attempt.participantId),
      ),
      isTrue,
    );

    await dataSource.reset();

    expect(await dataSource.loadParticipants(), hasLength(183));
    expect(await dataSource.loadAttempts(), hasLength(1706));
    expect((await dataSource.loadTreasures()), hasLength(8));
  });

  test(
    'setEventActive persists the event state for subsequent loads',
    () async {
      final dataSource = MockLocalDataSource();
      await dataSource.initialize();
      final repository = MockAppRepository(dataSource);

      expect((await repository.getEvent()).active, isTrue);

      await repository.setEventActive(false);

      final updated = await repository.getEvent();
      expect(updated.active, isFalse);
      expect(updated.id, isNotEmpty);
      expect(updated.name, isNotEmpty);
    },
  );

  test(
    'migrates persisted legacy challenges and preserves availability',
    () async {
      final storage = _MemoryStorage();
      final legacy = MockData.buildTreasures().map((item) {
        if (item.id != 'gym-android') return item;
        return item.copyWith(
          isActive: false,
          challenge: const GymChallenge(
            type: ChallengeType.code,
            question: 'Legacy question',
            options: ['Legacy answer'],
            correctAnswer: 'Legacy answer',
          ),
        );
      }).toList();
      await storage.write(
        'devfest.treasures.v1',
        TreasureItem.listToJson(legacy),
      );

      final dataSource = MockLocalDataSource(storage: storage, seedData: false);
      await dataSource.initialize();
      final repository = MockAppRepository(dataSource);
      final android = await repository.getTreasure('gym-android');

      expect(android!.isActive, isFalse);
      expect(android.challenge!.questionBank, hasLength(4));
      expect(android.challenge!.questionsRequired, 4);
      expect(storage.values['devfest.challengeContentVersion'], '11');
    },
  );
}
