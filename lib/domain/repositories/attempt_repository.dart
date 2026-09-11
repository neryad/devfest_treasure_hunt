import '../entities/attempt.dart';

abstract class AttemptRepository {
  Future<List<Attempt>> getAttempts(String participantId);
  Future<List<Attempt>> getAttemptsForGym(String participantId, String gymId);
  Future<void> saveAttempt(Attempt attempt);
  Future<int> getAttemptCount(String participantId, String gymId);
  Future<Attempt?> getLastAttempt(String participantId, String gymId);
}