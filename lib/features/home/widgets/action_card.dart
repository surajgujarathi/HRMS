import 'package:flutter/material.dart';
import 'package:flutter_app/core/widget/custome_card.dart';
import 'package:flutter_app/l10n/app_localizations.dart';
import 'package:flutter_app/routes.dart';
import 'package:flutter_app/core/utils/responsive_util.dart';
class AttendanceActions extends StatelessWidget {
  const AttendanceActions({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; 
    final actions = [
      {
        'title': l10n.leaves,
        'icon': Icons.event_note_rounded,
        'color': const Color(0xFF8E7CF0),
        'routeName': Routes.leaveList,
      },
      {
        'title': l10n.my_pay,
        'icon': Icons.account_balance_wallet_rounded,
        'color': const Color(0xFF00C853),
        'routeName': Routes.myPay,
      },
      {
        'title': l10n.inout_report,
        'icon': Icons.analytics_rounded,
        'color': const Color(0xFFFF6D00),
        'routeName': Routes.inOutReport,
      },
      {
        'title': l10n.doc_box,
        'icon': Icons.folder_copy_rounded,
        'color': const Color(0xFFFF4081),
        'routeName': Routes.docbox,
      },
      {
        'title': l10n.company_calendar,
        'icon': Icons.calendar_today_rounded,
        'color': const Color(0xFF00ACC1),
        'routeName': Routes.holidayCalendar,
      },
      {
            'title': l10n.ai_chat_bot,
        'icon': Icons.smart_toy_rounded,
        'color': const Color(0xFFFF6D00),
        'routeName': Routes.aichatbot,
      },
      {
             'title': l10n.events_list,
        'icon': Icons.celebration_rounded,
        'color': const Color(0xFF6C63FF),
        'routeName': Routes.events,
      },
      {
        'title': 'My Projects',
        'icon': Icons.assignment_rounded,
        'color': const Color(0xFF3F51B5), // AppColors.indigo equivalent
        'routeName': Routes.projects,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveUtil.getCrossAxisCount(context, mobile: 2, tablet: 4),
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: ResponsiveUtil.isTablet(context) 
            ? 1.2 
            : (MediaQuery.of(context).size.height < 780 ? 2.25 : 1.55),
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