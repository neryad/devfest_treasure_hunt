class Clue {
  const Clue({
    required this.treasureId,
    required this.text,
    required this.unlocked,
    required this.consulted,
  });

  /// Id of the treasure this clue belongs to.
  final String treasureId;

  final String text;

  /// `true` once its treasure has been discovered.
  final bool unlocked;

  /// `true` if it has been shown to the participant at least once.
  final bool consulted;

  Clue copyWith({bool? consulted, bool? unlocked}) => Clue(
        treasureId: treasureId,
        text: text,
        unlocked: unlocked ?? this.unlocked,
        consulted: consulted ?? this.consulted,
      );
}