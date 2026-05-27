// import 'dart:math' as math;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/features/home/presentation/feature_search_delegate.dart';
import 'package:flutter_app/features/notifications/cubit/notification_cubit.dart';
import 'package:flutter_app/features/profile/cubit/profile_cubit.dart';
import 'package:flutter_app/features/auth/login/cubit/login_cubit.dart';
import 'package:flutter_app/features/projects/cubit/projects_cubit.dart';
import 'package:flutter_app/features/projects/cubit/project_tasks_cubit.dart';
import 'package:flutter_app/features/leave/cubit/leave_cubit.dart';
import 'package:flutter_app/features/events/cubit/event_cubit.dart';
import 'package:flutter_app/features/profile/cubit/holiday_cubit.dart';
import 'package:flutter_app/routes.dart';
import 'package:flutter_app/core/utils/shared_pref.dart';
import 'package:flutter_app/core/constants/app_colors.dart';
import 'package:flutter_app/core/widget/custome_search_bar.dart';
import 'package:flutter_app/features/home/widgets/action_card.dart';
import 'package:flutter_app/features/home/widgets/anniversary.dart';
import 'package:flutter_app/features/home/widgets/birth_days.dart';
import 'package:flutter_app/features/home/widgets/upcoming_events.dart';
import 'package:flutter_app/features/home/widgets/upcoming_holidays.dart';

import 'package:flutter_app/features/attendance/presentation/check_in_out.dart';
import 'package:flutter_app/features/home/widgets/circular.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;

