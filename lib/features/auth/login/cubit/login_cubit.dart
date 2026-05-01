import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:flutter_app/core/utils/shared_pref.dart';
import 'package:flutter/foundation.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(const LoginState());

  Future<void> login(String username, String password) async {
    debugPrint('--- Login Process Started ---');
    debugPrint('Input Username: $username');
    debugPrint('Input Password: $password');
    
    const baseUrl = 'https://ftprotech.in/';
    const db = 'ftprotech';
    final client = OdooClient(baseUrl);

    emit(state.copyWith(status: LoginStatus.loading));

    try {
      // 1. Authenticate
      debugPrint('Method: authenticate(db: $db, user: $username) - Calling...');
      final session = await client.authenticate(db, username, password);
      debugPrint('Method: authenticate - Result: Session ID ${session.id}, User ID ${session.userId}');

      final prefs = SharedPref();
      await prefs.saveObject('session', session);
      await prefs.saveString('baseUrl', baseUrl);
      await prefs.saveString('db', db);
      await prefs.saveBool('isLoggedIn', true);

      // 2. Get Employee Data
      debugPrint('Method: callKw(hr.employee, search_read) - Fetching employee ID for userId: ${session.userId}');
      final empResponse = await client.callKw({
        'model': 'hr.employee',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'context': {'bin_size': true},
          'domain': [['user_id', '=', session.userId]],
          'fields': ['id'],
        },
      });
      debugPrint('Method: callKw(hr.employee, search_read) - Data Received: $empResponse');

      if (empResponse == null || empResponse.isEmpty) {
        throw Exception("Employee not found for this user");
      }

      final emp = empResponse as List<dynamic>;
      final empId = emp[0]['id']?.toString() ?? '';
      debugPrint('Resolved Employee ID: $empId');

      // 3. Get Full Employee Details
      debugPrint('Method: callKw(hr.employee, fetch_all_employees_info) - Fetching details for empId: $empId');
      final employeeResponse = await client.callKw({
        'model': 'hr.employee',
        'method': 'fetch_all_employees_info',
        'args': [empId, session.userId],
        'kwargs': {},
      });
      debugPrint('Method: callKw(hr.employee, fetch_all_employees_info) - Data Received: $employeeResponse');

      if (employeeResponse == null) {
        throw Exception("Failed to fetch complete employee details");
      }

      final employee = employeeResponse as Map<String, dynamic>;
      await prefs.saveObject('employee_data', employee);
      await prefs.saveString('employee_id', employee['id']?.toString() ?? '');
      await prefs.saveString('profile_pic', employee['profile_pic']?.toString() ?? '');

      // 4. Get User Groups
      debugPrint('Method: callKw(res.users, search_read) - Checking groups for userId: ${session.userId}');
      final groupsResponse = await client.callKw({
        'model': 'res.users',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'context': {'bin_size': true},
          'domain': [['id', '=', session.userId]],
          'fields': ['groups_id'],
        },
      });
      debugPrint('Method: callKw(res.users, search_read) - Data Received: $groupsResponse');

      if (groupsResponse != null && groupsResponse is List && groupsResponse.isNotEmpty) {
        final groups = groupsResponse[0]['groups_id'] as List<dynamic>? ?? [];
        const internalUserGroupId = 96;
        bool isInternal = groups.contains(internalUserGroupId);
        debugPrint('User belongs to Internal User group (96): $isInternal');
        await prefs.saveBool('isInternalUser', isInternal);
      }

      await prefs.saveString('partner_id', session.partnerId.toString());
      debugPrint('Partner ID Saved: ${session.partnerId}');

      debugPrint('--- Login Process Success ---');
      emit(state.copyWith(status: LoginStatus.success));

    } on OdooSessionExpiredException {
      debugPrint('--- Login Process Failed: Session Expired ---');
      emit(state.copyWith(status: LoginStatus.failure, errorMessage: "Session expired. Please log in again."));
    } on OdooException catch (e) {
      debugPrint('--- Login Process Failed: Odoo Exception ($e) ---');
      emit(state.copyWith(status: LoginStatus.failure, errorMessage: "Wrong login or password"));
    } catch (e) {
      debugPrint('--- Login Process Failed: Unexpected Error ($e) ---');
      emit(state.copyWith(status: LoginStatus.failure, errorMessage: "An error occurred: ${e.toString()}"));
    } finally {
      client.close();
      debugPrint('--- Odoo Client Closed ---');
    }
  }

  Future<void> checkLoginStatus() async {
    final prefs = SharedPref();
    final sessionData = await prefs.getObject('session');
    
    // Check if we have stored chat credentials (as per user request)
    final chatServerUrl = await prefs.getString('chat_server_url');
    final chatDbName = await prefs.getString('chat_db_name');
    final chatUsername = await prefs.getString('chat_username');
    final chatPassword = await prefs.getString('chat_password');

    if (sessionData != null && sessionData is Map && sessionData.isNotEmpty) {
      final baseUrl = await prefs.getString('baseUrl') ?? 'https://ftprotech.in/';
      
      // Reconstruction of OdooSession
      final session = OdooSession(
        id: sessionData['id']?.toString() ?? '',
        userId: sessionData['userId'] is int ? sessionData['userId'] : int.parse(sessionData['userId']?.toString() ?? '0'),
        partnerId: sessionData['partnerId'] is int ? sessionData['partnerId'] : int.parse(sessionData['partnerId']?.toString() ?? '0'),
        companyId: sessionData['companyId'] is int ? sessionData['companyId'] : int.parse(sessionData['companyId']?.toString() ?? '0'),
        allowedCompanies: const <Company>[], 
        userLogin: sessionData['userLogin']?.toString() ?? '',
        userName: sessionData['userName']?.toString() ?? '',
        userLang: sessionData['userLang']?.toString() ?? "en_US",
        userTz: sessionData['userTz']?.toString() ?? "UTC",
        isSystem: sessionData['isSystem'] is bool ? sessionData['isSystem'] : false,
        dbName: sessionData['dbName']?.toString() ?? 'ftprotech',
        serverVersion: sessionData['serverVersion']?.toString() ?? "",
      );

      final client = OdooClient(baseUrl, sessionId: session);
      
      try {
        debugPrint('Checking Odoo session validity...');
        await client.checkSession();
        debugPrint('Session is valid.');
        
        // Chat verification logic could go here if OdooChat is enabled
        
        emit(state.copyWith(status: LoginStatus.success));
      } catch (e) {
        debugPrint('Session check failed: $e');
        // If session fails, clear credentials
        await prefs.remove('session');
        await prefs.remove('isLoggedIn');
        await prefs.remove('chat_server_url');
        await prefs.remove('chat_db_name');
        await prefs.remove('chat_username');
        await prefs.remove('chat_password');
        emit(state.copyWith(status: LoginStatus.initial));
      } finally {
        client.close();
      }
    } else {
      emit(state.copyWith(status: LoginStatus.initial));
    }
  }
}
