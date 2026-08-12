import 'dart:convert';

enum ParticipantStatus { active, completed }

class Participant {
  const Participant({
    required this.id,
    required this.name,
    required this.nickname,
    required this.startedAt,
    this.completedAt,
    this.status = ParticipantStatus.active,
    this.discoveredTreasureIds = const [],
  });

  final String id;
  final String name;
  final String nickname;
  final DateTime startedAt;
  final DateTime? completedAt;
  final ParticipantStatus status;

  /// Ids of the treasures already found, in discovery order.
  final List<String> discoveredTreasureIds;

  int get discoveredCount => discoveredTreasureIds.length;

  bool get isCompleted => status == ParticipantStatus.completed;

  Participant copyWith({
    List<String>? discoveredTreasureIds,
    ParticipantStatus? status,
    DateTime? completedAt,
  }) =>
      Participant(
        id: id,
        name: name,
        nickname: nickname,
        startedAt: startedAt,
        completedAt: completedAt ?? this.completedAt,
        status: status ?? this.status,
        discoveredTreasureIds:
            discoveredTreasureIds ?? this.discoveredTreasureIds,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nickname': nickname,
        'startedAt': startedAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'status': status.name,
        'discoveredTreasureIds': discoveredTreasureIds,
      };

  factory Participant.fromJson(Map<String, dynamic> json) => Participant(
        id: json['id'] as String,
        name: json['name'] as String,
        nickname: json['nickname'] as String,
        startedAt: DateTime.parse(json['startedAt'] as String),
        completedAt: json['completedAt'] != null
            ? DateTime.tryParse(json['completedAt'] as String)
            : null,
        status: ParticipantStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => ParticipantStatus.active,
        ),
        discoveredTreasureIds: (json['discoveredTreasureIds'] as List? ?? const [])
            .map((e) => e as String)
            .toList(),
      );

  static List<Participant> listFromJson(String json) => (jsonDecode(json) as List)
      .map((e) => Participant.fromJson(e as Map<String, dynamic>))
      .toList();

  static String listToJson(List<Participant> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());
}