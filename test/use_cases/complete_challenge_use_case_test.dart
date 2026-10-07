import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
import 'package:devfest_treasure_hunt/domain/entities/participant.dart';
import 'package:devfest_treasure_hunt/domain/use_cases/complete_challenge_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockLocalDataSource dataSource;
  late MockAppRepository repository;
  late CompleteChallengeUseCase useCase;

  setUp(() async {
    dataSource = MockLocalDataSource(seedData: false);
    await dataSource.initialize();
    repository = MockAppRepository(dataSource);
    useCase = CompleteChallengeUseCase(
      treasureRepository: repository,
      participantRepository: repository,
      attemptRepository: repository,
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

  test('awards base points plus first attempt bonus', () async {
    final participantId = await createParticipant();

    final result = await useCase.execute(
      participantId: participantId,
      gymId: 'gym-android',
      answer: 'AndroidManifest.xml',
    );

    expect(result.isSuccess, isTrue);
    expect(result.pointsEarned, 130);

    final participant = await repository.getParticipant(participantId);
    expect(participant!.points, 130);
    expect(participant.medals, 1);
  });

  test('awards second attempt bonus after one wrong answer', () async {
    final participantId = await createParticipant();

    final wrong = await useCase.execute(
      participantId: participantId,
      gymId: 'gym-android',
      answer: 'build.gradle',
    );
    expect(wrong.failure, ChallengeFailure.invalidAnswer);

    final correct = await useCase.execute(
      participantId: participantId,
      gymId: 'gym-android',
      answer: 'AndroidManifest.xml',
    );

    expect(correct.isSuccess, isTrue);
    expect(correct.pointsEarned, 115);
  });

  test('awards no attempt bonus after two wrong answers', () async {
    final participantId = await createParticipant();

    await useCase.execute(
      participantId: participantId,
      gymId: 'gym-android',
      answer: 'wrong one',
    );
    await useCase.execute(
      participantId: participantId,
      gymId: 'gym-android',
      answer: 'wrong two',
    );

    final correct = await useCase.execute(
      participantId: participantId,
      gymId: 'gym-android',
      answer: 'AndroidManifest.xml',
    );

    expect(correct.isSuccess, isTrue);
    expect(correct.pointsEarned, 100);
  });

  test('does not apply cooldown after wrong answer', () async {
    final participantId = await createParticipant();

    final wrong = await useCase.execute(
      participantId: participantId,
      gymId: 'gym-cloud',
      answer: 'Compute Engine',
    );
    expect(wrong.failure, ChallengeFailure.invalidAnswer);

    final correct = await useCase.execute(
      participantId: participantId,
      gymId: 'gym-cloud',
      answer: 'Firestore',
    );

    expect(correct.isSuccess, isTrue);
    expect(correct.failure, isNull);
  });

  test('adds completion bonus when eighth medal is completed', () async {
    final participantId = await createParticipant();
    final participant = await repository.getParticipant(participantId);
    await repository.updateParticipant(
      participant!.copyWith(
        discoveredTreasureIds: const [
          'gym-android',
          'gym-ia',
          'gym-security',
          'gym-web',
          'gym-startup',
          'gym-speaker',
          'gym-community',
        ],
        medals: 7,
        points: 700,
      ),
    );

    final result = await useCase.execute(
      participantId: participantId,
      gymId: 'gym-cloud',
      answer: 'Firestore',
    );

    expect(result.isSuccess, isTrue);
    expect(result.completed, isTrue);
    expect(result.pointsEarned, 230);

    final completed = await repository.getParticipant(participantId);
    expect(completed!.status, ParticipantStatus.completed);
    expect(completed.points, 930);
  });

  test('paused event blocks challenge completion', () async {
    final participantId = await createParticipant();
    await repository.setEventActive(false);

    final result = await useCase.execute(
      participantId: participantId,
      gymId: 'gym-android',
      answer: 'AndroidManifest.xml',
    );

    expect(result.failure, ChallengeFailure.eventPaused);
    final participant = await repository.getParticipant(participantId);
    expect(participant!.points, 0);
    expect(participant.medals, 0);
    final attempts = await repository.getAttemptCount(
      participantId,
      'gym-android',
    );
    expect(attempts, 0);
  });
}
