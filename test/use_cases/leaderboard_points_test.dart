import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
import 'package:devfest_treasure_hunt/domain/entities/leaderboard_entry.dart';
import 'package:devfest_treasure_hunt/domain/use_cases/leaderboard_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockLocalDataSource dataSource;
  late MockAppRepository repository;
  late LeaderboardUseCase useCase;

  setUp(() async {
    dataSource = MockLocalDataSource(seedData: false);
    await dataSource.initialize();
    repository = MockAppRepository(dataSource);
    useCase = LeaderboardUseCase(repository);
  });

  Future<List<LeaderboardEntry>> loadBoard() async {
    return useCase.execute(
      participants: await repository.getParticipants(),
      totalTreasures: (await repository.getTreasures()).length,
    );
  }

  Future<void> addParticipant({
    required String id,
    required String name,
    required int points,
    required List<String> discovered,
    required int minutesAgo,
  }) async {
    final participant = await repository.createParticipant(
      id: id,
      name: name,
      nickname: name.toLowerCase(),
      startedAt: DateTime.now().subtract(Duration(minutes: minutesAgo)),
    );
    await repository.updateParticipant(
      participant.copyWith(
        points: points,
        medals: discovered.length,
        discoveredTreasureIds: discovered,
      ),
    );
  }

  test('sorts by points desc before medal count and elapsed time', () async {
    await addParticipant(
      id: 'p1',
      name: 'Ana',
      points: 300,
      discovered: ['gym-android', 'gym-web', 'gym-cloud'],
      minutesAgo: 5,
    );
    await addParticipant(
      id: 'p2',
      name: 'Pedro',
      points: 430,
      discovered: ['gym-android', 'gym-web'],
      minutesAgo: 20,
    );

    final board = await loadBoard();

    expect(board.first.participantId, 'p2');
    expect(board.first.points, 430);
  });

  test(
    'equal points share a rank and the next rank skips tied places',
    () async {
      await addParticipant(
        id: 'p1',
        name: 'Ana',
        points: 570,
        discovered: ['gym-android', 'gym-web', 'gym-cloud', 'gym-ia'],
        minutesAgo: 90,
      );
      await addParticipant(
        id: 'p2',
        name: 'Pedro',
        points: 570,
        discovered: ['gym-android', 'gym-web'],
        minutesAgo: 300,
      );
      await addParticipant(
        id: 'p3',
        name: 'Laura',
        points: 545,
        discovered: ['gym-android', 'gym-web', 'gym-cloud', 'gym-ia'],
        minutesAgo: 20,
      );

      final board = await loadBoard();

      expect(board.map((entry) => entry.position), [1, 1, 3]);
      expect(board.map((entry) => entry.points), [570, 570, 545]);
    },
  );
}
