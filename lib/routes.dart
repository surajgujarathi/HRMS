import 'package:flutter/widgets.dart';
import 'package:flutter_app/features/profile/pages/personal_information.dart';
import 'package:flutter_app/features/auth/login_screen.dart';
import 'package:flutter_app/features/main/presentation/main_page.dart';
import 'package:flutter_app/features/onboard/onboard_page.dart';
import 'package:flutter_app/features/payroll/payroll_screen.dart';
import 'package:flutter_app/features/profile/pages/change_password.dart';
import 'package:flutter_app/features/profile/pages/holidays_calendar.dart';
import 'package:flutter_app/features/profile/pages/job_details.dart';
import 'package:flutter_app/features/profile/pages/language.dart';
import 'package:flutter_app/features/profile/pages/leave_balance.dart';
import 'package:flutter_app/features/profile/pages/perform_review.dart';
import 'package:flutter_app/features/profile/pages/reimbursement_page.dart';
import 'package:flutter_app/features/profile/pages/training_learning.dart';
import 'package:flutter_app/features/screens/ai_chat_bot_page.dart';
import 'package:flutter_app/features/screens/company_cal.dart';
import 'package:flutter_app/features/screens/doc_box_page.dart';
import 'package:flutter_app/features/attendance/presentation/attendance_report.dart';
import 'package:flutter_app/features/leave/presentation/leave_list_screen.dart';
import 'package:flutter_app/features/leave/presentation/apply_leave_screen.dart';
import 'package:flutter_app/features/maintenance/presentation/assigned_assets_page.dart';
import 'package:flutter_app/features/notifications/presentation/notification_page.dart';
import 'package:flutter_app/features/maintenance/presentation/new_equipment_page.dart';
import 'package:flutter_app/features/events/presentation/events_list_page.dart';
import 'package:flutter_app/features/events/presentation/event_details_page.dart';
import 'package:flutter_app/features/events/models/event_model.dart';
import 'package:flutter_app/features/projects/presentation/projects_page.dart';
import 'package:flutter_app/features/payroll/presentation/it_declaration_page.dart';
import 'package:flutter_app/features/payroll/presentation/tax_regime_comparison_page.dart';

class Routes {
  Routes._();
  static String onboarding = '/onboarding';
  static String login = '/login';
  static String admin = '/admin';
  static String main = '/main';
  static String leaveList = '/leave-list';
  static String applyLeave = '/apply-leave';
  static String leave = '/leave';
  static String myPay = '/myPay';
  static String inOutReport = '/inout-report';
  static String docbox = '/docbox';
 
  static String aichatbot = '/aichatbot';
  // profilepage
  static String jobdetails = '/jobdetails';
  static String personalinf = '/personalInf';
  static String leavebalance = '/leavebalance';
  static String performRev = '/performRev';
  static String holidayCalendar = '/holidayCalendar';
  static String reimbursements = '/reimbursements';
  static String learnTraing = '/learnTraing';
  static String changepassword = '/changepassword';
  static String language = '/language';
  static const String assignedAssets = "/assigned-assets";
  static const String notifications = "/notifications";
  static String newEquipment = '/new-equipment';
  static const String events = "/events";
  static const String eventDetails = "/event-details";
  static const String projects = "/projects";
  static String itDeclarations = '/it-declarations';
  static String taxComparison = '/tax-comparison';
  static Map<String, WidgetBuilder> getAll() {
    return {
      onboarding: (c) => const OnboardingScreen(),
      login: (c) => const LoginScreen(),
     
      main: (c) => MainPage(),
      leaveList: (c) => const LeaveListScreen(),
      applyLeave: (c) => const ApplyLeaveScreen(),
     
      myPay: (c) => PayrollScreen(),
      inOutReport: (c) => InOutReportPage(),
      docbox: (c) => DocBoxPage(),
      aichatbot: (c) => AiChatBotPage(),
      jobdetails: (c) => JobDetailsPage(),
      personalinf: (c) => const ProfileFullDetailsPage(),
      leavebalance: (c) => LeaveBalanceModernPage(),
      performRev: (c) => PerformanceReviewPage(),
      holidayCalendar: (c) => HolidayCalendarPage(),
      reimbursements: (c) => ReimbursementPage(),
      learnTraing: (c) => TrainingLearningPage(),
      changepassword: (c) => ChangePasswordPage(),
      language: (c) => LanguagePage(),
      Routes.assignedAssets: (context) => const AssignedAssetsPage(),
      Routes.notifications: (context) => const NotificationPage(),
      newEquipment: (c) => const NewEquipmentPage(),
      events: (c) => const EventsListPage(),
      eventDetails: (c) => EventDetailsPage(event: ModalRoute.of(c)!.settings.arguments as EventModel),
      projects: (c) => const ProjectsPage(),
      itDeclarations: (c) => const ItDeclarationPage(),
      taxComparison: (c) => const TaxRegimeComparisonPage(),
    };
  }
}
