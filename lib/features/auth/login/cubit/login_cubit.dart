import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/core/utils/shared_pref.dart';
import 'package:flutter_app/network/odoo_service.dart';
import 'package:flutter/foundation.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:flutter_app/core/constants/api_config.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(const LoginState());

  void onUsernameChanged(String value) {
    emit(state.copyWith(
      username: value,
      usernameError: null,
      status: LoginStatus.initial,
      errorMessage: null,
    ));
  }

  void onPasswordChanged(String value) {
    emit(state.copyWith(
      password: value,
      passwordError: null,
      status: LoginStatus.initial,
      errorMessage: null,
    ));
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  Future<void> toggleRememberMe(bool value) async {
    emit(state.copyWith(rememberMe: value));
    final prefs = SharedPref();
    await prefs.saveBool('rememberMe', value);
    if (!value) {
      await prefs.remove('saved_username');
      await prefs.remove('saved_password');
    }
  }

  Future<void> login({
    required String usernameErrorMsg,
    required String passwordErrorMsg,
  }) async {
    // 1. Validation
    bool hasError = false;
    String? usernameError;
    String? passwordError;

    if (state.username.trim().isEmpty) {
      usernameError = usernameErrorMsg;
      hasError = true;
    }

    if (state.password.trim().isEmpty) {
      passwordError = passwordErrorMsg;
      hasError = true;
    }

    if (hasError) {
      emit(state.copyWith(
        usernameError: usernameError,
        passwordError: passwordError,
      ));
      return;
    }

    final username = state.username;
    final password = state.password;
    debugPrint('--- Login Process Started ---');
    debugPrint('Input Username: $username');
    debugPrint('Input Password: $password');

    const baseUrl = ApiConfig.baseUrl;
    debugPrint('Using Base URL: $baseUrl');
    const db = ApiConfig.dbName;
    debugPrint('Using Database: $db');
    final odooService = OdooService(baseUrl);

    emit(state.copyWith(status: LoginStatus.loading));

    try {
      // 1. Authenticate
      debugPrint('Method: authenticate(db: $db, user: $username) - Calling...');
      final session = await odooService.authenticate(db, username, password);
      debugPrint(
        'Method: authenticate - Result: Session ID ${session.id}, User ID ${session.userId}',
      );

      final prefs = SharedPref();
      await prefs.saveObject('session', session);
      await prefs.saveString('baseUrl', baseUrl);
      await prefs.saveString('db', db);
      await prefs.saveObject('port', 7075); // Example port value
      await prefs.saveBool('isLoggedIn', true);
      await prefs.saveBool('rememberMe', state.rememberMe);

      if (state.rememberMe) {
        await prefs.saveString('saved_username', username);
        await prefs.saveString('saved_password', password);
      } else {
        await prefs.remove('saved_username');
        await prefs.remove('saved_password');
      }

      // 2. Get Employee Data
      debugPrint(
        'Method: callKw(hr.employee, search_read) - Fetching employee ID for userId: ${session.userId}',
      );
      final empResponse = await odooService.getEmployeeRecordsForUser(
        session.userId,
      );
      debugPrint(
        'Method: callKw(hr.employee, search_read) - Data Received: $empResponse',
      );

      final empId = empResponse[0]['id']?.toString() ?? '';
      final deptData = empResponse[0]['department_id'];
      String deptId = '';
      if (deptData != null && deptData != false) {
        if (deptData is List && deptData.isNotEmpty) {
          deptId = deptData[0].toString();
        } else {
          deptId = deptData.toString();
        }
      }
      debugPrint('Resolved Employee ID: $empId, Department ID: $deptId');

      // 3. Get Full Employee Details
      debugPrint(
        'Method: callKw(hr.employee, fetch_all_employees_info) - Fetching details for empId: $empId',
      );
      final employeeResponse = await odooService.fetchEmployeeDetails(
        int.parse(empId),
        session.userId,
      );

      // Fetch missing fields from standard search_read on login safely
      Map<String, dynamic> extraFields = {};
      final fieldsToFetch = [
        'identification_id',
        'passport_id',
        'blood_group',
        'emergency_contact',
        'emergency_phone',
        'coach_id',
        'mobile_phone',
        'permanent_address',
        'x_permanent_address',
        'permanent_street',
        'employment_type',
        'employee_type',
        'emp_type',
        'company_id'
      ];
      for (final field in fieldsToFetch) {
        try {
          final List<dynamic> res = await odooService.executeModelMethod(
            'hr.employee',
            'search_read',
            [],
            kwargs: {
              'domain': [['id', '=', int.parse(empId)]],
              'fields': [field],
            },
            silent: true,
          );
          if (res.isNotEmpty && res[0] is Map && res[0][field] != null && res[0][field] != false) {
            extraFields[field] = res[0][field];
          }
        } catch (e) {
          debugPrint('Odoo field $field is invalid or not supported on this instance.');
        }
      }
      debugPrint('Fetched extra employee fields successfully on login: $extraFields');

      final employee = Map<String, dynamic>.from(employeeResponse);
      extraFields.forEach((key, value) {
        if (!employee.containsKey(key) || employee[key] == null || employee[key] == false) {
          employee[key] = value;
        }
      });

      debugPrint(
        'Method: callKw(hr.employee, fetch_all_employees_info) - Data Received: $employee',
      );

      await prefs.saveObject('employee_data', employee);
      await prefs.saveString('employee_id', employee['id']?.toString() ?? '');
      await prefs.saveString('department_id', deptId);
      await prefs.saveString(
        'profile_pic',
        employee['profile_pic']?.toString() ?? '',
      );

      // 4. Get User Groups
      debugPrint(
        'Method: callKw(res.users, search_read) - Checking groups for userId: ${session.userId}',
      );
      final isInternal = await odooService.isInternalUser(session.userId);
      debugPrint('User belongs to Internal User group (96): $isInternal');
      await prefs.saveBool('isInternalUser', isInternal);

      await prefs.saveString('partner_id', session.partnerId.toString());
      debugPrint('Partner ID Saved: ${session.partnerId}');

      debugPrint('--- Login Process Success ---');
      emit(state.copyWith(status: LoginStatus.success));
    } on OdooSessionExpiredException {
      debugPrint('--- Login Process Failed: Session Expired ---');
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: "Session expired. Please log in again.",
        ),
      );
    } on OdooException catch (e) {
      debugPrint('--- Login Process Failed: Odoo Exception ($e) ---');
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: "Wrong login or password",
        ),
      );
    } catch (e) {
      debugPrint('--- Login Process Failed: Unexpected Error ($e) ---');
      
      String errorMsg = "An unexpected error occurred. Please try again later.";
      String errorStr = e.toString().toLowerCase();
      
      if (errorStr.contains('socketexception') || 
          errorStr.contains('connection refused') || 
          errorStr.contains('failed host lookup') || 
          errorStr.contains('clientexception') ||
          errorStr.contains('network') ||
          errorStr.contains('timeout')) {
        errorMsg = "Authentication server is currently unavailable. Please check your connection or try again later.";
      }

      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: errorMsg,
        ),
      );
    } finally {
      odooService.close();
      debugPrint('--- Odoo Client Closed ---');
    }
  }

  Future<void> checkLoginStatus() async {
    final prefs = SharedPref();
    final rememberMe = await prefs.getBool('rememberMe') ?? false;
    final savedUsername = rememberMe ? (await prefs.getString('saved_username') ?? '') : '';
    final savedPassword = rememberMe ? (await prefs.getString('saved_password') ?? '') : '';

    // Initialize state with remembered credentials if available
    emit(state.copyWith(
      rememberMe: rememberMe,
      username: savedUsername,
      password: savedPassword,
    ));

    final sessionData = await prefs.getObject('session');

    if (sessionData != null && sessionData is Map && sessionData.isNotEmpty) {
      final baseUrl =
          await prefs.getString('baseUrl') ?? ApiConfig.baseUrl;

      // Reconstruction of OdooSession
      final session = OdooSession(
        id: sessionData['id']?.toString() ?? '',
        userId: sessionData['userId'] is int
            ? sessionData['userId']
            : int.parse(sessionData['userId']?.toString() ?? '0'),
        partnerId: sessionData['partnerId'] is int
            ? sessionData['partnerId']
            : int.parse(sessionData['partnerId']?.toString() ?? '0'),
        companyId: sessionData['companyId'] is int
            ? sessionData['companyId']
            : int.parse(sessionData['companyId']?.toString() ?? '0'),
        allowedCompanies: const <Company>[],
        userLogin: sessionData['userLogin']?.toString() ?? '',
        userName: sessionData['userName']?.toString() ?? '',
        userLang: sessionData['userLang']?.toString() ?? "en_US",
        userTz: sessionData['userTz']?.toString() ?? "UTC",
        isSystem: sessionData['isSystem'] is bool
            ? sessionData['isSystem']
            : false,
        dbName: sessionData['dbName']?.toString() ?? 'ftprotech',
        serverVersion: sessionData['serverVersion']?.toString() ?? "",
      );

      final client = OdooClient(baseUrl, sessionId: session);

      try {
        debugPrint('Checking Odoo session validity...');
        await client.checkSession();
        debugPrint('Session is valid.');

        emit(state.copyWith(status: LoginStatus.success));
      } catch (e) {
        debugPrint('Session check failed or expired: $e');
        // If session fails, clear credentials
        await _clearSessionData(prefs);
        emit(state.copyWith(status: LoginStatus.initial));
      } finally {
        client.close();
      }
    } else {
      debugPrint('No saved session found.');
      emit(state.copyWith(status: LoginStatus.initial));
    }
  }

  Future<void> logout() async {
    debugPrint('--- Logout Process Started ---');
    final prefs = SharedPref();
    await _clearSessionData(prefs);

    final rememberMe = await prefs.getBool('rememberMe') ?? false;
    final savedUsername = rememberMe ? (await prefs.getString('saved_username') ?? '') : '';
    final savedPassword = rememberMe ? (await prefs.getString('saved_password') ?? '') : '';

    emit(LoginState(
      status: LoginStatus.initial,
      rememberMe: rememberMe,
      username: savedUsername,
      password: savedPassword,
    ));
    debugPrint('--- Logout Process Complete ---');
  }

  Future<void> _clearSessionData(SharedPref prefs) async {
    debugPrint('Clearing session data from SharedPref...');
    await Future.wait([
      prefs.remove('session'),
      prefs.remove('isLoggedIn'),
      prefs.remove('employee_data'),
      prefs.remove('employee_id'),
      prefs.remove('profile_pic'),
      prefs.remove('partner_id'),
      prefs.remove('isInternalUser'),
      prefs.remove('chat_server_url'),
      prefs.remove('chat_db_name'),
      prefs.remove('chat_username'),
      prefs.remove('chat_password'),
      prefs.remove('read_notification_ids'),
    ]);
  }
}
