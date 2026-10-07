import 'dart:convert';

import 'package:flutter/foundation.dart';

/// A single successful discovery of a treasure by a participant.
///
/// Future Firebase shape: `participants/{id}/discoveries/{treasureId}`.
class Discovery {
  const Discovery({
    required this.id,
    required this.participantId,
    required this.treasureId,
    required this.discoveredAt,
  });

  final String id;
  final String participantId;
  final String treasureId;
  final DateTime discoveredAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'participantId': participantId,
        'treasureId': treasureId,
        'discoveredAt': discoveredAt.toIso8601String(),
      };

  factory Discovery.fromJson(Map<String, dynamic> json) => Discovery(
        id: json['id'] as String,
        participantId: json['participantId'] as String,
        treasureId: json['treasureId'] as String,
        discoveredAt: DateTime.parse(json['discoveredAt'] as String),
      );

  static Discovery? tryFromJson(Map<String, dynamic> json) {
    try {
      return Discovery.fromJson(json);
    } catch (_) {
      debugPrint('Skipping malformed discovery doc: ${json['id']}');
      return null;
    }
  }

  static List<Discovery> listFromJson(String json) => (jsonDecode(json) as List)
      .map((e) => Discovery.tryFromJson(e as Map<String, dynamic>))
      .whereType<Discovery>()
      .toList();

  static String listToJson(List<Discovery> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());
}