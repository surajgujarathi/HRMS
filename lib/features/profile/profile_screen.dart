import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/features/auth/login/cubit/login_cubit.dart';
import 'package:flutter_app/features/profile/cubit/profile_cubit.dart';
import 'package:flutter_app/features/profile/cubit/profile_state.dart';
import 'package:flutter_app/features/notifications/cubit/notification_cubit.dart';
import 'package:flutter_app/core/theme/theme_cubit.dart';
import 'package:flutter_app/routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state.status == ProfileStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final employee = state.employee;
          if (employee == null) {
            return const Center(child: Text("No employee data found"));
          }

          return Column(
            children: [
              const SizedBox(height: 50),
              // ---------- CONTENT ----------
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // ---------- USER CARD ----------
                      _WhiteCard(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                _buildAvatar(context, employee.image1920, radius: 28),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        employee.name ?? "User",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        employee.jobTitle ?? "Employee",
                                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            _InfoLine(employee.employeeCode ?? "N/A"),
                            _InfoLine(employee.departmentId?.name ?? "N/A"),
                            _InfoLine("Joining: ${employee.doj != null ? employee.doj!.toString().split(' ')[0] : 'N/A'}"),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ---------- MANAGER ----------
                      if (employee.parentId != null)
                        _WhiteCard(
                          title: "Reporting Manager",
                          child: Row(
                            children: [
                              _buildAvatar(context, null, radius: 20),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    employee.parentId!.name,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Manager",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                      if (employee.coachId != null) ...[
                        const SizedBox(height: 12),
                        _WhiteCard(
                          title: "Coach",
                          child: Row(
                            children: [
                              _buildAvatar(context, null, radius: 20),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    employee.coachId!.name,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Coach",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 12),

                      // ---------- RESUME SECTION ----------
                      if (employee.resumeLines.isNotEmpty)
                        _WhiteCard(
                          title: "Resume",
                          child: Column(
                            children: employee.resumeLines.map((line) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(line.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  if (line.lineTypeId != null)
                                    Text(line.lineTypeId!.name, style: const TextStyle(fontSize: 12, color: Colors.blue)),
                                  Text(
                                    "${line.dateStart?.toString().split(' ')[0] ?? ''} - ${line.dateEnd?.toString().split(' ')[0] ?? 'Present'}",
                                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                                  ),
                                  if (line.description != null)
                                    Text(line.description!, style: const TextStyle(fontSize: 12)),
                                  const Divider(),
                                ],
                              ),
                            )).toList(),
                          ),
                        ),

                      const SizedBox(height: 12),

                      // ---------- SKILLS SECTION ----------
                      if (employee.skills.isNotEmpty)
                        _WhiteCard(
                          title: "Skills",
                          child: Column(
                            children: employee.skills.map((skill) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(skill.skillId?.name ?? "Skill", style: const TextStyle(fontWeight: FontWeight.w500)),
                                      Text("${skill.levelProgress}%", style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: skill.levelProgress / 100.0,
                                    backgroundColor: Theme.of(context).dividerColor.withOpacity(0.1),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      skill.color != 0 ? Color(skill.color) : Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            )).toList(),
                          ),
                        ),

                      const SizedBox(height: 12),

                      // ---------- SETTINGS ----------
                      _SettingTile(
                        icon: Icons.badge_outlined,
                        title: "Job Details",
                        onTap: () {
                          Navigator.pushNamed(context, Routes.jobdetails);
                        },
                      ),
                      const Divider(),
                      _SettingTile(
                        icon: Icons.event_available_outlined,
                        title: "Leave Balance",
                        onTap: () {
                          Navigator.pushNamed(context, Routes.leaveList);
                        },
                      ),
                      const Divider(),
                      _SettingTile(
                        icon: Icons.calendar_month_outlined,
                        title: "Holidays Calendar",
                        onTap: () {
                          Navigator.pushNamed(context, Routes.holidayCalendar);
                        },
                      ),
                      const Divider(),
                      _SettingTile(
                        icon: Icons.receipt_long_outlined,
                        title: "Reimbursements",
                        onTap: () {
                          Navigator.pushNamed(context, Routes.reimbursements);
                        },
                      ),
                      const Divider(),
                      _SettingTile(
                        icon: Icons.school_outlined,
                        title: "Training & Learning",
                        onTap: () {
                          Navigator.pushNamed(context, Routes.learnTraing);
                        },
                      ),
                      const Divider(),
                      _SettingTile(
                        icon: Icons.assignment_turned_in_outlined,
                        title: "Assets Assigned",
                        onTap: () {
                          Navigator.pushNamed(context, Routes.assignedAssets);
                        },
                      ),
                      const Divider(),
                      _SettingTile(
                        icon: Icons.lock_outline,
                        title: "Change Password",
                        onTap: () {
                          Navigator.pushNamed(context, Routes.changepassword);
                        },
                      ),
                      const Divider(),
                      BlocBuilder<NotificationCubit, NotificationState>(
                        builder: (context, state) {
                          return _SettingTile(
                            icon: Icons.notifications_none_outlined,
                            title: "Notifications",
                            trailing: state.unreadCount > 0 
                              ? _Badge(count: state.unreadCount) 
                              : const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.pushNamed(context, Routes.notifications);
                            },
                          );
                        },
                      ),
                      const Divider(),
                      _SettingTile(
                        icon: Icons.language_outlined,
                        title: "Language",
                        onTap: () {
                          Navigator.pushNamed(context, Routes.language);
                        },
                      ),
                      const Divider(),
                      BlocBuilder<ThemeCubit, ThemeMode>(
                        builder: (context, themeMode) {
                          final isDark = themeMode == ThemeMode.dark;
                          return SwitchListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            title: const Text("Dark Mode", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                            secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: Colors.blue),
                            value: isDark,
                            onChanged: (value) {
                              context.read<ThemeCubit>().toggleTheme(value);
                            },
                          );
                        },
                      ),
                      const Divider(),
                      _SettingTile(
                        icon: Icons.logout,
                        title: "Logout",
                        titleColor: Colors.red,
                        iconColor: Colors.red,
                        onTap: () async {
                          await context.read<LoginCubit>().logout();
                          if (context.mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              Routes.login,
                              (route) => false,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, dynamic picData, {double radius = 28}) {
    Widget? avatarImage;
    if (picData != null && picData != false && picData.toString().length > 50) {
      try {
        String cleanedPicData = picData.toString().trim().replaceAll('\n', '').replaceAll('\r', '').replaceAll(' ', '');
        if (cleanedPicData.contains(',')) {
          cleanedPicData = cleanedPicData.split(',').last;
        }
        final bytes = base64Decode(cleanedPicData);
        final header = String.fromCharCodes(bytes.take(10)).toLowerCase();
        if (!header.contains('<?xml') && !header.contains('<svg')) {
          avatarImage = ClipOval(
            child: Image.memory(
              bytes,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.person,
                size: radius * 1.2,
                color: Colors.blue.shade300,
              ),
            ),
          );
        }
      } catch (e) {
        debugPrint('Error decoding avatar: $e');
      }
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).dividerColor.withOpacity(0.05),
      child: avatarImage ??
          Icon(
            Icons.person,
            size: radius * 1.2,
            color: Colors.blue.shade300,
          ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String text;
  const _InfoLine(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
        ),
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  final String? title;
  final Widget child;
  const _WhiteCard({this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.05), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
            ),
            const Divider(),
          ],
          child,
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final Color? titleColor;
  final Color? iconColor;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.titleColor,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      onTap: onTap,
      leading: Icon(icon, color: iconColor ?? Colors.blue),
      title: Text(
        title,
        style: TextStyle(color: titleColor ?? Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500, fontSize: 13),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 10,
      backgroundColor: Colors.red,
      child: Text(
        count.toString(),
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }
}
