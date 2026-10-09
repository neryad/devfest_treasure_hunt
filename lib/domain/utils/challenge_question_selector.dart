import '../../core/utils/stable_hash.dart';
import '../entities/challenge_question.dart';

class ChallengeQuestionSelector {
  static ChallengeQuestion? select({
    required String participantId,
    required String gymId,
    required List<ChallengeQuestion> bank,
  }) {
    if (bank.isEmpty) return null;
    final hash = stableHash('$participantId:$gymId');
    final index = ((hash % bank.length) + bank.length) % bank.length;
    return bank[index];
  }

  static List<ChallengeQuestion> selectMany({
    required String participantId,
    required String gymId,
    required List<ChallengeQuestion> bank,
    required int count,
  }) {
    if (bank.isEmpty || count <= 0) return const [];
    final sorted = List<ChallengeQuestion>.of(bank)
      ..sort((a, b) {
        final aHash = stableHash('$participantId:$gymId:${a.id}');
        final bHash = stableHash('$participantId:$gymId:${b.id}');
        final byHash = aHash.compareTo(bHash);
        return byHash != 0 ? byHash : a.id.compareTo(b.id);
      });
    return sorted.take(count.clamp(0, sorted.length)).toList(growable: false);
  }
}
