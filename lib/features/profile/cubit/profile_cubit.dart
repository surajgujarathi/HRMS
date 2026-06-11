import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/core/utils/shared_pref.dart';
import 'package:flutter_app/network/odoo_service.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'profile_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/features/profile/models/employee_model.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileState());

  /// Clears all in-memory profile data back to initial.
  /// Call this on logout so stale data never leaks into a new session.
  void resetProfile() {
    debugPrint('ProfileCubit: resetting state to initial');
    emit(const ProfileState());
  }

  Future<void> fetchProfile() async {
    if (isClosed) return;
    emit(state.copyWith(status: ProfileStatus.loading));

    try {
      final prefs = SharedPref();

      // 1. Get the current session's employee_id first
      final currentEmployeeId = await prefs.getString('employee_id');
      if (currentEmployeeId == null) {
        throw Exception("Missing session data. Please log in again.");
      }

      // 2. Try cached data ONLY if it belongs to the current logged-in user
      final cachedData = await prefs.getObject('employee_data');
      if (cachedData != null && cachedData is Map && cachedData.isNotEmpty) {
        final cachedId = cachedData['id']?.toString();
        if (cachedId == currentEmployeeId) {
          debugPrint(
            'Using cached profile data for employee: $currentEmployeeId',
          );
          try {
            final employee = Employee.fromJson(
              cachedData as Map<String, dynamic>,
            );
            emit(
              state.copyWith(status: ProfileStatus.success, employee: employee),
            );
          } catch (e) {
            debugPrint('Error parsing cached employee data: $e');
          }
        } else {
          // Cached data belongs to a different user — discard it
          debugPrint(
            'Cached data belongs to different user ($cachedId vs $currentEmployeeId) — clearing cache',
          );
          await prefs.remove('employee_data');
        }
      }

      // 3. Always fetch fresh data from server
      final baseUrl = await prefs.getString('baseUrl');
      final db = await prefs.getString('db');
      final sessionData = await prefs.getObject('session');

      if (baseUrl == null || db == null || sessionData == null) {
        throw Exception("Missing session data. Please log in again.");
      }

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
        dbName: sessionData['dbName']?.toString() ?? db,
        serverVersion: sessionData['serverVersion']?.toString() ?? "",
      );

      final odooService = OdooService(baseUrl, session: session);

      try {
        debugPrint(
          'Fetching profile from server for employeeId: $currentEmployeeId',
        );

        final employeeResponse = await odooService.fetchEmployeeDetails(
          int.parse(currentEmployeeId),
          session.userId,
        );

        // Fetch Resume and Skills in parallel
        final results = await Future.wait([
          odooService.getResumeLines(int.parse(currentEmployeeId)),
          odooService.getEmployeeSkills(int.parse(currentEmployeeId)),
        ]);

        final fullData = Map<String, dynamic>.from(employeeResponse);
        fullData['resume_line_ids'] = results[0];
        fullData['employee_skill_ids'] = results[1];

        final employee = Employee.fromJson(fullData);

        debugPrint('--- EMPLOYEE DATA DEBUG ---');
        debugPrint('ID: ${employee.id}');
        debugPrint('Name: ${employee.name}');
        debugPrint('Code: ${employee.employeeCode}');
        debugPrint('---------------------------');

        // Save fresh data keyed to the current user
        await prefs.saveObject('employee_data', fullData);

        emit(state.copyWith(status: ProfileStatus.success, employee: employee));
      } finally {
        odooService.close();
      }
    } catch (e, stackTrace) {
      debugPrint('Profile Fetch Error: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (!isClosed) {
        emit(
          state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: _getErrorMessage(e),
          ),
        );
      }
    }
  }

  String _getErrorMessage(Object e) {
    if (e is OdooException) {
      try {
        final data = e.error;
        if (data is Map && data['message'] != null) {
          return data['message'].toString();
        }
      } catch (_) {}
      return e.message;
    }
    return e.toString();
  }
}
