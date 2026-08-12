import 'dart:convert';

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

  static List<Discovery> listFromJson(String json) => (jsonDecode(json) as List)
      .map((e) => Discovery.fromJson(e as Map<String, dynamic>))
      .toList();

  static String listToJson(List<Discovery> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());
}