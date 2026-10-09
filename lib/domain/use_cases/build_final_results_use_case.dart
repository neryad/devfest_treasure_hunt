import '../entities/finalist_result.dart';
import '../entities/participant.dart';

/// Builds the provisional final results from participants who finished 8/8.
///
/// Higher scores rank first. Equal scores are resolved by the earliest
/// absolute completion time, not by elapsed time since registration.
class BuildFinalResultsUseCase {
  const BuildFinalResultsUseCase();

  List<FinalistResult> execute(List<Participant> participants) {
    final completed =
        participants
            .where((participant) => participant.isCompleted)
            .where((participant) => participant.completedAt != null)
            .toList()
          ..sort((a, b) {
            final byPoints = b.points.compareTo(a.points);
            if (byPoints != 0) return byPoints;

            final byCompletion = a.completedAt!.compareTo(b.completedAt!);
            if (byCompletion != 0) return byCompletion;

            return a.id.compareTo(b.id);
          });

    final results = <FinalistResult>[];
    var position = 0;
    for (var i = 0; i < completed.length; i++) {
      final participant = completed[i];
      if (i == 0 ||
          participant.points != completed[i - 1].points ||
          participant.completedAt != completed[i - 1].completedAt) {
        position = i + 1;
      }
      results.add(
        FinalistResult(
          participantId: participant.id,
          name: participant.name,
          nickname: participant.nickname,
          points: participant.points,
          completedAt: participant.completedAt!,
          elapsed: participant.completedAt!.difference(participant.startedAt),
          position: position,
        ),
      );
    }
    return List.unmodifiable(results);
  }
}
