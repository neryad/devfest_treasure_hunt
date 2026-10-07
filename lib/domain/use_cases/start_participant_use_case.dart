import '../../core/utils/id_generator.dart';
import '../../domain/entities/participant.dart';
import '../../domain/repositories/participant_repository.dart';

class StartParticipantUseCase {
  StartParticipantUseCase(this._participantRepository);

  final ParticipantRepository _participantRepository;

  Future<Participant> execute({
    required String name,
    required String nickname,
  }) async {
    final normalized = nickname.trim().toLowerCase();
    final participants = await _participantRepository.getParticipants();
    Participant? existing;
    for (final p in participants) {
      if (p.nickname.trim().toLowerCase() == normalized) {
        existing = p;
        break;
      }
    }

    final participant =
        existing ??
        await _participantRepository.createParticipant(
          id: IdGenerator.participantId(),
          name: name.trim(),
          nickname: nickname.trim(),
          startedAt: DateTime.now(),
        );
    await _participantRepository.setCurrentParticipantId(participant.id);
    return participant;
  }
}
