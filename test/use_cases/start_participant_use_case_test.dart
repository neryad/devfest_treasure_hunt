import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
import 'package:devfest_treasure_hunt/domain/use_cases/start_participant_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockLocalDataSource dataSource;
  late MockAppRepository repository;
  late StartParticipantUseCase useCase;
  late int seedCount;

  setUp(() async {
    dataSource = MockLocalDataSource();
    await dataSource.initialize();
    repository = MockAppRepository(dataSource);
    useCase = StartParticipantUseCase(repository);
    seedCount = (await repository.getParticipants()).length;
  });

  test(
    'registering with an existing nickname returns that participant',
    () async {
      final existing = await repository.createParticipant(
        id: 'participant-existing',
        name: 'papotico',
        nickname: 'test',
        startedAt: DateTime.utc(2026, 10, 7, 17, 45),
      );
      await repository.updateParticipant(
        existing.copyWith(points: 100, discoveredTreasureIds: ['gym-android']),
      );
      final beforeCount = (await repository.getParticipants()).length;

      final result = await useCase.execute(name: 'papotico', nickname: 'test');

      expect(result.id, 'participant-existing');
      expect(result.points, 100);
      expect(result.discoveredTreasureIds, ['gym-android']);

      final participants = await repository.getParticipants();
      expect(participants, hasLength(beforeCount));

      final currentId = await repository.getCurrentParticipantId();
      expect(currentId, 'participant-existing');
    },
  );

  test('nickname lookup is trimmed and case-insensitive', () async {
    await repository.createParticipant(
      id: 'participant-existing',
      name: 'Laura',
      nickname: 'laura_dev',
      startedAt: DateTime.now(),
    );
    final beforeCount = (await repository.getParticipants()).length;

    final result = await useCase.execute(
      name: 'Laura G.',
      nickname: '  Laura_Dev ',
    );

    expect(result.id, 'participant-existing');

    final participants = await repository.getParticipants();
    expect(participants, hasLength(beforeCount));
  });

  test('a brand new nickname still creates a participant', () async {
    final result = await useCase.execute(name: 'Nery', nickname: 'nery');

    expect(result.id, isNotEmpty);
    expect(result.points, 0);

    final participants = await repository.getParticipants();
    expect(participants, hasLength(seedCount + 1));
  });
}
