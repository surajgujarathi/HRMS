import 'package:flutter/material.dart';
import 'package:flutter_app/core/widget/custome_card.dart';
import 'package:flutter_app/routes.dart';
class AttendanceActions extends StatelessWidget {
  const AttendanceActions({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        'title': 'Leaves',
        'icon': Icons.event_note_rounded,
        'color': const Color(0xFF8E7CF0),
        'routeName': Routes.leaveList,
      },
      {
        'title': 'MyPay',
        'icon': Icons.account_balance_wallet_rounded,
        'color': const Color(0xFF00C853),
        'routeName': Routes.myPay,
      },
      {
        'title': 'In/Out Report',
        'icon': Icons.analytics_rounded,
        'color': const Color(0xFFFF6D00),
        'routeName': Routes.inOutReport,
      },
      {
        'title': 'Doc Box',
        'icon': Icons.folder_copy_rounded,
        'color': const Color(0xFFFF4081),
        'routeName': Routes.docbox,
      },
      {
        'title': 'Company Calendar',
        'icon': Icons.calendar_today_rounded,
        'color': const Color(0xFF00ACC1),
        'routeName': Routes.holidayCalendar,
      },
      {
        'title': 'Ai Chat Bot',
        'icon': Icons.smart_toy_rounded,
        'color': const Color(0xFFFF6D00),
        'routeName': Routes.aichatbot,
      },
      {
        'title': 'Events',
        'icon': Icons.celebration_rounded,
        'color': const Color(0xFF6C63FF),
        'routeName': Routes.events,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.55,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];

        return AttendanceActionCard(
          title: action['title'] as String,
          icon: action['icon'] as IconData,
          color: action['color'] as Color,
          onTap: () {
            Navigator.pushNamed(context, action['routeName'] as String);
          },
        );
      },
    );
  }
}