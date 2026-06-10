import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/features/auth/login/cubit/login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/features/chat/cubit/chat_cubit.dart';
import 'package:flutter_app/features/chat/cubit/chat_state.dart';
import 'package:flutter_app/features/chat/models/chat_model.dart';
import 'package:flutter_app/features/chat/presentation/chat_detail_screen.dart';
import 'package:flutter_app/features/notifications/cubit/notification_cubit.dart';
import 'package:flutter_app/features/auth/login/cubit/login_cubit.dart';
import 'package:flutter_app/routes.dart';
import 'package:flutter_app/main.dart';

class InAppNotificationWrapper extends StatefulWidget {
  final Widget child;

  const InAppNotificationWrapper({super.key, required this.child});

  @override
  State<InAppNotificationWrapper> createState() => _InAppNotificationWrapperState();
}

class _InAppNotificationWrapperState extends State<InAppNotificationWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  Timer? _hideTimer;
  
  String _title = '';
  String _message = '';
  IconData _icon = Icons.notifications;
  String? _routeToOpen;
  VoidCallback? _customOnTap;

  List<ChatChannel> _previousChannels = [];
  int _previousNotificationCount = 0;
  bool _isFirstLoad = true;
  bool _isFirstNotifLoad = true;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.5),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  void _showNotification(String title, String message, IconData icon, {String? route, VoidCallback? onTap}) {
    if (context.read<LoginCubit>().state.status != LoginStatus.success) {
      return; // Do not show notifications if not fully logged in
    }

    setState(() {
      _title = title;
      _message = message;
      _icon = icon;
      _routeToOpen = route;
      _customOnTap = onTap;
      _isDismissed = false;
    });
    
    _controller.forward();
    
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && !_isDismissed) _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: MultiBlocListener(
        listeners: [
          BlocListener<ChatCubit, ChatState>(
            listenWhen: (previous, current) {
              final allChannels = [...current.channels, ...current.directMessages];
              if (_isFirstLoad && allChannels.isNotEmpty) {
                _previousChannels = allChannels;
                _isFirstLoad = false;
                return false;
              }
              if (_isFirstLoad) return false;
              return true;
            },
            listener: (context, state) {
              final allChannels = [...state.channels, ...state.directMessages];
              
              context.read<NotificationCubit>().fetchNotifications();

              for (var channel in allChannels) {
                final prevChannel = _previousChannels.firstWhere(
                  (c) => c.id == channel.id, 
                  orElse: () => channel.copyWith(unreadCount: 0)
                );
                
                if (channel.unreadCount > prevChannel.unreadCount && state.currentChatId != channel.id.toString()) {
                  _showNotification(
                    channel.displayName,
                    channel.lastMessage.isNotEmpty ? channel.lastMessage : 'Sent a new message',
                    Icons.chat_bubble_outline_rounded,
                    onTap: () {
                      if (navigatorKey.currentState != null) {
                        navigatorKey.currentState!.push(
                          MaterialPageRoute(
                            builder: (context) => ChatDetailScreen(channel: channel),
                          ),
                        ).then((_) {
                          if (navigatorKey.currentContext != null && navigatorKey.currentContext!.mounted) {
                            navigatorKey.currentContext!.read<ChatCubit>().fetchChannels();
                          }
                        });
                      }
                    }
                  );
                  break;
                }
              }
              _previousChannels = allChannels;
            },
          ),
          BlocListener<NotificationCubit, NotificationState>(
            listenWhen: (previous, current) {
              if (_isFirstNotifLoad && current.status == NotificationStatus.success) {
                _previousNotificationCount = current.unreadCount;
                _isFirstNotifLoad = false;
                return false;
              }
              return current.status == NotificationStatus.success;
            },
            listener: (context, state) {
              if (state.notifications.isNotEmpty && state.unreadCount > _previousNotificationCount) {
                 final newest = state.notifications.first;
                 _showNotification(
                   newest.messageSubject.isNotEmpty ? newest.messageSubject : 'New Notification',
                   newest.messageBody.isNotEmpty ? newest.messageBody : 'You have a new system notification',
                   Icons.notifications_active_rounded,
                   route: Routes.notifications,
                 );
              }
              _previousNotificationCount = state.unreadCount;
            },
          ),
        ],
        child: Stack(
          children: [
            widget.child,
            if (!_isDismissed)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SlideTransition(
                  position: _offsetAnimation,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Dismissible(
                        key: UniqueKey(),
                        direction: DismissDirection.horizontal,
                        onDismissed: (direction) {
                          _hideTimer?.cancel();
                          setState(() {
                            _isDismissed = true;
                          });
                          _controller.reset();
                        },
                        child: Material(
                          elevation: 16,
                          shadowColor: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              _controller.reverse();
                              if (_customOnTap != null) {
                                _customOnTap!();
                              } else if (_routeToOpen != null && navigatorKey.currentState != null) {
                                 navigatorKey.currentState!.pushNamed(_routeToOpen!);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: const Color(0xFF5A67D8).withOpacity(0.1), // AppColors.primaryPurple fallback
                                    child: const Icon(Icons.notifications_active, color: Color(0xFF5A67D8)),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _title,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _message.replaceAll(RegExp(r'<[^>]*>'), ''), // strip any stray HTML
                                          style: TextStyle(color: Colors.grey[700], fontSize: 14),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
