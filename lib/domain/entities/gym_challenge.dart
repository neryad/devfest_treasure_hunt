enum ChallengeType { qr, trivia, riddle, code, completion, social, miniGame }

class GymChallenge {
  const GymChallenge({
    required this.type,
    this.question,
    this.options,
    this.correctAnswer,
    this.hint,
    this.codeSnippet,
    this.timeLimitSeconds = 60,
    this.points = 100,
    this.targetScore,
  });

  final ChallengeType type;
  final String? question;
  final List<String>? options;
  final String? correctAnswer;
  final String? hint;
  final String? codeSnippet;
  final int timeLimitSeconds;
  final int points;
  final int? targetScore;

  bool get hasTimer =>
      type == ChallengeType.trivia || type == ChallengeType.code;
  bool get requiresInput =>
      type == ChallengeType.riddle || type == ChallengeType.social;
  bool get hasOptions => options != null && options!.isNotEmpty;
  bool get isMiniGame => type == ChallengeType.miniGame;
}
