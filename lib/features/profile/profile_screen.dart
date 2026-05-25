import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/features/auth/login/cubit/login_cubit.dart';
import 'package:flutter_app/features/profile/cubit/profile_cubit.dart';
import 'package:flutter_app/features/profile/cubit/profile_state.dart';
import 'package:flutter_app/features/notifications/cubit/notification_cubit.dart';
import 'package:flutter_app/core/theme/theme_cubit.dart';
import 'package:flutter_app/routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/core/constants/app_colors.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final l10n = AppLocalizations.of(context)!;
          if (state.status == ProfileStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final employee = state.employee;
          if (employee == null) {
            return Center(child: Text(l10n.no_employee_data_found));
          }

          return Stack(
            children: [
              // 🎨 Gradient Header Background
              Container(
                height: 240,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.indigo,
                      AppColors.brightBlue,
                    ],
                  ),
                ),
                child: Stack(
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
                      bottom: 40,
                      left: -20,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white.withOpacity(0.03),
                      ),
                    ),
                  ],
                ),
              ),

              // 🚀 Scrollable Content
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // ---------- HEADER CONTENT ----------
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.2),
                              ),
                              child: _buildAvatar(context, employee.image1920, radius: 45),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    employee.name ?? "User",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      employee.jobTitle ?? "Employee",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ---------- MAIN CONTENT CARDS ----------
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        child: Column(
                          children: [
                            // ---------- USER INFO CARD ----------
                            _ProfileCard(
                              child: Column(
                                children: [
                                  _InfoLine(
                                    icon: Icons.badge_outlined,
                                    label: l10n.employee_id,
                                    value: employee.employeeCode ?? "N/A",
                                  ),
                                  _InfoLine(
                                    icon: Icons.business_outlined,
                                    label: l10n.department,
                                    value: employee.departmentId?.name ?? "N/A",
                                  ),
                                  _InfoLine(
                                    icon: Icons.calendar_today_outlined,
                                    label: l10n.date_of_joining,
                                    value: employee.doj != null ? employee.doj!.toString().split(' ')[0] : 'N/A',
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // ---------- MANAGER & COACH ----------
                            if (employee.parentId != null || employee.coachId != null)
                              Row(
                                children: [
                                  if (employee.parentId != null)
                                    Expanded(
                                      child: _ProfileCard(
                                        title: l10n.manager,
                                        child: Row(
                                          children: [
                                            _buildAvatar(context, null, radius: 16),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                employee.parentId!.name,
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (employee.parentId != null && employee.coachId != null)
                                    const SizedBox(width: 12),
                                  if (employee.coachId != null)
                                    Expanded(
                                      child: _ProfileCard(
                                        title: l10n.coach,
                                        child: Row(
                                          children: [
                                            _buildAvatar(context, null, radius: 16),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                employee.coachId!.name,
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),

                            const SizedBox(height: 16),

                            // ---------- SKILLS SECTION ----------
                            if (employee.skills.isNotEmpty)
                              _ProfileCard(
                                title: l10n.top_skills,
                                child: Column(
                                  children: employee.skills.take(3).map((skill) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(skill.skillId?.name ?? "Skill", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                            Text("${skill.levelProgress}%", style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: skill.levelProgress / 100.0,
                                            minHeight: 6,
                                            backgroundColor: Colors.grey.shade100,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              skill.color != 0 ? Color(skill.color) : AppColors.brightBlue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )).toList(),
                                ),
                              ),

                            const SizedBox(height: 24),

                            // ---------- SETTINGS SECTION ----------
                            _buildSectionHeader(l10n.quick_actions),
                            _ProfileCard(
                              padding: EdgeInsets.zero,
                              child: Column(
                                children: [
                                  _SettingTile(
                                    icon: Icons.badge_outlined,
                                    title: l10n.job_details,
                                    onTap: () => Navigator.pushNamed(context, Routes.jobdetails),
                                  ),
                                  _buildDivider(),
                                  _SettingTile(
                                    icon: Icons.event_available_outlined,
                                    title: l10n.leave_balance,
                                    onTap: () => Navigator.pushNamed(context, Routes.leaveList),
                                  ),
                                  _buildDivider(),
                                  _SettingTile(
                                    icon: Icons.calendar_month_outlined,
                                    title: l10n.holidays_calendar,
                                    onTap: () => Navigator.pushNamed(context, Routes.holidayCalendar),
                                  ),
                                  _buildDivider(),
                                  _SettingTile(
                                    icon: Icons.receipt_long_outlined,
                                    title: l10n.reimbursements,
                                    onTap: () => Navigator.pushNamed(context, Routes.reimbursements),
                                  ),
                                  _buildDivider(),
                                  _SettingTile(
                                    icon: Icons.school_outlined,
                                    title: l10n.training_learning,
                                    onTap: () => Navigator.pushNamed(context, Routes.learnTraing),
                                  ),
                                  _buildDivider(),
                                  _SettingTile(
                                    icon: Icons.assignment_turned_in_outlined,
                                    title: l10n.assets_assigned,
                                    onTap: () => Navigator.pushNamed(context, Routes.assignedAssets),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ---------- RESUME SECTION ----------
                            if (employee.resumeLines.isNotEmpty) ...[
                              _buildSectionHeader(l10n.resume_experience),
                              _ProfileCard(
                                child: Column(
                                  children: employee.resumeLines.map((line) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 16.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppColors.brightBlue.withOpacity(0.05),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              line.lineTypeId?.name.toLowerCase().contains('education') ?? false 
                                                ? Icons.school_outlined 
                                                : Icons.work_outline,
                                              size: 16,
                                              color: AppColors.brightBlue,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  line.name,
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                                ),
                                                if (line.lineTypeId != null)
                                                  Text(
                                                    line.lineTypeId!.name,
                                                    style: const TextStyle(fontSize: 11, color: AppColors.brightBlue, fontWeight: FontWeight.w500),
                                                  ),
                                                Text(
                                                  "${line.dateStart?.toString().split(' ')[0] ?? ''} - ${line.dateEnd?.toString().split(' ')[0] ?? 'Present'}",
                                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                                ),
                                                if (line.description != null && line.description!.isNotEmpty)
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 4),
                                                    child: Text(
                                                      line.description!,
                                                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],

                            _buildSectionHeader(l10n.preferences),
                            _ProfileCard(
                              padding: EdgeInsets.zero,
                              child: Column(
                                children: [
                                  BlocBuilder<NotificationCubit, NotificationState>(
                                    builder: (context, state) {
                                      return _SettingTile(
                                        icon: Icons.notifications_none_outlined,
                                        title: l10n.notifications,
                                        trailing: state.unreadCount > 0 
                                          ? _Badge(count: state.unreadCount) 
                                          : const Icon(Icons.chevron_right, size: 16),
                                        onTap: () => Navigator.pushNamed(context, Routes.notifications),
                                      );
                                    },
                                  ),
                                  _buildDivider(),
                                  _SettingTile(
                                    icon: Icons.language_outlined,
                                    title: l10n.language,
                                    onTap: () => Navigator.pushNamed(context, Routes.language),
                                  ),
                                  _buildDivider(),
                                  BlocBuilder<ThemeCubit, ThemeMode>(
                                    builder: (context, themeMode) {
                                      final isDark = Theme.of(context).brightness == Brightness.dark;
                                      return SwitchListTile(
                                        dense: true,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                        title: Text(l10n.dark_mode, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                                        secondary: Icon(isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined, color: AppColors.brightBlue, size: 20),
                                        value: isDark,
                                        onChanged: (value) => context.read<ThemeCubit>().toggleTheme(value),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            _buildSectionHeader(l10n.security),
                            _ProfileCard(
                              padding: EdgeInsets.zero,
                              child: Column(
                                children: [
                                  _SettingTile(
                                    icon: Icons.lock_outline,
                                    title: l10n.change_password,
                                    onTap: () => Navigator.pushNamed(context, Routes.changepassword),
                                  ),
                                  _buildDivider(),
                                  _SettingTile(
                                    icon: Icons.logout,
                                    title: l10n.logout,
                                    titleColor: Colors.redAccent,
                                    iconColor: Colors.redAccent,
                                    onTap: () async {
                                      context.read<ProfileCubit>().resetProfile();
                                      await context.read<LoginCubit>().logout();
                                      if (context.mounted) {
                                        Navigator.of(context).pushNamedAndRemoveUntil(Routes.login, (route) => false);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade500,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, indent: 50, color: Colors.grey.withOpacity(0.1));
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
      backgroundColor: Colors.white.withOpacity(0.1),
      child: avatarImage ??
          Icon(
            Icons.person,
            size: radius * 1.2,
            color: Colors.white.withOpacity(0.8),
          ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _ProfileCard({this.title, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.brightBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.brightBlue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
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
      leading: Icon(icon, color: iconColor ?? AppColors.brightBlue, size: 20),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
      trailing: trailing ?? Icon(Icons.chevron_right, size: 16, color: Colors.grey.shade400),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(
        color: Colors.redAccent,
        shape: BoxShape.circle,
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
