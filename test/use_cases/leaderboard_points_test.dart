import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
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

    final board = await useCase.execute();

    expect(board.first.participantId, 'p2');
    expect(board.first.points, 430);
  });
}
