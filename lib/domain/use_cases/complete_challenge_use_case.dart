import '../../core/utils/id_generator.dart';
import '../entities/attempt.dart';
import '../entities/participant.dart';
import '../entities/treasure_item.dart';
import '../repositories/attempt_repository.dart';
import '../repositories/event_repository.dart';
import '../repositories/participant_repository.dart';
import '../repositories/treasure_repository.dart';

enum ChallengeFailure {
  participantNotFound,
  gymNotFound,
  notActive,
  alreadyCompleted,
  cooldownActive,
  invalidAnswer,
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
  });

  factory ChallengeResult.success({
    required TreasureItem gym,
    required int pointsEarned,
    required int totalPoints,
    required int medals,
    bool completed = false,
  }) => ChallengeResult._(
    gym: gym,
    pointsEarned: pointsEarned,
    totalPoints: totalPoints,
    medals: medals,
    completed: completed,
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

  bool get isSuccess => failure == null;
}

class CompleteChallengeUseCase {
  CompleteChallengeUseCase({
    required TreasureRepository treasureRepository,
    required ParticipantRepository participantRepository,
    required AttemptRepository attemptRepository,
    required EventRepository eventRepository,
  }) : // Keep public constructor names without leading underscores.
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
    required String answer,
  }) async {
    // 1. Validate participant
    final participant = await _participantRepository.getParticipant(
      participantId,
    );
    if (participant == null) {
      return ChallengeResult.failure(ChallengeFailure.participantNotFound);
    }

    // 2. Check the event is not paused
    final event = await _eventRepository.getEvent();
    if (!event.active) {
      return ChallengeResult.failure(ChallengeFailure.eventPaused);
    }

    // 3. Validate gym
    final gym = await _treasureRepository.getTreasure(gymId);
    if (gym == null) {
      return ChallengeResult.failure(ChallengeFailure.gymNotFound);
    }
    if (!gym.isActive) {
      return ChallengeResult.failure(ChallengeFailure.notActive);
    }

    // 4. Check if already completed
    if (participant.discoveredTreasureIds.contains(gymId)) {
      return ChallengeResult.failure(ChallengeFailure.alreadyCompleted);
    }

    // 5. Validate answer
    final correct = _validateAnswer(gym, answer);

    // 6. Record attempt
    final attempt = Attempt(
      id: IdGenerator.discoveryId(),
      participantId: participantId,
      gymId: gymId,
      answeredAt: DateTime.now(),
      correct: correct,
      answer: answer,
    );
    await _attemptRepository.saveAttempt(attempt);

    if (!correct) {
      return ChallengeResult.failure(ChallengeFailure.invalidAnswer);
    }

    final attemptsBeforeCorrect =
        await _attemptRepository.getAttemptCount(participantId, gymId) - 1;
    final basePoints = gym.challenge?.points ?? gym.pointValue;
    final attemptBonus = switch (attemptsBeforeCorrect) {
      0 => firstAttemptBonus,
      1 => secondAttemptBonus,
      _ => 0,
    };

    // 7. Award points and mark as discovered
    final updatedTreasures = [...participant.discoveredTreasureIds, gymId];
    final newMedals = updatedTreasures.length;
    final allTreasures = await _treasureRepository.getTreasures();
    final allCompleted = newMedals >= allTreasures.length;
    final completionBonus = allCompleted ? allMedalsBonus : 0;
    final pointsEarned = basePoints + attemptBonus + completionBonus;
    final updatedParticipant = participant.copyWith(
      discoveredTreasureIds: updatedTreasures,
      points: participant.points + pointsEarned,
      medals: newMedals,
    );

    if (allCompleted) {
      await _participantRepository.updateParticipant(
        updatedParticipant.copyWith(
          status: ParticipantStatus.completed,
          completedAt: DateTime.now(),
        ),
      );
    } else {
      await _participantRepository.updateParticipant(updatedParticipant);
    }

    return ChallengeResult.success(
      gym: gym,
      pointsEarned: pointsEarned,
      totalPoints: updatedParticipant.points,
      medals: newMedals,
      completed: allCompleted,
    );
  }

  bool _validateAnswer(TreasureItem gym, String answer) {
    final challenge = gym.challenge;
    if (challenge == null) return true; // QR-only gyms auto-pass
    if (challenge.correctAnswer == null) return true;
    return answer.trim().toLowerCase() ==
        challenge.correctAnswer!.trim().toLowerCase();
  }
}
