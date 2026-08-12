import 'package:devfest_treasure_hunt/data/datasources/mock_data.dart';
import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
import 'package:devfest_treasure_hunt/domain/use_cases/discover_treasure_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockLocalDataSource dataSource;
  late MockAppRepository repository;
  late DiscoverTreasureUseCase useCase;

  setUp(() async {
    dataSource = MockLocalDataSource();
    await dataSource.initialize();
    repository = MockAppRepository(dataSource);
    useCase = DiscoverTreasureUseCase(
      treasureRepository: repository,
      participantRepository: repository,
    );
  });

  Future<String> createParticipant(String name) async {
    final p = await repository.createParticipant(
      id: 'participant-test',
      name: name,
      nickname: 'nick_${name.toLowerCase()}',
      startedAt: DateTime.now(),
    );
    return p.id;
  }

  test('discovers treasures in ANY order without errors', () async {
    final pid = await createParticipant('Laura');

    // Random-ish order: 4 -> 1 -> 7 -> 3 (3 is inactive, skipped) -> 2.
    final r1 = await useCase.execute(participantId: pid, treasureId: 'treasure-004');
    final r2 = await useCase.execute(participantId: pid, treasureId: 'treasure-001');
    final r3 = await useCase.execute(participantId: pid, treasureId: 'treasure-007');
    final r4 = await useCase.execute(participantId: pid, treasureId: 'treasure-002');

    expect(r1.isSuccess, isTrue);
    expect(r2.isSuccess, isTrue);
    expect(r3.isSuccess, isTrue);
    expect(r4.isSuccess, isTrue);

    final participant = await repository.getParticipant(pid);
    expect(participant!.discoveredCount, 4);
    // Discoveries were registered in the exact order attempted.
    expect(participant.discoveredTreasureIds, [
      'treasure-004',
      'treasure-001',
      'treasure-007',
      'treasure-002',
    ]);
  });

  test('inactive treasure is rejected and NOT registered', () async {
    final pid = await createParticipant('Diego');

    final result = await useCase.execute(
      participantId: pid,
      treasureId: 'treasure-003',
    );

    expect(result.failure, DiscoverFailure.notActive);
    final participant = await repository.getParticipant(pid);
    expect(participant!.discoveredCount, 0);
    final discoveries =
        await dataSource.loadDiscoveries();
    expect(
      discoveries.where((d) => d.participantId == pid),
      isEmpty,
    );
  });

  test('the same treasure cannot be discovered twice', () async {
    final pid = await createParticipant('Ana');

    final first = await useCase.execute(participantId: pid, treasureId: 'treasure-005');
    final second = await useCase.execute(participantId: pid, treasureId: 'treasure-005');

    expect(first.isSuccess, isTrue);
    expect(second.failure, DiscoverFailure.alreadyDiscovered);
    final participant = await repository.getParticipant(pid);
    expect(participant!.discoveredCount, 1);
  });

  test('a treasure with unknown id is reported as not found', () async {
    final pid = await createParticipant('Isaac');

    final result = await useCase.execute(participantId: pid, treasureId: 'treasure-999');
    expect(result.failure, DiscoverFailure.treasureNotFound);
  });

  test('unknown participant cannot discover anything', () async {
    final result = await useCase.execute(
      participantId: 'nobody',
      treasureId: 'treasure-001',
    );
    expect(result.failure, DiscoverFailure.participantNotFound);
  });

  test('discovering every treasure completes the participant', () async {
    final pid = await createParticipant('Carlos');

    // The admin must have activated every treasure for the run to be
    // completable: proves the demo can toggle availability too.
    await repository.setTreasureActive('treasure-003', true);

    final ids = MockData.buildTreasures().map((t) => t.id).toList();
    // Deliberately shuffled to prove the order does not matter.
    final shuffled = [
      'treasure-009',
      'treasure-002',
      'treasure-010',
      'treasure-001',
      'treasure-008',
      'treasure-004',
      'treasure-006',
      'treasure-005',
      'treasure-007',
      'treasure-003',
    ];

    DiscoverTreasureResult? last;
    for (final id in shuffled) {
      last = await useCase.execute(participantId: pid, treasureId: id);
    }

    expect(last!.isSuccess, isTrue);
    expect(last.completed, isTrue);
    expect(last.participant!.isCompleted, isTrue);
    expect(last.participant!.completedAt, isNotNull);

    final participant = await repository.getParticipant(pid);
    expect(participant!.discoveredCount, ids.length);
  });

  test('a successful discovery unlocks a clue on the result', () async {
    final pid = await createParticipant('Valeria');

    final result = await useCase.execute(participantId: pid, treasureId: 'treasure-001');
    expect(result.isSuccess, isTrue);
    expect(result.clue, isNotEmpty);
  });
}