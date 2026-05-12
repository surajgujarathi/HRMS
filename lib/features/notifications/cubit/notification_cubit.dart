import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:flutter_app/core/constants/api_config.dart';
import 'package:flutter_app/core/utils/shared_pref.dart';
import 'package:flutter_app/features/notifications/models/notification_model.dart';
import 'package:flutter_app/network/odoo_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum NotificationStatus { initial, loading, success, failure }

enum NotificationFilter { all, unread, read }

class NotificationState extends Equatable {
  final NotificationStatus status;
  final List<OdooNotification> notifications;
  final String? errorMessage;
  final int unreadCount;
  final NotificationFilter filter;

  const NotificationState({
    this.status = NotificationStatus.initial,
    this.notifications = const [],
    this.errorMessage,
    this.unreadCount = 0,
    this.filter = NotificationFilter.all,
  });

  NotificationState copyWith({
    NotificationStatus? status,
    List<OdooNotification>? notifications,
    String? errorMessage,
    int? unreadCount,
    NotificationFilter? filter,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      errorMessage: errorMessage ?? this.errorMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      filter: filter ?? this.filter,
    );
  }

  List<OdooNotification> get filteredNotifications {
    switch (filter) {
      case NotificationFilter.unread:
        return notifications.where((n) => !n.isRead).toList();
      case NotificationFilter.read:
        return notifications.where((n) => n.isRead).toList();
      case NotificationFilter.all:
      default:
        return notifications;
    }
  }

  @override
  List<Object?> get props => [status, notifications, errorMessage, unreadCount, filter];
}

class NotificationCubit extends Cubit<NotificationState> {
  final OdooService _odooService = OdooService(ApiConfig.baseUrl);

  NotificationCubit() : super(const NotificationState());

  Future<void> fetchNotifications() async {
    debugPrint('NotificationCubit: fetchNotifications started');
    emit(state.copyWith(status: NotificationStatus.loading));
    try {
      final prefs = SharedPref();
      final sessionData = await prefs.getObject('session');
      if (sessionData != null) {
        final session = OdooSession.fromJson(sessionData);
        _odooService.setSession(session);
      }
      
      final partnerIdStr = await prefs.getString('partner_id');
      final partnerId = int.tryParse(partnerIdStr ?? '0') ?? 0;
      debugPrint('NotificationCubit: partnerId extracted: $partnerId');

      if (partnerId == 0) {
        throw Exception('Partner ID not found. Please login again.');
      }

      final response = await _odooService.fetchNotifications(partnerId);
      final notifications = response.map((json) => OdooNotification.fromJson(json)).toList();
      
      final unreadCount = notifications.where((n) => !n.isRead).length;
      debugPrint('NotificationCubit: Fetched ${notifications.length} notifications, unread: $unreadCount');

      emit(state.copyWith(
        status: NotificationStatus.success,
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      debugPrint('NotificationCubit: fetchNotifications ERROR: $e');
      emit(state.copyWith(
        status: NotificationStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> markAsRead(int notificationId) async {
    debugPrint('NotificationCubit: markAsRead notificationId=$notificationId');
    try {
      final prefs = SharedPref();
      final sessionData = await prefs.getObject('session');
      if (sessionData != null) {
        final session = OdooSession.fromJson(sessionData);
        _odooService.setSession(session);
      }
      
      await _odooService.markNotificationAsRead(notificationId);
      debugPrint('NotificationCubit: markAsRead success, refreshing list...');
      fetchNotifications(); // Refresh from server to be sure
    } catch (e) {
      debugPrint('NotificationCubit: markAsRead ERROR: $e');
    }
  }

  void setFilter(NotificationFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  @override
  Future<void> close() {
    _odooService.close();
    return super.close();
  }
}
