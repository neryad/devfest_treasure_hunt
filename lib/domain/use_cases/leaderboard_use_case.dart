import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/entities/participant.dart';
import '../../domain/repositories/leaderboard_repository.dart';

class LeaderboardUseCase {
  LeaderboardUseCase(this._leaderboardRepository);

  final LeaderboardRepository _leaderboardRepository;

  Future<List<LeaderboardEntry>> execute({
    required List<Participant> participants,
    required int totalTreasures,
  }) => _leaderboardRepository.getLeaderboard(
    participants: participants,
    totalTreasures: totalTreasures,
  );
}
