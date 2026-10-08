import 'package:devfest_treasure_hunt/domain/entities/leaderboard_entry.dart';
import 'package:devfest_treasure_hunt/domain/entities/participant.dart';
import 'package:devfest_treasure_hunt/ui/screens/admin/admin_ranking_csv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds ranking csv with headers and rows', () {
    final csv = buildAdminRankingCsv([
      const LeaderboardEntry(
        participantId: 'participant-1',
        name: 'Ada Lovelace',
        nickname: 'ada',
        discoveredCount: 8,
        totalTreasures: 8,
        elapsed: Duration(minutes: 42, seconds: 5),
        status: ParticipantStatus.completed,
        position: 1,
        points: 930,
      ),
    ]);

    expect(
      csv,
      'position,name,nickname,points,medals,total_medals,elapsed,status\n'
      '1,Ada Lovelace,ada,930,8,8,00:42:05,completed',
    );
  });

  test('escapes csv cells that contain commas quotes or line breaks', () {
    final csv = buildAdminRankingCsv([
      const LeaderboardEntry(
        participantId: 'participant-2',
        name: 'Grace, "Bug" Hopper',
        nickname: 'line\nbreak',
        discoveredCount: 3,
        totalTreasures: 8,
        elapsed: Duration(seconds: 7),
        status: ParticipantStatus.active,
        position: 2,
        points: 300,
      ),
    ]);

    expect(
      csv,
      'position,name,nickname,points,medals,total_medals,elapsed,status\n'
      '2,"Grace, ""Bug"" Hopper","line\nbreak",300,3,8,00:00:07,active',
    );
  });

  test('empty ranking csv contains only headers', () {
    expect(
      buildAdminRankingCsv(const []),
      'position,name,nickname,points,medals,total_medals,elapsed,status',
    );
  });
}
