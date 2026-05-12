// import 'dart:math' as math;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/features/notifications/cubit/notification_cubit.dart';
import 'package:flutter_app/features/profile/cubit/profile_cubit.dart';
import 'package:flutter_app/features/auth/login/cubit/login_cubit.dart';
import 'package:flutter_app/routes.dart';
import 'package:flutter_app/core/utils/shared_pref.dart';
import 'package:flutter_app/core/constants/app_colors.dart';
import 'package:flutter_app/core/widget/custome_search_bar.dart';
import 'package:flutter_app/features/home/widgets/action_card.dart';
import 'package:flutter_app/features/home/widgets/anniversary.dart';
import 'package:flutter_app/features/home/widgets/birth_days.dart';

import 'package:flutter_app/features/attendance/presentation/check_in_out.dart';
import 'package:flutter_app/features/home/widgets/circular.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;

import 'package:flutter_app/features/attendance/cubit/attendance_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late AttendanceCubit _attendanceCubit;

  @override
  void initState() {
    super.initState();
    _attendanceCubit = AttendanceCubit()..loadInitialStatus();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _attendanceCubit.close();
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
    return BlocProvider.value(
      value: _attendanceCubit,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          leadingWidth: 200,
          leading: Padding(
            padding: const EdgeInsets.only(left: 1),
            child: Row(
              children: [
                Transform.scale(
                  scale: 0.6,
                  child: Image.asset(
                    'assets/images/opsen.png',
                    fit: BoxFit.contain,
                  ),
                ),
                Expanded(
                  child: FutureBuilder<dynamic>(
                    future: SharedPref().getObject('employee_data'),
                    builder: (context, snapshot) {
                      String name = "User";
                      if (snapshot.hasData && snapshot.data is Map) {
                        name = snapshot.data['name']?.toString().split(' ').first ?? "User";
                      }
                      return Text(
                        'Hi, $name',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                          letterSpacing: 0.5,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            BlocBuilder<NotificationCubit, NotificationState>(
              builder: (context, state) {
                return Stack(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.notifications);
                      },
                      icon: Icon(Icons.notifications_none_outlined, color: Theme.of(context).colorScheme.onSurface),
                    ),
                    if (state.unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${state.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: PopupMenuButton<String>(
                color: Theme.of(context).colorScheme.surface,
                offset: const Offset(0, 45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (value) {
                  if (value == "profile") {
                    Navigator.pushNamed(context, Routes.personalinf);
                  } else if (value == "logout") {
                    context.read<LoginCubit>().logout();
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil(Routes.login, (route) => false);
                    }
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<String>(
                    value: "profile",
                    child: Row(
                      children: [
                        Icon(Icons.person_outline),
                        SizedBox(width: 8),
                        Text("Go to Profile"),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: "logout",
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text("Logout", style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                child: FutureBuilder<String?>(
                  future: SharedPref().getString('profile_pic'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.grey,
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
                        return CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.lightPurple,
                          child: ClipOval(
                            child: Image.memory(
                              bytes,
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                              gaplessPlayback: true,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.person, size: 22, color: AppColors.primaryPurple),
                            ),
                          ),
                        );
                      } catch (e) {
                        debugPrint('HomePage: Error decoding profile pic: $e');
                        return const CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.lightPurple,
                          child: Icon(Icons.person, size: 22, color: AppColors.primaryPurple),
                        );
                      }
                    } else {
                      return const CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.lightPurple,
                        child: Icon(Icons.person, size: 22, color: AppColors.primaryPurple),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: AppColors.primaryPurple,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSearchBar(),
                  const SizedBox(height: 2),
                  const CheckInOutCard(),
                  const SizedBox(height: 16),
                  const AttendanceActions(),
                  const SizedBox(height: 16),
                  const CircularCardSection(),
                  const SizedBox(height: 16),
                  const BirthdaySection(),
                  const SizedBox(height: 16),
                  const AnniversarySection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
