import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
import 'package:devfest_treasure_hunt/state/app_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockLocalDataSource dataSource;
  late MockAppRepository repository;
  late AppController controller;

  setUp(() async {
    dataSource = MockLocalDataSource(seedData: false);
    await dataSource.initialize();
    repository = MockAppRepository(dataSource);
    controller = AppController(
      treasureRepository: repository,
      participantRepository: repository,
      leaderboardRepository: repository,
      eventRepository: repository,
      resetStore: dataSource.reset,
      attemptRepository: repository,
      enableElapsedTicker: false,
    );
    await controller.initialize();
  });

  tearDown(() => controller.dispose());

  test('signs in admin with shared event credentials', () {
    expect(controller.adminSignedIn, isFalse);

    expect(controller.signInAdmin('admin', 'wrong'), isFalse);
    expect(controller.adminSignedIn, isFalse);

    expect(controller.signInAdmin('admin', 'devfest2026'), isTrue);
    expect(controller.adminSignedIn, isTrue);
  });

  test('staff can grant a medal and base points manually', () async {
    final participant = await repository.createParticipant(
      id: 'participant-admin-test',
      name: 'Admin Test',
      nickname: 'admin_test',
      startedAt: DateTime.now(),
    );
    await controller.initialize();

    final granted = await controller.grantMedal(
      participantId: participant.id,
      gymId: 'gym-android',
    );

    expect(granted, isTrue);
    final updated = await repository.getParticipant(participant.id);
    expect(updated!.discoveredTreasureIds, contains('gym-android'));
    expect(updated.medals, 1);
    expect(updated.points, 100);
    expect(controller.participants.single.id, participant.id);
    expect(controller.leaderboard.single.points, 100);
  });

  test('granting the same medal twice is ignored', () async {
    final participant = await repository.createParticipant(
      id: 'participant-duplicate-test',
      name: 'Duplicate Test',
      nickname: 'duplicate_test',
      startedAt: DateTime.now(),
    );
    await controller.initialize();

    expect(
      await controller.grantMedal(
        participantId: participant.id,
        gymId: 'gym-android',
      ),
      isTrue,
    );
    expect(
      await controller.grantMedal(
        participantId: participant.id,
        gymId: 'gym-android',
      ),
      isFalse,
    );

    final updated = await repository.getParticipant(participant.id);
    expect(updated!.medals, 1);
    expect(updated.points, 100);
  });

  test('staff can add points manually and refresh ranking', () async {
    final participant = await repository.createParticipant(
      id: 'participant-points-add',
      name: 'Points Add',
      nickname: 'points_add',
      startedAt: DateTime.now(),
    );
    await controller.initialize();

    final adjusted = await controller.adjustParticipantPoints(
      participantId: participant.id,
      delta: 50,
    );

    expect(adjusted, isTrue);
    final updated = await repository.getParticipant(participant.id);
    expect(updated!.points, 50);
    expect(controller.participants.single.points, 50);
    expect(controller.leaderboard.single.points, 50);
  });

  test('staff can subtract points manually', () async {
    final participant = await repository.createParticipant(
      id: 'participant-points-subtract',
      name: 'Points Subtract',
      nickname: 'points_subtract',
      startedAt: DateTime.now(),
    );
    await controller.initialize();
    await controller.adjustParticipantPoints(
      participantId: participant.id,
      delta: 80,
    );

    final adjusted = await controller.adjustParticipantPoints(
      participantId: participant.id,
      delta: -30,
    );

    expect(adjusted, isTrue);
    final updated = await repository.getParticipant(participant.id);
    expect(updated!.points, 50);
    expect(controller.leaderboard.single.points, 50);
  });

  test('manual point adjustment cannot reduce total below zero', () async {
    final participant = await repository.createParticipant(
      id: 'participant-points-clamp',
      name: 'Points Clamp',
      nickname: 'points_clamp',
      startedAt: DateTime.now(),
    );
    await controller.initialize();

    final adjusted = await controller.adjustParticipantPoints(
      participantId: participant.id,
      delta: -100,
    );

    expect(adjusted, isTrue);
    final updated = await repository.getParticipant(participant.id);
    expect(updated!.points, 0);
    expect(controller.leaderboard.single.points, 0);
  });

  test('manual point adjustment fails for missing participant', () async {
    expect(
      await controller.adjustParticipantPoints(
        participantId: 'missing-participant',
        delta: 50,
      ),
      isFalse,
    );
    expect(controller.participants, isEmpty);
    expect(controller.leaderboard, isEmpty);
  });
}
