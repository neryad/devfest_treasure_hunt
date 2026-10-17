import 'dart:convert';

import '../../domain/entities/attempt.dart';
import '../../domain/entities/discovery.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/participant.dart';
import '../../domain/entities/treasure_item.dart';

class DemoDataSeed {
  const DemoDataSeed({
    required this.event,
    required this.treasures,
    required this.participants,
    required this.discoveries,
    required this.attempts,
    required this.challengeContentVersion,
  });

  final Event event;
  final List<TreasureItem> treasures;
  final List<Participant> participants;
  final List<Discovery> discoveries;
  final List<Attempt> attempts;
  final int challengeContentVersion;

  factory DemoDataSeed.fromJson(String source) {
    final root = jsonDecode(source) as Map<String, dynamic>;
    final eventJson = root['event'] as Map<String, dynamic>;

    return DemoDataSeed(
      event: Event(
        id: eventJson['id'] as String,
        name: eventJson['name'] as String,
        description: eventJson['description'] as String,
        dateLabel: eventJson['dateLabel'] as String?,
        active: eventJson['active'] as bool? ?? true,
      ),
      treasures: _decodeList(root, 'treasures', TreasureItem.fromJson),
      participants: _decodeList(root, 'participants', Participant.fromJson),
      discoveries: _decodeList(root, 'discoveries', Discovery.fromJson),
      attempts: _decodeList(root, 'attempts', Attempt.fromJson),
      challengeContentVersion:
          eventJson['challengeContentVersion'] as int? ?? 0,
    );
  }

  static List<T> _decodeList<T>(
    Map<String, dynamic> root,
    String key,
    T Function(Map<String, dynamic>) decode,
  ) {
    final items = root[key] as List<dynamic>;
    return items
        .map((item) => decode(item as Map<String, dynamic>))
        .toList(growable: false);
  }
}
