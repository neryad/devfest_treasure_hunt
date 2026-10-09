import 'dart:math' as math;

import '../../core/utils/id_generator.dart';
import '../entities/attempt.dart';
import '../entities/challenge_question.dart';
import '../entities/participant.dart';
import '../entities/treasure_item.dart';
import '../repositories/attempt_repository.dart';
import '../repositories/event_repository.dart';
import '../repositories/participant_repository.dart';
import '../repositories/treasure_repository.dart';
import '../utils/challenge_question_selector.dart';

enum ChallengeFailure {
  participantNotFound,
  gymNotFound,
  notActive,
  alreadyCompleted,
  cooldownActive,
  invalidAnswer,
  invalidQuestion,
  questionAlreadyAnswered,
  eventPaused,
}

class ChallengeResult {
  const ChallengeResult._({
    this.failure,
    this.gym,
    this.pointsEarned,
    this.totalPoints,
    this.medals,
    this.completed = false,
    this.cooldownRemaining,
    this.pending = false,
    this.answeredQuestionIds = const {},
    this.requiredQuestions = 0,
    this.performanceBonus = 0,
  });

  factory ChallengeResult.success({
    required TreasureItem gym,
    required int pointsEarned,
    required int totalPoints,
    required int medals,
    int performanceBonus = 0,
    bool completed = false,
  }) => ChallengeResult._(
    gym: gym,
    pointsEarned: pointsEarned,
    totalPoints: totalPoints,
    medals: medals,
    performanceBonus: performanceBonus,
    completed: completed,
  );

  factory ChallengeResult.progress({
    required TreasureItem gym,
    required Set<String> answeredQuestionIds,
    required int requiredQuestions,
  }) => ChallengeResult._(
    gym: gym,
    pending: true,
    answeredQuestionIds: Set.unmodifiable(answeredQuestionIds),
    requiredQuestions: requiredQuestions,
  );

  factory ChallengeResult.failure(
    ChallengeFailure failure, {
    Duration? cooldownRemaining,
  }) =>
      ChallengeResult._(failure: failure, cooldownRemaining: cooldownRemaining);

  final ChallengeFailure? failure;
  final TreasureItem? gym;
  final int? pointsEarned;
  final int? totalPoints;
  final int? medals;
  final bool completed;
  final Duration? cooldownRemaining;
  final bool pending;
  final Set<String> answeredQuestionIds;
  final int requiredQuestions;
  final int performanceBonus;

  bool get isProgress => failure == null && pending;
  bool get isSuccess => failure == null && !pending;
}

class CompleteChallengeUseCase {
  CompleteChallengeUseCase({
    required TreasureRepository treasureRepository,
    required ParticipantRepository participantRepository,
    required AttemptRepository attemptRepository,
    required EventRepository eventRepository,
  }) : // Keep public dependency names stable for existing composition/tests.
       // ignore: prefer_initializing_formals
       _treasureRepository = treasureRepository,
       // ignore: prefer_initializing_formals
       _participantRepository = participantRepository,
       // ignore: prefer_initializing_formals
       _attemptRepository = attemptRepository,
       // ignore: prefer_initializing_formals
       _eventRepository = eventRepository;

  final TreasureRepository _treasureRepository;
  final ParticipantRepository _participantRepository;
  final AttemptRepository _attemptRepository;
  final EventRepository _eventRepository;

  static const baseCompletionPoints = 100;
  static const firstAttemptBonus = 30;
  static const secondAttemptBonus = 15;
  static const allMedalsBonus = 100;

