import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/datasources/mock_data.dart';
import 'package:devfest_treasure_hunt/data/local/app_local_storage.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
import 'package:devfest_treasure_hunt/domain/entities/gym_challenge.dart';
import 'package:devfest_treasure_hunt/domain/entities/treasure_item.dart';
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
