import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/features/auth/login/cubit/login_cubit.dart';
import 'package:flutter_app/features/profile/cubit/profile_cubit.dart';
import 'package:flutter_app/features/profile/cubit/profile_state.dart';
import 'package:flutter_app/routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit()..fetchProfile(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state.status == ProfileStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = state.employeeData ?? {};

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
                                  _buildAvatar(data['profile_pic'], radius: 28),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['name'] ?? "User",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          data['job_title'] ?? "Employee",
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              _InfoLine(data['employee_code'] ?? "N/A"),
                              _InfoLine(data['department_name'] ?? "N/A"),
                              _InfoLine("Joining: ${data['doj'] ?? 'N/A'}"),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ---------- MANAGER ----------
                        if (data['manager'] != null && data['manager'] != false)
                          _WhiteCard(
                            title: "Reporting Manager",
                            child: Row(
                              children: [
                                _buildAvatar(null, radius: 20), // Manager pic usually not in same record
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['manager'] ?? "N/A",
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      "Manager",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                  const SizedBox(height: 12),

                  // ---------- SETTINGS ----------
                  // ---------- SETTINGS ----------
                  _SettingTile(
                    icon: Icons.badge_outlined,
                    title: "Job Details",
                    onTap: () {
                      Navigator.pushNamed(context, Routes.jobdetails);
                    },
                  ),
                  // Divider(),
                  // _SettingTile(
                  //   icon: Icons.person_outline,
                  //   title: "Personal Information",
                  //   onTap: () {
                  //     Navigator.pushNamed(context, Routes.personalinf);
                  //   },
                  // ),
                  Divider(),
                  _SettingTile(
                    icon: Icons.event_available_outlined,
                    title: "Leave Balance",
                    onTap: () {
                      Navigator.pushNamed(context, Routes.leavebalance);
                    },
                  ),
                  Divider(),

                  _SettingTile(
                    icon: Icons.bar_chart_outlined,
                    title: "Performance Reviews",
                    onTap: () {
                      Navigator.pushNamed(context, Routes.performRev);
                    },
                  ),
                  Divider(),

                  _SettingTile(
                    icon: Icons.calendar_month_outlined,
                    title: "Holidays Calendar",
                    onTap: () {
                      Navigator.pushNamed(context, Routes.holidayCalendar);
                    },
                  ),
                  Divider(),

                  _SettingTile(
                    icon: Icons.receipt_long_outlined,
                    title: "Reimbursements",
                    onTap: () {
                      Navigator.pushNamed(context, Routes.reimbursements);
                    },
                  ),
                  Divider(),

                  _SettingTile(
                    icon: Icons.school_outlined,
                    title: "Training & Learning",
                    onTap: () {
                      Navigator.pushNamed(context, Routes.learnTraing);
                    },
                  ),
                  Divider(),

                  const _SettingTile(
                    icon: Icons.assignment_turned_in_outlined,
                    title: "Assets Assigned",
                  ),
                  Divider(),
                  _SettingTile(
                    icon: Icons.lock_outline,
                    title: "Change Password",
                    onTap: () {
                      Navigator.pushNamed(context, Routes.changepassword);
                    },
                  ),
                  Divider(),

                  _SettingTile(
                    icon: Icons.notifications_none_outlined,
                    title: "Notifications",
                    trailing: _Badge(count: 3),
                    onTap: () {
                      Navigator.pushNamed(context, Routes.notifications);
                    },
                  ),
                  Divider(),

                  _SettingTile(
                    icon: Icons.language_outlined,
                    title: "Language",
                    onTap: () {
                      Navigator.pushNamed(context, Routes.language);
                    },
                  ),
                  Divider(),

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
      ),
    );
  }

  Widget _buildAvatar(dynamic picData, {double radius = 28}) {
    if (picData != null && picData != false && picData.toString().isNotEmpty) {
      try {
        final bytes = base64Decode(picData.toString());
        return CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey.shade100,
          backgroundImage: MemoryImage(bytes),
        );
      } catch (e) {
        return CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey.shade100,
          child: Icon(Icons.person, size: radius * 1.2, color: Colors.blue.shade300),
        );
      }
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade100,
      child: Icon(Icons.person, size: radius * 1.2, color: Colors.blue.shade300),
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
          style: const TextStyle(fontSize: 13, color: Colors.grey),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
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
  final String? subtitle;
  final Widget? trailing;
  final Color? titleColor;
  final Color? iconColor;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.titleColor,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          dense: true,
          onTap: onTap,
          leading: Icon(icon, color: iconColor ?? Colors.blue),
          title: Text(
            title,
            style: TextStyle(
              color: titleColor ?? Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          subtitle: subtitle != null ? Text(subtitle!) : null,
          trailing: trailing ?? const Icon(Icons.chevron_right),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 0,
          ),
        ),

        // 🔹 Divider line
        // const Divider(
        //   height: 1,
        //   thickness: 0.8,
        //   indent: 66, // aligns after icon
        //   endIndent: 30,
        // ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 12,
      backgroundColor: Colors.red,
      child: Text(
        count.toString(),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
