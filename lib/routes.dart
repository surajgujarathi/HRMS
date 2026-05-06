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
import 'package:flutter_app/features/profile/pages/notifications.dart';
import 'package:flutter_app/features/profile/pages/perform_review.dart';
import 'package:flutter_app/features/profile/pages/reimbursement_page.dart';
import 'package:flutter_app/features/profile/pages/training_learning.dart';
import 'package:flutter_app/features/screens/ai_chat_bot_page.dart';
import 'package:flutter_app/features/screens/company_cal.dart';
import 'package:flutter_app/features/screens/doc_box_page.dart';
import 'package:flutter_app/features/attendance/presentation/attendance_report.dart';
import 'package:flutter_app/features/screens/leave_page.dart';

class Routes {
  Routes._();
  static String onboarding = '/onboarding';
  static String login = '/login';
  static String admin = '/admin';
  static String main = '/main';
  static String leave = '/leave';
  static String myPay = '/myPay';
  static String inOutReport = '/inout-report';
  static String docbox = '/docbox';
  static String companyCalendar = '/companyCalendar';
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
  static String notifications = '/notifications';
  static String language = '/language';
  static Map<String, WidgetBuilder> getAll() {
    return {
      onboarding: (c) => const OnboardingScreen(),
      login: (c) => const LoginScreen(),
     
      main: (c) => MainPage(),
      leave: (c) => LeavePage(),
      myPay: (c) => PayrollScreen(),
      inOutReport: (c) => InOutReportPage(),
      docbox: (c) => DocBoxPage(),
      companyCalendar: (c) => CompanyCalendarPage(),
      aichatbot: (c) => AiChatBotPage(),
      jobdetails: (c) => JobDetailsPage(),
      personalinf: (c) => const ProfileFullDetailsPage(),
      leavebalance: (c) => LeaveBalanceModernPage(),
      performRev: (c) => PerformanceReviewPage(),
      holidayCalendar: (c) => HolidayCalendarPage(),
      reimbursements: (c) => ReimbursementPage(),
      learnTraing: (c) => TrainingLearningPage(),
      changepassword: (c) => ChangePasswordPage(),
      notifications: (c) => NotificationsPage(),
      language: (c) => LanguagePage(),
    };
  }
}
