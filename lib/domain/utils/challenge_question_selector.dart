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
}