  Future<ChallengeResult> execute({
    required String participantId,
    required String gymId,
    required String questionId,
    required String answer,
    int? miniGameScore,
  }) async {
    final participant = await _participantRepository.getParticipant(
      participantId,
    );
    if (participant == null) {
      return ChallengeResult.failure(ChallengeFailure.participantNotFound);
    }

    final event = await _eventRepository.getEvent();
    if (!event.active) {
      return ChallengeResult.failure(ChallengeFailure.eventPaused);
    }

    final gym = await _treasureRepository.getTreasure(gymId);
    if (gym == null) {
      return ChallengeResult.failure(ChallengeFailure.gymNotFound);
    }
    if (!gym.isActive) {
      return ChallengeResult.failure(ChallengeFailure.notActive);
    }
    if (participant.discoveredTreasureIds.contains(gymId)) {
      return ChallengeResult.failure(ChallengeFailure.alreadyCompleted);
    }

    final assigned = _selectAssignedQuestions(participantId, gym);
    if (assigned.isEmpty) {
      return ChallengeResult.failure(ChallengeFailure.invalidQuestion);
    }
    final requiredQuestions = _requiredQuestionCount(gym, assigned.length);
    if (requiredQuestions <= 0) {
      return ChallengeResult.failure(ChallengeFailure.invalidQuestion);
    }
    ChallengeQuestion? question;
    for (final candidate in assigned) {
      if (candidate.id == questionId) {
        question = candidate;
        break;
      }
    }
    if (question == null) {
      return ChallengeResult.failure(ChallengeFailure.invalidQuestion);
    }

    final storedAnswered = await _attemptRepository.getCorrectQuestionIds(
      participantId,
      gymId,
    );
    final assignedIds = assigned.map((item) => item.id).toSet();
    final previouslyAnswered = storedAnswered.intersection(assignedIds);
    if (previouslyAnswered.contains(questionId)) {
      return ChallengeResult.failure(ChallengeFailure.questionAlreadyAnswered);
    }

    final normalizedAnswer = _normalizeAnswer(gym, answer);
    final normalizedCorrectAnswer = _normalizeAnswer(
      gym,
      question.correctAnswer,
    );
    final correct =
        normalizedAnswer.isNotEmpty &&
        normalizedCorrectAnswer.isNotEmpty &&
        normalizedAnswer == normalizedCorrectAnswer;

    await _attemptRepository.saveAttempt(
      Attempt(
        id: IdGenerator.discoveryId(),
        participantId: participantId,
        gymId: gymId,
        answeredAt: DateTime.now(),
        correct: correct,
        answer: answer,
        questionId: questionId,
      ),
    );

    if (!correct) {
      return ChallengeResult.failure(ChallengeFailure.invalidAnswer);
    }

    final answeredIds = {...previouslyAnswered, questionId};
    if (answeredIds.length < requiredQuestions) {
      return ChallengeResult.progress(
        gym: gym,
        answeredQuestionIds: answeredIds,
        requiredQuestions: requiredQuestions,
      );
    }

    final totalAttempts = await _attemptRepository.getAttemptCount(
      participantId,
      gymId,
    );
    final wrongAttempts = math.max(0, totalAttempts - requiredQuestions);
    final attemptBonus = switch (wrongAttempts) {
      0 => firstAttemptBonus,
      1 => secondAttemptBonus,
      _ => 0,
    };
    final basePoints = gym.challenge?.points ?? gym.pointValue;

    final updatedTreasures = {...participant.discoveredTreasureIds, gymId};
    final newMedals = updatedTreasures.length;
    final allTreasures = await _treasureRepository.getTreasures();
    final allCompleted = newMedals >= allTreasures.length;
    final completionBonus = allCompleted ? allMedalsBonus : 0;
    final performanceBonus = _performanceBonus(gym, miniGameScore);
    final pointsEarned =
        basePoints + attemptBonus + completionBonus + performanceBonus;
    final updatedParticipant = participant.copyWith(
      discoveredTreasureIds: updatedTreasures.toList(growable: false),
      points: participant.points + pointsEarned,
      medals: newMedals,
      status: allCompleted ? ParticipantStatus.completed : participant.status,
      completedAt: allCompleted ? DateTime.now() : participant.completedAt,
    );
    await _participantRepository.updateParticipant(updatedParticipant);

    return ChallengeResult.success(
      gym: gym,
      pointsEarned: pointsEarned,
      totalPoints: updatedParticipant.points,
      medals: newMedals,
      performanceBonus: performanceBonus,
      completed: allCompleted,
    );
  }

  int _performanceBonus(TreasureItem gym, int? miniGameScore) {
    if (gym.id != 'gym-web' || miniGameScore == null) return 0;
    final correctAnswers = miniGameScore.clamp(0, 10);
    return math.max(0, correctAnswers - 5) * 10;
  }

  String _normalizeAnswer(TreasureItem gym, String value) {
    var normalized = value.trim().toLowerCase();
    if (gym.id == 'gym-speaker') {
      normalized = _removeSpanishDiacritics(normalized)
          .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
    }
    return normalized;
  }

  String _removeSpanishDiacritics(String value) {
    const accented = 'áàäâéèëêíìïîóòöôúùüûñç';
    const plain = 'aaaaeeeeiiiioooouuuunc';
    var result = value;
    for (var index = 0; index < accented.length; index++) {
      result = result.replaceAll(accented[index], plain[index]);
    }
    return result;
  }

  List<ChallengeQuestion> _selectAssignedQuestions(
    String participantId,
    TreasureItem gym,
  ) {
    final challenge = gym.challenge;
    if (challenge == null) return const [];
    if (challenge.questionBank.isNotEmpty) {
      return ChallengeQuestionSelector.selectMany(
        participantId: participantId,
        gymId: gym.id,
        bank: challenge.questionBank,
        count: challenge.questionBank.length,
      );
    }
    final correctAnswer = challenge.correctAnswer;
    if (correctAnswer == null || correctAnswer.trim().isEmpty) return const [];
    return [
      ChallengeQuestion(
        id: 'legacy',
        question: challenge.question ?? '',
        options: challenge.options ?? const [],
        correctAnswer: correctAnswer,
        hint: challenge.hint,
        codeSnippet: challenge.codeSnippet,
      ),
    ];
  }

  int _requiredQuestionCount(TreasureItem gym, int availableQuestions) {
    final requested = gym.challenge?.questionsRequired ?? 1;
    return math.min(requested, availableQuestions);
  }
}
