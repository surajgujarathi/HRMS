// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcome_title => 'Welcome to\nOpzento HR';

  @override
  String get welcome_subtitle =>
      'Experience a seamless way to manage all your HR tasks in one place.';

  @override
  String get login => 'Login';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get remember_me => 'Remember me';

  @override
  String get forgot_password => 'Forgot?';

  @override
  String get sign_in => 'SIGN IN';

  @override
  String get skip => 'Skip';

  @override
  String get next_step => 'Next Step';

  @override
  String get get_started => 'Get Started';

  @override
  String get attendance_payroll => 'Attendance &\nPayroll Made Easy';

  @override
  String get attendance_payroll_subtitle =>
      'Monitor your attendance and manage payroll with precision and ease.';

  @override
  String get sign_in_continue => 'Sign in to continue';

  @override
  String get powered_by => 'POWERED BY';

  @override
  String get language => 'Language';

  @override
  String get error_empty_fields => 'Please enter username and password';

  @override
  String get error_enter_username => 'Please enter username';

  @override
  String get error_enter_password => 'Please enter password';
}