import 'package:flutter_app/features/attendance/cubit/attendance_cubit.dart';
import 'package:flutter_app/features/chat/cubit/chat_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late AttendanceCubit _attendanceCubit;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  late Future<dynamic> _employeeDataFuture;
  late Future<String?> _profilePicFuture;

  @override
  void initState() {
    super.initState();
    _attendanceCubit = AttendanceCubit()..loadInitialStatus();
    _employeeDataFuture = SharedPref().getObject('employee_data');
    _profilePicFuture = SharedPref().getString('profile_pic');
    WidgetsBinding.instance.addObserver(this);
    
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    
    // CRITICAL: Initialize background data immediately at app launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ChatCubit>().initChat();
        context.read<NotificationCubit>().fetchNotifications();
        context.read<ProjectsCubit>().fetchProjects();
        context.read<LeaveCubit>().fetchLeavesAndTypes();
        context.read<EventCubit>().fetchEvents();
        context.read<HolidayCubit>().fetchHolidays();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _attendanceCubit.close();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh attendance status when app is resumed from background
    if (state == AppLifecycleState.resumed) {
      debugPrint('HomePage: App resumed, refreshing attendance status...');
      _attendanceCubit.loadInitialStatus();
    }
  }

  Future<void> _handleRefresh() async {
    debugPrint('HomePage: Manual refresh triggered');
    await _attendanceCubit.loadInitialStatus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final List<Map<String, dynamic>> features = [
      {'title': l10n.apply_leave, 'route': Routes.leave, 'icon': Icons.calendar_today},
      {'title': l10n.my_pay, 'route': Routes.myPay, 'icon': Icons.payment},
      {'title': l10n.personal_information, 'route': Routes.personalinf, 'icon': Icons.person},
      {'title': l10n.attendance_report, 'route': Routes.inOutReport, 'icon': Icons.access_time},
      {'title': l10n.company_calendar, 'route': Routes.companyCalendar, 'icon': Icons.event},
      {'title': l10n.ai_chat_bot, 'route': Routes.aichatbot, 'icon': Icons.chat},
      {'title': l10n.doc_box, 'route': Routes.docbox, 'icon': Icons.folder},
      {'title': l10n.job_details, 'route': Routes.jobdetails, 'icon': Icons.work},
      {'title': l10n.notifications, 'route': Routes.notifications, 'icon': Icons.notifications},
      {'title': l10n.events_list, 'route': Routes.events, 'icon': Icons.event_available},
      {'title': 'Projects', 'route': Routes.projects, 'icon': Icons.assignment},
    ];
    
    final searchResults = _searchQuery.isEmpty 
        ? [] 
        : features.where((f) => f['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return BlocProvider.value(
      value: _attendanceCubit,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          top: false,
          bottom: false,
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: AppColors.brightBlue, // Matching the header color
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  toolbarHeight: 170, // Fixed height for header content
                  flexibleSpace: Container(
                    padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.indigo,
                          AppColors.brightBlue,
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: -40,
                          right: -40,
                          child: CircleAvatar(
                            radius: 80,
                            backgroundColor: Colors.white.withOpacity(0.05),
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          left: -20,
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white.withOpacity(0.03),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Image.asset(
                                        'assets/images/opsen.png',
                                        height: 32,
                                        width: 32,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    FutureBuilder<dynamic>(
                                      future: _employeeDataFuture,
                                      builder: (context, snapshot) {
                                        String name = "User";
                                        if (snapshot.hasData && snapshot.data is Map) {
                                          name = snapshot.data['name']?.toString().split(' ').first ?? "User";
                                        }
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              l10n.welcome_prefix,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white.withOpacity(0.8),
                                              ),
                                            ),
                                            Text(
                                              name,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    _buildNotificationIcon(context),
                                    const SizedBox(width: 12),
                                    _buildProfileMenu(context),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            CustomSearchBar(
                              controller: _searchController,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                _searchQuery.isEmpty ? SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 100), // Extra bottom padding for floating nav bar
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const CheckInOutCard(),
                      // const SizedBox(height: 10),
                      const AttendanceActions(),
                      const SizedBox(height: 24),
                      const UpcomingHolidaysSection(),
                      const SizedBox(height: 24),
                      const UpcomingEventsSection(),
                      const SizedBox(height: 24),
                    ]),
                  ),
                ) : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final feature = searchResults[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                          shadowColor: Colors.black12,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                               padding: const EdgeInsets.all(8),
                               decoration: BoxDecoration(
                                 color: AppColors.brightBlue.withOpacity(0.1),
                                 borderRadius: BorderRadius.circular(8),
                               ),
                               child: Icon(feature['icon'] as IconData, color: AppColors.brightBlue)
                            ),
                            title: Text(feature['title'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                            onTap: () {
                              _searchController.clear();
                              FocusScope.of(context).unfocus();
                              Navigator.pushNamed(context, feature['route'] as String);
                            },
                          ),
                        );
                      },
                      childCount: searchResults.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, Routes.notifications),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
              ),
            ),
            if (state.unreadCount > 0)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.dangerRed,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryPurple, width: 2),
                  ),
                  child: Text(
                    '${state.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<String>(
      color: Theme.of(context).colorScheme.surface,
      offset: const Offset(0, 45),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (value) async {
        if (value == "profile") {
          Navigator.pushNamed(context, Routes.personalinf);
        } else if (value == "logout") {
          await context.read<LoginCubit>().logout();
          if (context.mounted) {
            context.read<ChatCubit>().clearData();
            context.read<NotificationCubit>().clearData();
            context.read<ProjectsCubit>().clearData();
            context.read<ProjectTasksCubit>().clearData();
            context.read<LeaveCubit>().clearData();
            context.read<EventCubit>().clearData();
            context.read<HolidayCubit>().clearData();
            context.read<ProfileCubit>().resetProfile();
            Navigator.of(context).pushNamedAndRemoveUntil(Routes.login, (route) => false);
          }
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: "profile",
          child: Row(
            children: [
              const Icon(Icons.person_outline, color: AppColors.primaryPurple),
              const SizedBox(width: 12),
              Text(l10n.go_to_profile, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: "logout",
          child: Row(
            children: [
              const Icon(Icons.logout_rounded, color: AppColors.dangerRed),
              const SizedBox(width: 12),
              Text(l10n.logout, style: const TextStyle(color: AppColors.dangerRed, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
      child: FutureBuilder<String?>(
        future: _profilePicFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white24,
              child: Padding(
                padding: EdgeInsets.all(4.0),
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
            );
          }
          final picData = snapshot.data;
          if (snapshot.hasData && picData != null && picData.length > 50 && picData != 'false') {
            try {
              String cleanedPicData = picData.trim().replaceAll('\n', '').replaceAll('\r', '').replaceAll(' ', '');
              if (cleanedPicData.contains(',')) {
                cleanedPicData = cleanedPicData.split(',').last;
              }
              final bytes = base64Decode(cleanedPicData);
              
              // Validate image magic bytes to prevent Android ImageDecoder console spam
              bool isValidImage = false;
              if (bytes.length >= 3) {
                // Check for JPEG (FF D8 FF)
                if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
                  isValidImage = true;
                }
                // Check for PNG (89 50 4E 47)
                else if (bytes.length >= 4 && bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
                  isValidImage = true;
                }
              }

              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.lightPurple,
                  child: ClipOval(
                    child: isValidImage 
                      ? Image.memory(
                          bytes,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person, size: 24, color: AppColors.primaryPurple),
                        )
                      : const Icon(Icons.person, size: 24, color: AppColors.primaryPurple),
                  ),
                ),
              );
            } catch (e) {
              return Container(
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                child: const CircleAvatar(radius: 20, backgroundColor: AppColors.lightPurple, child: Icon(Icons.person, color: AppColors.primaryPurple)),
              );
            }
          } else {
            return Container(
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
              child: const CircleAvatar(radius: 20, backgroundColor: AppColors.lightPurple, child: Icon(Icons.person, color: AppColors.primaryPurple)),
            );
          }
        },
      ),
    );
  }
    
  }

