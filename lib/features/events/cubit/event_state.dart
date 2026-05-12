import 'package:flutter_app/features/events/models/event_model.dart';

enum EventStatus { initial, loading, loaded, error }

class EventState {
  final EventStatus status;
  final List<EventModel> events;
  final String? errorMessage;

  EventState({
    this.status = EventStatus.initial,
    this.events = const [],
    this.errorMessage,
  });

  EventState copyWith({
    EventStatus? status,
    List<EventModel>? events,
    String? errorMessage,
  }) {
    return EventState(
      status: status ?? this.status,
      events: events ?? this.events,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
