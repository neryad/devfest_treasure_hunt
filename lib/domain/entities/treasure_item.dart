import 'dart:convert';

import 'gym_challenge.dart';

/// Visual state of a treasure from the participant's point of view.
///
/// - [TreasureStatus.locked]: the treasure exists but is not relevant yet
///   (reserved for future event phases). Not enforced as an ordering rule.
/// - [TreasureStatus.available]: can be discovered right now.
/// - [TreasureStatus.discovered]: already found by the participant.
/// - [TreasureStatus.disabled]: `isActive == false`, cannot be discovered.
enum TreasureStatus { locked, available, discovered, disabled }

class TreasureItem {
  const TreasureItem({
    required this.id,
    required this.title,
    required this.description,
    required this.code,
    required this.qrValue,
    required this.clue,
    required this.locationDescription,
    required this.iconKey,
    this.order = 0,
    this.isActive = true,
    this.createdAt,
    this.challengeType = ChallengeType.qr,
    this.challenge,
    this.gymName,
    this.track,
    this.pointValue = 10,
  });

  final String id;

  /// Human friendly title, e.g. "Tesoro #03 · Main Stage".
  final String title;

  final String description;

  /// Manual code a participant can type, e.g. "DEVFEST-042".
  final String code;

  /// Value encoded in the physical QR, e.g. "DEVFEST-TREASURE-001".
  final String qrValue;

  /// Hint unlocked once this treasure is discovered. Guidance, not order.
  final String clue;

  /// Where the physical treasure lives in the venue.
  final String locationDescription;

  /// Key used by the UI to pick an icon (keeps the domain Flutter-free).
  final String iconKey;

  /// Only used to organise items in the admin dashboard. Never enforced
  /// as a discovery requirement.
  final int order;

  /// Controls availability. The single real unlock rule of the demo.
  final bool isActive;

  final DateTime? createdAt;

  /// Type of challenge this gym presents.
  final ChallengeType challengeType;

  /// The actual challenge data (question, options, answer, etc.).
  final GymChallenge? challenge;

  /// Display name for the gym.
  final String? gymName;

  /// Track/theme this gym belongs to.
  final String? track;

  /// Base points for completing this gym.
  final int pointValue;

  TreasureItem copyWith({
    bool? isActive,
    ChallengeType? challengeType,
    GymChallenge? challenge,
    String? gymName,
    String? track,
    int? pointValue,
  }) =>
      TreasureItem(
        id: id,
        title: title,
        description: description,
        code: code,
        qrValue: qrValue,
        clue: clue,
        locationDescription: locationDescription,
        iconKey: iconKey,
        order: order,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt,
        challengeType: challengeType ?? this.challengeType,
        challenge: challenge ?? this.challenge,
        gymName: gymName ?? this.gymName,
        track: track ?? this.track,
        pointValue: pointValue ?? this.pointValue,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'code': code,
        'qrValue': qrValue,
        'clue': clue,
        'locationDescription': locationDescription,
        'iconKey': iconKey,
        'order': order,
        'isActive': isActive,
        'createdAt': createdAt?.toIso8601String(),
        'challengeType': challengeType.name,
        'challenge': challenge != null
            ? {
                'type': challenge!.type.name,
                'question': challenge!.question,
                'options': challenge!.options,
                'correctAnswer': challenge!.correctAnswer,
                'hint': challenge!.hint,
                'codeSnippet': challenge!.codeSnippet,
                'timeLimitSeconds': challenge!.timeLimitSeconds,
                'points': challenge!.points,
              }
            : null,
        'gymName': gymName,
        'track': track,
        'pointValue': pointValue,
      };

  factory TreasureItem.fromJson(Map<String, dynamic> json) => TreasureItem(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        code: json['code'] as String,
        qrValue: json['qrValue'] as String,
        clue: json['clue'] as String,
        locationDescription: json['locationDescription'] as String,
        iconKey: json['iconKey'] as String,
        order: json['order'] as int? ?? 0,
        isActive: json['isActive'] as bool? ?? true,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
        challengeType: ChallengeType.values.firstWhere(
          (e) => e.name == json['challengeType'],
          orElse: () => ChallengeType.qr,
        ),
        challenge: json['challenge'] != null
            ? GymChallenge(
                type: ChallengeType.values.firstWhere(
                  (e) => e.name == json['challenge']['type'],
                  orElse: () => ChallengeType.qr,
                ),
                question: json['challenge']['question'] as String?,
                options: (json['challenge']['options'] as List<dynamic>?)
                    ?.map((e) => e as String)
                    .toList(),
                correctAnswer: json['challenge']['correctAnswer'] as String?,
                hint: json['challenge']['hint'] as String?,
                codeSnippet: json['challenge']['codeSnippet'] as String?,
                timeLimitSeconds:
                    json['challenge']['timeLimitSeconds'] as int? ?? 60,
                points: json['challenge']['points'] as int? ?? 10,
              )
            : null,
        gymName: json['gymName'] as String?,
        track: json['track'] as String?,
        pointValue: json['pointValue'] as int? ?? 10,
      );

  static List<TreasureItem> listFromJson(String json) => (jsonDecode(json) as List)
      .map((e) => TreasureItem.fromJson(e as Map<String, dynamic>))
      .toList();

  static String listToJson(List<TreasureItem> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());
}