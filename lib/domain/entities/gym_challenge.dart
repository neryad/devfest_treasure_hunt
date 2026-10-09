import 'package:flutter/foundation.dart';

import 'challenge_question.dart';

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
    this.questionBank = const [],
    this.questionsRequired = 1,
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
  final List<ChallengeQuestion> questionBank;
  final int questionsRequired;

  bool get hasTimer =>
      type == ChallengeType.trivia || type == ChallengeType.code;
  bool get requiresInput =>
      type == ChallengeType.riddle || type == ChallengeType.social;
  bool get hasOptions => options != null && options!.isNotEmpty;
  bool get isMiniGame => type == ChallengeType.miniGame;

  GymChallenge copyWith({
    ChallengeType? type,
    String? question,
    List<String>? options,
    String? correctAnswer,
    String? hint,
    String? codeSnippet,
    int? timeLimitSeconds,
    int? points,
    int? targetScore,
    List<ChallengeQuestion>? questionBank,
    int? questionsRequired,
  }) {
    return GymChallenge(
      type: type ?? this.type,
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      hint: hint ?? this.hint,
      codeSnippet: codeSnippet ?? this.codeSnippet,
      timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
      points: points ?? this.points,
      targetScore: targetScore ?? this.targetScore,
      questionBank:
          questionBank ?? List<ChallengeQuestion>.from(this.questionBank),
      questionsRequired: questionsRequired ?? this.questionsRequired,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'hint': hint,
      'codeSnippet': codeSnippet,
      'timeLimitSeconds': timeLimitSeconds,
      'points': points,
      'targetScore': targetScore,
      'questionBank': questionBank.map((q) => q.toJson()).toList(),
      'questionsRequired': questionsRequired,
    };
  }

  factory GymChallenge.fromJson(Map<String, dynamic> json) {
    final bankJson = json['questionBank'] as List<dynamic>?;
    final questionBank = bankJson != null
        ? bankJson
              .map((e) => ChallengeQuestion.fromJson(e as Map<String, dynamic>))
              .toList()
        : <ChallengeQuestion>[];
    final requested = (json['questionsRequired'] as num?)?.toInt() ?? 1;
    final questionsRequired = questionBank.isNotEmpty
        ? requested.clamp(0, questionBank.length)
        : requested;
    return GymChallenge(
      type: ChallengeType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ChallengeType.trivia,
      ),
      question: json['question'] as String?,
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      correctAnswer: json['correctAnswer'] as String?,
      hint: json['hint'] as String?,
      codeSnippet: json['codeSnippet'] as String?,
      timeLimitSeconds: json['timeLimitSeconds'] as int? ?? 60,
      points: json['points'] as int? ?? 100,
      targetScore: json['targetScore'] as int?,
      questionBank: questionBank,
      questionsRequired: questionsRequired,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GymChallenge &&
        other.type == type &&
        other.question == question &&
        listEquals(other.options, options) &&
        other.correctAnswer == correctAnswer &&
        other.hint == hint &&
        other.codeSnippet == codeSnippet &&
        other.timeLimitSeconds == timeLimitSeconds &&
        other.points == points &&
        other.targetScore == targetScore &&
        other.questionsRequired == questionsRequired &&
        listEquals(other.questionBank, questionBank);
  }

  @override
  int get hashCode {
    return Object.hash(
      type,
      question,
      Object.hashAll(options ?? []),
      correctAnswer,
      hint,
      codeSnippet,
      timeLimitSeconds,
      points,
      targetScore,
      questionsRequired,
      Object.hashAll(questionBank),
    );
  }
}
