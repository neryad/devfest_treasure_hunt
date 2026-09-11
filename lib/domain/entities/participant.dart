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
    this.points = 0,
    this.medals = 0,
    this.avatarEmoji,
  });

  final String id;
  final String name;
  final String nickname;
  final DateTime startedAt;
  final DateTime? completedAt;
  final ParticipantStatus status;

  /// Ids of the treasures already found, in discovery order.
  final List<String> discoveredTreasureIds;
  final int points;
  final int medals;
  final String? avatarEmoji;

  int get discoveredCount => discoveredTreasureIds.length;

  bool get isCompleted => status == ParticipantStatus.completed;

  String get level {
    if (medals >= 8) return 'DevFest Master';
    if (medals >= 7) return 'Lead Engineer';
    if (medals >= 5) return 'Senior Dev';
    if (medals >= 3) return 'Developer';
    return 'Aprendiz Tech';
  }

  Participant copyWith({
    List<String>? discoveredTreasureIds,
    ParticipantStatus? status,
    DateTime? completedAt,
    int? points,
    int? medals,
    String? avatarEmoji,
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
        points: points ?? this.points,
        medals: medals ?? this.medals,
        avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nickname': nickname,
        'startedAt': startedAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'status': status.name,
        'discoveredTreasureIds': discoveredTreasureIds,
        'points': points,
        'medals': medals,
        'avatarEmoji': avatarEmoji,
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
        points: json['points'] as int? ?? 0,
        medals: json['medals'] as int? ?? 0,
        avatarEmoji: json['avatarEmoji'] as String?,
      );

  static List<Participant> listFromJson(String json) => (jsonDecode(json) as List)
      .map((e) => Participant.fromJson(e as Map<String, dynamic>))
      .toList();

  static String listToJson(List<Participant> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());
}