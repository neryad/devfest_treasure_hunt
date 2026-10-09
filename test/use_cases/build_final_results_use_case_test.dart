import 'package:devfest_treasure_hunt/domain/entities/participant.dart';
import 'package:devfest_treasure_hunt/domain/use_cases/build_final_results_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const useCase = BuildFinalResultsUseCase();
  final eventStart = DateTime(2026, 10, 9, 8);

  Participant participant({
    required String id,
    required int points,
    required DateTime? completedAt,
  }) => Participant(
    id: id,
    name: 'Name $id',
    nickname: id,
    startedAt: eventStart,
    completedAt: completedAt,
    status: completedAt == null
        ? ParticipantStatus.active
        : ParticipantStatus.completed,
    discoveredTreasureIds: completedAt == null
        ? const ['gym-android']
        : const ['1', '2', '3', '4', '5', '6', '7', '8'],
    medals: completedAt == null ? 1 : 8,
    points: points,
  );

  test('returns no finalists before anyone completes all gyms', () {
    final results = useCase.execute([
      participant(id: 'active', points: 570, completedAt: null),
    ]);

    expect(results, isEmpty);
  });

  test('orders finalists by points then absolute completion time', () {
    final results = useCase.execute([
      participant(
        id: 'later-high-score',
        points: 900,
        completedAt: DateTime(2026, 10, 10, 12),
      ),
      participant(
        id: 'earlier-high-score',
        points: 900,
        completedAt: DateTime(2026, 10, 9, 16),
      ),
      participant(
        id: 'early-lower-score',
        points: 850,
        completedAt: DateTime(2026, 10, 9, 14),
      ),
    ]);

    expect(results.map((result) => result.participantId), [
      'earlier-high-score',
      'later-high-score',
      'early-lower-score',
    ]);
    expect(results.map((result) => result.position), [1, 2, 3]);
  });
}
