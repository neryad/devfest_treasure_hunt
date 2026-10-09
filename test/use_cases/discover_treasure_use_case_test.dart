import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
import 'package:devfest_treasure_hunt/domain/entities/gym_challenge.dart';
import 'package:devfest_treasure_hunt/domain/entities/treasure_item.dart';
import 'package:devfest_treasure_hunt/domain/use_cases/discover_treasure_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockLocalDataSource dataSource;
  late MockAppRepository repository;
  late DiscoverTreasureUseCase useCase;

  setUp(() async {
    dataSource = MockLocalDataSource(seedData: false);
    await dataSource.initialize();
    repository = MockAppRepository(dataSource);
    useCase = DiscoverTreasureUseCase(
      treasureRepository: repository,
      participantRepository: repository,
      eventRepository: repository,
    );
  });

  Future<String> createParticipant() async {
    final participant = await repository.createParticipant(
      id: 'participant-test',
      name: 'Test User',
      nickname: 'tester',
      startedAt: DateTime.now(),
    );
    return participant.id;
  }

  Future<TreasureItem> makeQrOnly(String gymId) async {
    final original = (await repository.getTreasure(gymId))!;
    final replacement = TreasureItem(
      id: original.id,
      title: original.title,
      description: original.description,
      code: original.code,
      clue: original.clue,
      locationDescription: original.locationDescription,
      iconKey: original.iconKey,
      order: original.order,
      isActive: original.isActive,
      createdAt: original.createdAt,
      challengeType: ChallengeType.qr,
      gymName: original.gymName,
      track: original.track,
      pointValue: original.pointValue,
    );
    final treasures = await dataSource.loadTreasures();
    await dataSource.saveTreasures([
      for (final treasure in treasures)
        if (treasure.id == gymId) replacement else treasure,
    ]);
    return replacement;
  }

  test(
    'a gym with a challenge requires its challenge and grants no medal',
    () async {
      final participantId = await createParticipant();

      final result = await useCase.execute(
        participantId: participantId,
        treasureId: 'gym-android',
      );

      expect(result.failure, DiscoverFailure.requiresChallenge);
      expect(result.treasure?.id, 'gym-android');
      final participant = await repository.getParticipant(participantId);
      expect(participant!.medals, 0);
      expect(participant.discoveredTreasureIds, isEmpty);
    },
  );

  test('a QR-only gym still grants its medal', () async {
    final participantId = await createParticipant();
    await makeQrOnly('gym-android');

    final result = await useCase.execute(
      participantId: participantId,
      treasureId: 'gym-android',
    );

    expect(result.isSuccess, isTrue);
    expect(result.participant!.discoveredTreasureIds, ['gym-android']);
    expect(result.participant!.medals, 1);
  });

  test('an inactive gym is rejected before challenge routing', () async {
    final participantId = await createParticipant();
    await repository.setTreasureActive('gym-android', false);

    final result = await useCase.execute(
      participantId: participantId,
      treasureId: 'gym-android',
    );

    expect(result.failure, DiscoverFailure.notActive);
  });

  test('a QR-only gym cannot be discovered twice', () async {
    final participantId = await createParticipant();
    await makeQrOnly('gym-android');
    await useCase.execute(
      participantId: participantId,
      treasureId: 'gym-android',
    );

    final duplicate = await useCase.execute(
      participantId: participantId,
      treasureId: 'gym-android',
    );

    expect(duplicate.failure, DiscoverFailure.alreadyDiscovered);
  });

  test('unknown treasure and participant are reported', () async {
    final participantId = await createParticipant();
    final missingGym = await useCase.execute(
      participantId: participantId,
      treasureId: 'missing',
    );
    final missingParticipant = await useCase.execute(
      participantId: 'missing',
      treasureId: 'gym-android',
    );

    expect(missingGym.failure, DiscoverFailure.treasureNotFound);
    expect(missingParticipant.failure, DiscoverFailure.participantNotFound);
  });

  test('a paused event does not route or grant a medal', () async {
    final participantId = await createParticipant();
    await repository.setEventActive(false);

    final result = await useCase.execute(
      participantId: participantId,
      treasureId: 'gym-android',
    );

    expect(result.failure, DiscoverFailure.eventPaused);
    expect((await repository.getParticipant(participantId))!.medals, 0);
  });
}
