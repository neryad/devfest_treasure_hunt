class Event {
  const Event({
    required this.id,
    required this.name,
    required this.description,
    this.dateLabel,
    this.active = true,
  });

  final String id;
  final String name;
  final String description;
  final String? dateLabel;
  final bool active;

  Event copyWith({bool? active}) {
    return Event(
      id: id,
      name: name,
      description: description,
      dateLabel: dateLabel,
      active: active ?? this.active,
    );
  }
}
