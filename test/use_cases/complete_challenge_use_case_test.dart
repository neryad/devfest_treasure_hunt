import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
import 'package:devfest_treasure_hunt/domain/entities/participant.dart';
import 'package:devfest_treasure_hunt/domain/entities/gym_challenge.dart';
import 'package:devfest_treasure_hunt/domain/utils/challenge_question_selector.dart';
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

  Future<String> assignedAnswer(String participantId, String gymId) async {
    final gym = await repository.getTreasure(gymId);
    final challenge = gym!.challenge!;
    if (challenge.questionBank.isEmpty) return challenge.correctAnswer!;
    return ChallengeQuestionSelector.select(
      participantId: participantId,
      gymId: gymId,
      bank: challenge.questionBank,
    )!.correctAnswer;
  }

  test('awards base points plus first attempt bonus', () async {
    final participantId = await createParticipant();

    final result = await useCase.execute(
      participantId: participantId,
      gymId: 'gym-android',
      answer: await assignedAnswer(participantId, 'gym-android'),
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
      answer: await assignedAnswer(participantId, 'gym-android'),
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
      answer: await assignedAnswer(participantId, 'gym-android'),
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
      answer: await assignedAnswer(participantId, 'gym-cloud'),
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
      answer: await assignedAnswer(participantId, 'gym-cloud'),
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

  test('rejects an answer from another question in the same bank', () async {
    final participantId = await createParticipant();
    final gym = await repository.getTreasure('gym-android');
    final assigned = ChallengeQuestionSelector.select(
      participantId: participantId,
      gymId: gym!.id,
      bank: gym.challenge!.questionBank,
    )!;
    final other = gym.challenge!.questionBank.firstWhere(
      (question) => question.id != assigned.id,
    );

    final result = await useCase.execute(
      participantId: participantId,
      gymId: gym.id,
      answer: other.correctAnswer,
    );

    expect(result.failure, ChallengeFailure.invalidAnswer);
  });

  test('legacy single-question challenges still work', () async {
    final participantId = await createParticipant();
    final treasures = await dataSource.loadTreasures();
    final cloudIndex = treasures.indexWhere((item) => item.id == 'gym-cloud');
    treasures[cloudIndex] = treasures[cloudIndex].copyWith(
      challenge: const GymChallenge(
        type: ChallengeType.trivia,
        question: 'Legacy question',
        options: ['Legacy answer', 'Wrong'],
        correctAnswer: 'Legacy answer',
      ),
    );
    await dataSource.saveTreasures(treasures);

    final result = await useCase.execute(
      participantId: participantId,
      gymId: 'gym-cloud',
      answer: 'Legacy answer',
    );

    expect(result.isSuccess, isTrue);
  });

  test('startup and security keep their existing answers', () async {
    final participantId = await createParticipant();

    final startup = await useCase.execute(
      participantId: participantId,
      gymId: 'gym-startup',
      answer: 'RUNWAY-CLEARED',
    );
    final security = await useCase.execute(
      participantId: participantId,
      gymId: 'gym-security',
      answer: 'SECURE2026',
    );

    expect(startup.isSuccess, isTrue);
    expect(security.isSuccess, isTrue);
  });
}
