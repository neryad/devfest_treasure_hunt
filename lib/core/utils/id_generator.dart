/// Simple unique id generator for local entities.
///
/// IRL this would come from Firebase (document ids). Keeping it here means
/// nothing else duplicates this responsibility.
class IdGenerator {
  static String participantId() => 'participant-${DateTime.now().millisecondsSinceEpoch}';

  static String discoveryId() => 'discovery-${DateTime.now().microsecondsSinceEpoch}';
}