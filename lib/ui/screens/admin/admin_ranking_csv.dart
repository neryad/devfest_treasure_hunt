import '../../../domain/entities/leaderboard_entry.dart';

const _headers = [
  'position',
  'name',
  'nickname',
  'points',
  'medals',
  'total_medals',
  'status',
];

String buildAdminRankingCsv(List<LeaderboardEntry> entries) {
  final rows = [
    _headers,
    for (final entry in entries)
      [
        entry.position.toString(),
        entry.name,
        entry.nickname,
        entry.points.toString(),
        entry.discoveredCount.toString(),
        entry.totalTreasures.toString(),
        entry.status.name,
      ],
  ];

  return rows.map((row) => row.map(_escapeCsvCell).join(',')).join('\n');
}

String _escapeCsvCell(String value) {
  final escaped = value.replaceAll('"', '""');
  if (escaped.contains(',') ||
      escaped.contains('"') ||
      escaped.contains('\n')) {
    return '"$escaped"';
  }
  return escaped;
}
