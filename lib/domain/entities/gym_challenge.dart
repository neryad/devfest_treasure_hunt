enum ChallengeType {
  qr,          // Simple QR scan (no challenge screen)
  trivia,      // Multiple choice question, 60s timer
  riddle,      // Text riddle, answer is a code
  code,        // Code snippet question, multiple choice
  completion,  // Real-world action, admin verifies
  social,      // Social interaction required
}

class GymChallenge {
  const GymChallenge({
    required this.type,
    this.question,
    this.options,
    this.correctAnswer,
    this.hint,
    this.codeSnippet,
    this.timeLimitSeconds = 60,
    this.points = 10,
  });

  final ChallengeType type;
  final String? question;
  final List<String>? options;
  final String? correctAnswer;
  final String? hint;
  final String? codeSnippet;
  final int timeLimitSeconds;
  final int points;

  bool get hasTimer => type == ChallengeType.trivia || type == ChallengeType.code;
  bool get requiresInput => type == ChallengeType.riddle;
  bool get hasOptions => options != null && options!.isNotEmpty;
}