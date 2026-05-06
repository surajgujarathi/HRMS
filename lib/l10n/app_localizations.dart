import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('te'),
  ];

  /// No description provided for @welcome_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to\nOpzento HR'**
  String get welcome_title;

  /// No description provided for @welcome_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Experience a seamless way to manage all your HR tasks in one place.'**
  String get welcome_subtitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @remember_me.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get remember_me;

  /// No description provided for @forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot?'**
  String get forgot_password;

  /// No description provided for @sign_in.
  ///
  /// In en, this message translates to:
  /// **'SIGN IN'**
  String get sign_in;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next_step.
  ///
  /// In en, this message translates to:
  /// **'Next Step'**
  String get next_step;

  /// No description provided for @get_started.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get get_started;

  /// No description provided for @attendance_payroll.
  ///
  /// In en, this message translates to:
  /// **'Attendance &\nPayroll Made Easy'**
  String get attendance_payroll;

  /// No description provided for @attendance_payroll_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Monitor your attendance and manage payroll with precision and ease.'**
  String get attendance_payroll_subtitle;

  /// No description provided for @sign_in_continue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get sign_in_continue;

  /// No description provided for @powered_by.
  ///
  /// In en, this message translates to:
  /// **'POWERED BY'**
  String get powered_by;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @error_empty_fields.
  ///
  /// In en, this message translates to:
  /// **'Please enter username and password'**
  String get error_empty_fields;

  /// No description provided for @error_enter_username.
  ///
  /// In en, this message translates to:
  /// **'Please enter username'**
  String get error_enter_username;

  /// No description provided for @error_enter_password.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get error_enter_password;

  /// No description provided for @personal_details.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get personal_details;

  /// No description provided for @personal_information.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personal_information;

  /// No description provided for @employee_code.
  ///
  /// In en, this message translates to:
  /// **'Employee Code'**
  String get employee_code;

  /// No description provided for @full_name.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get full_name;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @date_of_birth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get date_of_birth;

  /// No description provided for @marital_status.
  ///
  /// In en, this message translates to:
  /// **'Marital Status'**
  String get marital_status;

  /// No description provided for @blood_group.
  ///
  /// In en, this message translates to:
  /// **'Blood Group'**
  String get blood_group;

  /// No description provided for @identification_id.
  ///
  /// In en, this message translates to:
  /// **'Identification ID'**
  String get identification_id;

  /// No description provided for @passport_no.
  ///
  /// In en, this message translates to:
  /// **'Passport No'**
  String get passport_no;

  /// No description provided for @aadhar_no.
  ///
  /// In en, this message translates to:
  /// **'Aadhar No'**
  String get aadhar_no;

  /// No description provided for @pan_no.
  ///
  /// In en, this message translates to:
  /// **'PAN No'**
  String get pan_no;

  /// No description provided for @work_information.
  ///
  /// In en, this message translates to:
  /// **'Work Information'**
  String get work_information;

  /// No description provided for @job_title.
  ///
  /// In en, this message translates to:
  /// **'Job Title'**
  String get job_title;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get department;

  /// No description provided for @work_location.
  ///
  /// In en, this message translates to:
  /// **'Work Location'**
  String get work_location;

  /// No description provided for @manager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get manager;

  /// No description provided for @date_of_joining.
  ///
  /// In en, this message translates to:
  /// **'Date of Joining'**
  String get date_of_joining;

  /// No description provided for @work_email.
  ///
  /// In en, this message translates to:
  /// **'Work Email'**
  String get work_email;

  /// No description provided for @work_phone.
  ///
  /// In en, this message translates to:
  /// **'Work Phone'**
  String get work_phone;

  /// No description provided for @employment_type.
  ///
  /// In en, this message translates to:
  /// **'Employment Type'**
  String get employment_type;

  /// No description provided for @emergency_contact.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get emergency_contact;

  /// No description provided for @contact_name.
  ///
  /// In en, this message translates to:
  /// **'Contact Name'**
  String get contact_name;

  /// No description provided for @contact_phone.
  ///
  /// In en, this message translates to:
  /// **'Contact Phone'**
  String get contact_phone;

  /// No description provided for @bank_details.
  ///
  /// In en, this message translates to:
  /// **'Bank Details'**
  String get bank_details;

  /// No description provided for @bank_name.
  ///
  /// In en, this message translates to:
  /// **'Bank Name'**
  String get bank_name;

  /// No description provided for @ifsc_code.
  ///
  /// In en, this message translates to:
  /// **'IFSC Code'**
  String get ifsc_code;

  /// No description provided for @account_id.
  ///
  /// In en, this message translates to:
  /// **'Account ID'**
  String get account_id;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @residential_address.
  ///
  /// In en, this message translates to:
  /// **'Residential Address'**
  String get residential_address;

  /// No description provided for @permanent_address.
  ///
  /// In en, this message translates to:
  /// **'Permanent Address'**
  String get permanent_address;

  /// No description provided for @employee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get employee;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @working_hours.
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get working_hours;

  /// No description provided for @check_in.
  ///
  /// In en, this message translates to:
  /// **'Check In'**
  String get check_in;

  /// No description provided for @check_out.
  ///
  /// In en, this message translates to:
  /// **'Check Out'**
  String get check_out;

  /// No description provided for @checking_in.
  ///
  /// In en, this message translates to:
  /// **'Checking In...'**
  String get checking_in;

  /// No description provided for @checking_out.
  ///
  /// In en, this message translates to:
  /// **'Checking Out...'**
  String get checking_out;

  /// No description provided for @checked_in_success.
  ///
  /// In en, this message translates to:
  /// **'Checked in successfully'**
  String get checked_in_success;

  /// No description provided for @checked_out_success.
  ///
  /// In en, this message translates to:
  /// **'Checked out successfully'**
  String get checked_out_success;

  /// No description provided for @session_expired.
  ///
  /// In en, this message translates to:
  /// **'Session expired'**
  String get session_expired;

  /// No description provided for @session_info_missing.
  ///
  /// In en, this message translates to:
  /// **'Session info missing'**
  String get session_info_missing;

  /// No description provided for @attendance_report.
  ///
  /// In en, this message translates to:
  /// **'Attendance Report'**
  String get attendance_report;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @still_working.
  ///
  /// In en, this message translates to:
  /// **'Still Working'**
  String get still_working;

  /// No description provided for @in_label.
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get in_label;

  /// No description provided for @out.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get out;

  /// No description provided for @break_time.
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get break_time;

  /// No description provided for @overtime.
  ///
  /// In en, this message translates to:
  /// **'Overtime'**
  String get overtime;

  /// No description provided for @validated_overtime.
  ///
  /// In en, this message translates to:
  /// **'Validated OT'**
  String get validated_overtime;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @no_records_found.
  ///
  /// In en, this message translates to:
  /// **'No records found for this period'**
  String get no_records_found;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
