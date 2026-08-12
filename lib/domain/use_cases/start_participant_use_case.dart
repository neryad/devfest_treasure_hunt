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
    final participant = await _participantRepository.createParticipant(
      id: IdGenerator.participantId(),
      name: name.trim(),
      nickname: nickname.trim(),
      startedAt: DateTime.now(),
    );
    await _participantRepository.setCurrentParticipantId(participant.id);
    return participant;
  }
}