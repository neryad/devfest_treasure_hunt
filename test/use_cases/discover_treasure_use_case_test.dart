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
      eventRepository: repository,
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

    final r1 = await useCase.execute(participantId: pid, treasureId: 'gym-web');
    final r2 = await useCase.execute(
      participantId: pid,
      treasureId: 'gym-android',
    );
    final r3 = await useCase.execute(
      participantId: pid,
      treasureId: 'gym-speaker',
    );
    final r4 = await useCase.execute(participantId: pid, treasureId: 'gym-ia');

    expect(r1.isSuccess, isTrue);
    expect(r2.isSuccess, isTrue);
    expect(r3.isSuccess, isTrue);
    expect(r4.isSuccess, isTrue);

    final participant = await repository.getParticipant(pid);
    expect(participant!.discoveredCount, 4);
    // Discoveries were registered in the exact order attempted.
    expect(participant.discoveredTreasureIds, [
      'gym-web',
      'gym-android',
      'gym-speaker',
      'gym-ia',
    ]);
  });

  test('inactive treasure is rejected and NOT registered', () async {
    final pid = await createParticipant('Diego');

    await repository.setTreasureActive('gym-security', false);

    final result = await useCase.execute(
      participantId: pid,
      treasureId: 'gym-security',
    );

    expect(result.failure, DiscoverFailure.notActive);
    final participant = await repository.getParticipant(pid);
    expect(participant!.discoveredCount, 0);
    final discoveries = await dataSource.loadDiscoveries();
    expect(discoveries.where((d) => d.participantId == pid), isEmpty);
  });

  test('the same treasure cannot be discovered twice', () async {
    final pid = await createParticipant('Ana');

    final first = await useCase.execute(
      participantId: pid,
      treasureId: 'gym-startup',
    );
    final second = await useCase.execute(
      participantId: pid,
      treasureId: 'gym-startup',
    );

    expect(first.isSuccess, isTrue);
    expect(second.failure, DiscoverFailure.alreadyDiscovered);
    final participant = await repository.getParticipant(pid);
    expect(participant!.discoveredCount, 1);
  });

  test('a treasure with unknown id is reported as not found', () async {
    final pid = await createParticipant('Isaac');

    final result = await useCase.execute(
      participantId: pid,
      treasureId: 'treasure-999',
    );
    expect(result.failure, DiscoverFailure.treasureNotFound);
  });

  test('unknown participant cannot discover anything', () async {
    final result = await useCase.execute(
      participantId: 'nobody',
      treasureId: 'gym-android',
    );
    expect(result.failure, DiscoverFailure.participantNotFound);
  });

  test('discovering every treasure completes the participant', () async {
    final pid = await createParticipant('Carlos');

    final ids = MockData.buildTreasures().map((t) => t.id).toList();
    // Deliberately shuffled to prove the order does not matter.
    final shuffled = [
      'gym-speaker',
      'gym-ia',
      'gym-community',
      'gym-android',
      'gym-cloud',
      'gym-web',
      'gym-startup',
      'gym-security',
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

    final result = await useCase.execute(
      participantId: pid,
      treasureId: 'gym-android',
    );
    expect(result.isSuccess, isTrue);
    expect(result.clue, isNotEmpty);
  });

  test('paused event blocks any discovery', () async {
    final pid = await createParticipant('Paused');
    await repository.setEventActive(false);

    final result = await useCase.execute(
      participantId: pid,
      treasureId: 'gym-android',
    );

    expect(result.failure, DiscoverFailure.eventPaused);
    expect(result.treasure, isNotNull);
    final participant = await repository.getParticipant(pid);
    expect(participant!.discoveredCount, 0);
    final discoveries = await dataSource.loadDiscoveries();
    expect(discoveries.where((d) => d.participantId == pid), isEmpty);
  });
}
