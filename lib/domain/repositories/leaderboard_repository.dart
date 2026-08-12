import '../entities/leaderboard_entry.dart';

/// Abstraction over ranking computation.
///
/// Today it is derived from mock data; on Firebase it would be computed by a
/// Cloud Function or an aggregated document so the UI contract stays the same.
abstract class LeaderboardRepository {
  Future<List<LeaderboardEntry>> getLeaderboard();
}