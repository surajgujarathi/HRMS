import 'package:flutter_app/features/events/cubit/event_state.dart';
import 'package:flutter_app/features/events/models/event_model.dart';
import 'package:flutter_app/network/odoo_service.dart';
import 'package:flutter_app/core/utils/shared_pref.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

class EventCubit extends Cubit<EventState> {
  EventCubit() : super(EventState());

  Future<void> fetchEvents() async {
    if (isClosed) return;
    emit(state.copyWith(status: EventStatus.loading));
    
    try {
      final prefs = SharedPref();
      final baseUrl = await prefs.getString('baseUrl');
      final sessionObj = await prefs.getObject('session');

      if (baseUrl == null || sessionObj == null) {
        emit(state.copyWith(status: EventStatus.error, errorMessage: "Session expired"));
        return;
      }

      final session = OdooSession.fromJson(sessionObj);
      final odooService = OdooService(baseUrl, session: session);

      debugPrint('EventCubit: Fetching events from Odoo...');
      try {
        final response = await odooService.fetchEvents();
        debugPrint('EventCubit: Raw Response received. Count: ${response.length}');
        
        final events = response.map((json) {
          debugPrint('EventModel.fromJson: Parsing event ${json['id']} - ${json['name']}');
          return EventModel.fromJson(json);
        }).toList();
        debugPrint('EventCubit: Successfully parsed ${events.length} events');

        if (!isClosed) {
          emit(state.copyWith(status: EventStatus.loaded, events: events));
        }
      } finally {
        odooService.close();
      }
    } catch (e) {
      debugPrint('EventCubit ERROR: $e');
      String userMessage = e.toString();
      
      // Graceful handling for missing Odoo module
      if (userMessage.contains('event.event') || userMessage.contains('404')) {
        userMessage = "The Events module is not installed on your Odoo server. Please contact your administrator to enable it.";
      }

      if (!isClosed) {
        emit(state.copyWith(status: EventStatus.error, errorMessage: userMessage));
      }
    }
  }

  Future<EventModel> fetchEventDetails(int eventId) async {
    try {
      return state.events.firstWhere((e) => e.id == eventId);
    } catch (e) {
      throw Exception('Event not found in state');
    }
  }
}
