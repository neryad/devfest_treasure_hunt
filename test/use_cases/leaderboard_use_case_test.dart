import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
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
      status: completeInMinutes == null ? null : ParticipantStatus.completed,
      completedAt: completeInMinutes == null
          ? null
          : startedAt.add(Duration(minutes: completeInMinutes)),
    );
    await repository.updateParticipant(updated);
    return updated;
  }

  test('sorts by discovered count desc, then elapsed time asc', () async {
    await add('p1', 'Ana', 30, ['a', 'b', 'c'], completeInMinutes: 20);
    await add('p2', 'Pedro', 30, ['a', 'b', 'c'], completeInMinutes: 12);
    await add('p3', 'Laura', 10, ['a']);
    await add('p4', 'Sofía', 10, ['a', 'b', 'c', 'd']);

    final board = await useCase.execute();

    expect(board[0].participantId, 'p4'); // 4 treasures
    // Both have 3; Pedro finished faster.
    expect(board[1].participantId, 'p2');
    expect(board[2].participantId, 'p1');
    // Only 1 treasure.
    expect(board[3].participantId, 'p3');
  });

  test('positions are 1-based consecutive numbers', () async {
    await add('p1', 'Ana', 5, ['a', 'b']);
    await add('p2', 'Pedro', 5, ['a']);

    final board = await useCase.execute();
    expect(board[0].position, 1);
    expect(board[1].position, 2);
  });

  test('completed participants finish above in-progress ones with same count',
      () async {
    // Same count; a fast completion (2 min) outranks a longer running clock.
    await add('p1', 'Ana', 20, ['a', 'b'], completeInMinutes: 2);
    await add('p2', 'Pedro', 30, ['a', 'b']);

    final board = await useCase.execute();
    expect(board[0].participantId, 'p1');
    expect(board[0].status, ParticipantStatus.completed);
  });
}