import '../entities/event.dart';

abstract class EventRepository {
  Future<Event> getEvent();

  Future<void> setEventActive(bool active);
}
