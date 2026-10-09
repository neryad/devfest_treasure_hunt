import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
import 'package:devfest_treasure_hunt/domain/entities/leaderboard_entry.dart';
import 'package:devfest_treasure_hunt/domain/entities/participant.dart';
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

  Future<Participant> add(
    String id,
    String name,
    int minutesAgo,
    List<String> discovered, {
    int? completeInMinutes,
  }) async {
    final startedAt = DateTime.now().subtract(Duration(minutes: minutesAgo));
    final p = await repository.createParticipant(
      id: id,
      name: name,
      nickname: name.toLowerCase(),
      startedAt: startedAt,
    );
    final updated = p.copyWith(
      discoveredTreasureIds: discovered,
      points: discovered.length * 100,
      medals: discovered.length,
      status: completeInMinutes == null ? null : ParticipantStatus.completed,
      completedAt: completeInMinutes == null
          ? null
          : startedAt.add(Duration(minutes: completeInMinutes)),
    );
    await repository.updateParticipant(updated);
    return updated;
  }

  test('sorts by points and keeps tied scores at the same position', () async {
    await add('p1', 'Ana', 30, ['a', 'b', 'c'], completeInMinutes: 20);
    await add('p2', 'Pedro', 30, ['a', 'b', 'c'], completeInMinutes: 12);
    await add('p3', 'Laura', 10, ['a']);
    await add('p4', 'Sofía', 10, ['a', 'b', 'c', 'd']);

    final board = await loadBoard();

    expect(board.map((entry) => entry.participantId), ['p4', 'p1', 'p2', 'p3']);
    expect(board.map((entry) => entry.position), [1, 2, 2, 4]);
  });

  test('positions are 1-based consecutive numbers', () async {
    await add('p1', 'Ana', 5, ['a', 'b']);
    await add('p2', 'Pedro', 5, ['a']);

    final board = await loadBoard();
    expect(board[0].position, 1);
    expect(board[1].position, 2);
  });

  test('status and elapsed time do not break a points tie', () async {
    await add('p1', 'Ana', 20, ['a', 'b'], completeInMinutes: 2);
    await add('p2', 'Pedro', 30, ['a', 'b']);

    final board = await loadBoard();
    expect(board.map((entry) => entry.position), [1, 1]);
    expect(board.map((entry) => entry.points), [200, 200]);
  });
}
