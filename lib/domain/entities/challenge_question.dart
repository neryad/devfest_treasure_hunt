import 'package:flutter/foundation.dart';

@immutable
class ChallengeQuestion {
  const ChallengeQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.hint,
    this.codeSnippet,
  });

  final String id;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String? hint;
  final String? codeSnippet;

  ChallengeQuestion copyWith({
    String? id,
    String? question,
    List<String>? options,
    String? correctAnswer,
    String? hint,
    String? codeSnippet,
  }) {
    return ChallengeQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? List<String>.from(this.options),
      correctAnswer: correctAnswer ?? this.correctAnswer,
      hint: hint ?? this.hint,
      codeSnippet: codeSnippet ?? this.codeSnippet,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'hint': hint,
      'codeSnippet': codeSnippet,
    };
  }

  factory ChallengeQuestion.fromJson(Map<String, dynamic> json) {
    return ChallengeQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      correctAnswer: json['correctAnswer'] as String,
      hint: json['hint'] as String?,
      codeSnippet: json['codeSnippet'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChallengeQuestion &&
        other.id == id &&
        other.question == question &&
        listEquals(other.options, options) &&
        other.correctAnswer == correctAnswer &&
        other.hint == hint &&
        other.codeSnippet == codeSnippet;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      question,
      Object.hashAll(options),
      correctAnswer,
      hint,
      codeSnippet,
    );
  }
}
