class FinalistResult {
  const FinalistResult({
    required this.participantId,
    required this.name,
    required this.nickname,
    required this.points,
    required this.completedAt,
    required this.elapsed,
    required this.position,
  });

  final String participantId;
  final String name;
  final String nickname;
  final int points;
  final DateTime completedAt;
  final Duration elapsed;

  /// Official provisional position: points first, completion time second.
  final int position;
}
