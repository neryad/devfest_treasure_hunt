import 'participant.dart';

/// Row of the ranking. Equal point totals share the same position.
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
    this.points = 0,
  });

  final String participantId;
  final String name;
  final String nickname;
  final int discoveredCount;
  final int totalTreasures;
  final Duration elapsed;
  final ParticipantStatus status;

  /// 1-based competition position. Tied scores reuse the same position.
  final int position;

  /// Points earned based on challenge difficulty.
  final int points;

  double get progress =>
      totalTreasures == 0 ? 0 : discoveredCount / totalTreasures;

  String get elapsedLabel =>
      '${_two(elapsed.inHours)}:${_two(elapsed.inMinutes.remainder(60))}:'
      '${_two(elapsed.inSeconds.remainder(60))}';

  static String _two(int v) => v.toString().padLeft(2, '0');
}
