import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/repositories/leaderboard_repository.dart';

class LeaderboardUseCase {
  LeaderboardUseCase(this._leaderboardRepository);

  final LeaderboardRepository _leaderboardRepository;

  Future<List<LeaderboardEntry>> execute() => _leaderboardRepository.getLeaderboard();
}