import 'package:flutter_app/features/events/models/event_model.dart';

enum EventStatus { initial, loading, loaded, error }

class EventState {
  final EventStatus status;
  final List<EventModel> events;
  final List<int> registeredEventIds;
  final String? errorMessage;

  EventState({
    this.status = EventStatus.initial,
    this.events = const [],
    this.registeredEventIds = const [],
    this.errorMessage,
  });

  EventState copyWith({
    EventStatus? status,
    List<EventModel>? events,
    List<int>? registeredEventIds,
    String? errorMessage,
  }) {
    return EventState(
      status: status ?? this.status,
      events: events ?? this.events,
      registeredEventIds: registeredEventIds ?? this.registeredEventIds,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
