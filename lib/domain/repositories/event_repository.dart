import '../entities/event.dart';

abstract class EventRepository {
  Future<Event> getEvent();
}