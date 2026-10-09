import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
import 'package:devfest_treasure_hunt/domain/entities/gym_challenge.dart';
import 'package:devfest_treasure_hunt/domain/entities/treasure_item.dart';
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

  Future<List<({String id, String answer})>> assignedQuestions(
    String participantId,
    String gymId,
  ) async {
    final gym = await repository.getTreasure(gymId);
    final challenge = gym!.challenge!;
    return ChallengeQuestionSelector.selectMany(
          participantId: participantId,
          gymId: gymId,
          bank: challenge.questionBank,
          count: challenge.questionsRequired,
        )
        .map((question) => (id: question.id, answer: question.correctAnswer))
        .toList();
  }

  Future<ChallengeResult> answer(
    String participantId,
    String gymId,
    ({String id, String answer}) question, {
    String? answerOverride,
  }) => useCase.execute(
    participantId: participantId,
    gymId: gymId,
    questionId: question.id,
    answer: answerOverride ?? question.answer,
  );

  test(
    'first correct answer reports progress without granting a medal',
    () async {
      final participantId = await createParticipant();
      final assigned = await assignedQuestions(participantId, 'gym-android');

      final result = await answer(participantId, 'gym-android', assigned.first);

      expect(result.isProgress, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.answeredQuestionIds, {assigned.first.id});
      expect(result.requiredQuestions, 4);
      final participant = await repository.getParticipant(participantId);
      expect(participant!.medals, 0);
      expect(participant.discoveredTreasureIds, isEmpty);
    },
  );

  test('the same assigned question cannot be answered twice', () async {
    final participantId = await createParticipant();
    final assigned = await assignedQuestions(participantId, 'gym-android');
    await answer(participantId, 'gym-android', assigned.first);

    final duplicate = await answer(
      participantId,
      'gym-android',
      assigned.first,
    );

    expect(duplicate.failure, ChallengeFailure.questionAlreadyAnswered);
    expect(await repository.getAttemptCount(participantId, 'gym-android'), 1);
  });

  test('a wrong answer does not remove prior progress', () async {
    final participantId = await createParticipant();
    final assigned = await assignedQuestions(participantId, 'gym-android');
    await answer(participantId, 'gym-android', assigned.first);

    final wrong = await answer(
      participantId,
      'gym-android',
      assigned.last,
      answerOverride: 'incorrecta',
    );
    expect(wrong.failure, ChallengeFailure.invalidAnswer);

    final continued = await answer(participantId, 'gym-android', assigned.last);
    expect(continued.isProgress, isTrue);
    expect(
      await repository.getCorrectQuestionIds(participantId, 'gym-android'),
      {assigned.first.id, assigned.last.id},
    );
    expect((await repository.getParticipant(participantId))!.medals, 0);
  });

  test('all assigned answers grant one medal', () async {
    final participantId = await createParticipant();
    final assigned = await assignedQuestions(participantId, 'gym-android');

    ChallengeResult? result;
    for (final question in assigned) {
      result = await answer(participantId, 'gym-android', question);
    }

    expect(result!.isSuccess, isTrue);
    expect(result.pointsEarned, 130);
    final participant = await repository.getParticipant(participantId);
    expect(participant!.medals, 1);
    expect(participant.discoveredTreasureIds, contains('gym-android'));
  });

  test(
    'an unassigned question id is rejected without saving an attempt',
    () async {
      final participantId = await createParticipant();

      final result = await useCase.execute(
        participantId: participantId,
        gymId: 'gym-android',
        questionId: 'not-assigned',
        answer: 'CAMERA',
      );

      expect(result.failure, ChallengeFailure.invalidQuestion);
      expect(await repository.getAttemptCount(participantId, 'gym-android'), 0);
    },
  );

  test('an empty answer is always incorrect and is recorded', () async {
    final participantId = await createParticipant();
    final assigned = await assignedQuestions(participantId, 'gym-android');

    final result = await answer(
      participantId,
      'gym-android',
      assigned.first,
      answerOverride: '   ',
    );

    expect(result.failure, ChallengeFailure.invalidAnswer);
    final attempts = await repository.getAttemptsForGym(
      participantId,
      'gym-android',
    );
    expect(attempts, hasLength(1));
    expect(attempts.single.correct, isFalse);
    expect(attempts.single.questionId, assigned.first.id);
  });

  test('speaker names accept accents, punctuation, and extra spaces', () async {
    final participantId = await createParticipant();
    final assigned = await assignedQuestions(participantId, 'gym-speaker');
    final expected = assigned.first.answer.toLowerCase();
    final vowel = RegExp(r'[aeiou]').firstMatch(expected)!;
    const accentedVowels = {'a': 'á', 'e': 'é', 'i': 'í', 'o': 'ó', 'u': 'ú'};
    final variant = expected
        .replaceRange(vowel.start, vowel.end, accentedVowels[vowel.group(0)]!)
        .replaceFirst(' ', ' ...  ');

    final result = await answer(
      participantId,
      'gym-speaker',
      assigned.first,
      answerOverride: variant,
    );

    expect(result.isProgress, isTrue);
  });

  test('a gym without a challenge is an invalid question', () async {
    final participantId = await createParticipant();
    final original = (await repository.getTreasure('gym-android'))!;
    final treasures = await dataSource.loadTreasures();
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
    await dataSource.saveTreasures([
      for (final treasure in treasures)
        if (treasure.id == original.id) replacement else treasure,
    ]);

    final result = await useCase.execute(
      participantId: participantId,
      gymId: original.id,
      questionId: 'legacy',
      answer: 'anything',
    );

    expect(result.failure, ChallengeFailure.invalidQuestion);
    expect((await repository.getParticipant(participantId))!.medals, 0);
  });

  test('a paused event changes neither attempts nor participant', () async {
    final participantId = await createParticipant();
    final assigned = await assignedQuestions(participantId, 'gym-android');
    await repository.setEventActive(false);

    final result = await answer(participantId, 'gym-android', assigned.first);

    expect(result.failure, ChallengeFailure.eventPaused);
    expect(await repository.getAttemptCount(participantId, 'gym-android'), 0);
    final participant = await repository.getParticipant(participantId);
    expect(participant!.points, 0);
    expect(participant.medals, 0);
  });

  test(
    'legacy and mini-game challenges remain single-question flows',
    () async {
      final participantId = await createParticipant();

      final startup = await useCase.execute(
        participantId: participantId,
        gymId: 'gym-startup',
        questionId: 'legacy',
        answer: 'RUNWAY-CLEARED',
      );

      expect(startup.isSuccess, isTrue);
      expect(startup.isProgress, isFalse);
    },
  );

  test('Pixel Perfect awards ten points for each hit above five', () async {
    final participantId = await createParticipant();

    final result = await useCase.execute(
      participantId: participantId,
      gymId: 'gym-web',
      questionId: 'legacy',
      answer: 'PIXEL-PERFECT',
      miniGameScore: 8,
    );

    expect(result.isSuccess, isTrue);
    expect(result.performanceBonus, 30);
    expect(result.pointsEarned, 160);
    expect((await repository.getParticipant(participantId))!.points, 160);
  });
}
