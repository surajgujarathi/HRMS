import 'dart:convert';
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

      try {
        debugPrint('EventCubit: Fetching events from Odoo...');
        final eventsRaw = await odooService.fetchEvents();
        
        // 1. Collect all ticket and question IDs
        final List<int> allTicketIds = [];
        final List<int> allQuestionIds = [];
        for (var ev in eventsRaw) {
          if (ev['event_ticket_ids'] is List) {
            allTicketIds.addAll(List<int>.from(ev['event_ticket_ids']));
          }
          if (ev['question_ids'] is List) {
            allQuestionIds.addAll(List<int>.from(ev['question_ids']));
          }
        }

        // 2. Fetch details in bulk
        final ticketsRaw = await odooService.fetchEventTickets(allTicketIds);
        final questionsRaw = await odooService.fetchEventQuestions(allQuestionIds);

        // 3. Map details for easy lookup
        final ticketMap = {for (var t in ticketsRaw) t['id']: t};
        final questionMap = {for (var q in questionsRaw) q['id']: q};

        // 4. Merge details back into eventsRaw
        for (var ev in eventsRaw) {
          if (ev['event_ticket_ids'] is List) {
            ev['event_ticket_ids'] = (ev['event_ticket_ids'] as List)
                .map((id) => ticketMap[id] ?? id)
                .toList();
          }
          if (ev['question_ids'] is List) {
            ev['question_ids'] = (ev['question_ids'] as List)
                .map((id) => questionMap[id] ?? id)
                .toList();
          }
        }

        final events = eventsRaw.map((json) => EventModel.fromJson(json)).toList();

        // Fetch user's registrations
        debugPrint('EventCubit: Fetching user registrations...');
        final regResponse = await odooService.fetchUserRegistrations(partnerId: session.partnerId);
        final registeredIds = regResponse
            .map((reg) => (reg['event_id'] as List)[0] as int)
            .toList();
        debugPrint('EventCubit: ACTIVE registration event IDs from Odoo: $registeredIds');

        if (!isClosed) {
          emit(state.copyWith(
            status: EventStatus.loaded, 
            events: events,
            registeredEventIds: registeredIds,
          ));
        }
      } finally {
        odooService.close();
      }
    } catch (e) {
      debugPrint('EventCubit ERROR: $e');
      String userMessage = e.toString();
      
      if (userMessage.contains('event.event') || userMessage.contains('404')) {
        userMessage = "The Events module is not installed on your Odoo server.";
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
  Future<bool> registerForEvent(int eventId, {int? ticketId}) async {
    try {
      final prefs = SharedPref();
      final baseUrl = await prefs.getString('baseUrl');
      final sessionObj = await prefs.getObject('session');

      if (baseUrl == null || sessionObj == null) return false;

      final session = OdooSession.fromJson(sessionObj);
      final odooService = OdooService(baseUrl, session: session);

      try {
        debugPrint('EventCubit: Registering for event $eventId...');
        final registrationId = await odooService.eventRegister(
          eventId: eventId,
          name: session.userName,
          email: session.userLogin,
          partnerId: session.partnerId,
          ticketId: ticketId,
        );

        if (registrationId > 0) {
          debugPrint('EventCubit: Successfully registered! ID: $registrationId');
          await fetchEvents(); // Refresh state
          return true;
        }
        return false;
      } finally {
        odooService.close();
      }
    } catch (e) {
      debugPrint('EventCubit Registration ERROR: $e');
      return false;
    }
  }

  Future<bool> cancelRegistration(int eventId) async {
    try {
      final prefs = SharedPref();
      final baseUrl = await prefs.getString('baseUrl');
      final sessionObj = await prefs.getObject('session');

      if (baseUrl == null || sessionObj == null) return false;

      final session = OdooSession.fromJson(sessionObj);
      final odooService = OdooService(baseUrl, session: session);

      try {
        debugPrint('EventCubit: Cancelling registration for event $eventId...');
        
        // 1. Find the registration ID
        final regs = await odooService.fetchUserRegistrations(partnerId: session.partnerId, eventId: eventId);
        if (regs.isEmpty) return false;
        
        final regId = regs[0]['id'] as int;
        
        // 2. Execute cancel action
        // Odoo's action_cancel often returns null/None on success or an action map.
        // We consider it a success if no exception is thrown.
        await odooService.executeModelMethod(
          'event.registration',
          'action_cancel',
          [[regId]],
        );

        debugPrint('EventCubit: action_cancel executed.');
        await fetchEvents(); // Refresh state to verify
        return true;
      } finally {
        odooService.close();
      }
    } catch (e) {
      debugPrint('EventCubit Cancellation ERROR: $e');
      return false;
    }
  }
}
