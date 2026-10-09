import 'dart:convert';

import 'package:flutter/foundation.dart';

class Attempt {
  const Attempt({
    required this.id,
    required this.participantId,
    required this.gymId,
    required this.answeredAt,
    required this.correct,
    this.answer,
    this.questionId,
  });

  final String id;
  final String participantId;
  final String gymId;
  final DateTime answeredAt;
  final bool correct;
  final String? answer;
  final String? questionId;

  Map<String, dynamic> toJson() => {
    'id': id,
    'participantId': participantId,
    'gymId': gymId,
    'answeredAt': answeredAt.toIso8601String(),
    'correct': correct,
    'answer': answer,
    'questionId': questionId,
  };

  factory Attempt.fromJson(Map<String, dynamic> json) => Attempt(
    id: json['id'] as String,
    participantId: json['participantId'] as String,
    gymId: json['gymId'] as String,
    answeredAt: DateTime.parse(json['answeredAt'] as String),
    correct: json['correct'] as bool,
    answer: json['answer'] as String?,
    questionId: json['questionId'] as String?,
  );

  static Attempt? tryFromJson(Map<String, dynamic> json) {
    try {
      return Attempt.fromJson(json);
    } catch (_) {
      debugPrint('Skipping malformed attempt doc: ${json['id']}');
      return null;
    }
  }

  static List<Attempt> listFromJson(String json) => (jsonDecode(json) as List)
      .map((e) => Attempt.tryFromJson(e as Map<String, dynamic>))
      .whereType<Attempt>()
      .toList();

  static String listToJson(List<Attempt> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());
}
