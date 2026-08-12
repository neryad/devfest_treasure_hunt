import 'participant.dart';

/// Row of the ranking. Sorted by discovered count (desc) then time (asc).
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.participantId,
    required this.name,
    required this.nickname,
    required this.discoveredCount,
    required this.totalTreasures,
    required this.elapsed,
    required this.status,
    this.position = 0,
  });

  final String participantId;
  final String name;
  final String nickname;
  final int discoveredCount;
  final int totalTreasures;
  final Duration elapsed;
  final ParticipantStatus status;

  /// 1-based position after sorting.
  final int position;

  double get progress =>
      totalTreasures == 0 ? 0 : discoveredCount / totalTreasures;

  String get elapsedLabel =>
      '${_two(elapsed.inHours)}:${_two(elapsed.inMinutes.remainder(60))}:'
      '${_two(elapsed.inSeconds.remainder(60))}';

  static String _two(int v) => v.toString().padLeft(2, '0');
}