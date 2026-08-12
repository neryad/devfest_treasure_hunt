import 'dart:convert';

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

  TreasureItem copyWith({bool? isActive}) =>
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
      );

  static List<TreasureItem> listFromJson(String json) => (jsonDecode(json) as List)
      .map((e) => TreasureItem.fromJson(e as Map<String, dynamic>))
      .toList();

  static String listToJson(List<TreasureItem> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());
}