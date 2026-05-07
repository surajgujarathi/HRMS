import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/core/utils/shared_pref.dart';
import 'package:flutter_app/network/odoo_service.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'profile_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/features/profile/models/employee_model.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileState());

  Future<void> fetchProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading));

    try {
      final prefs = SharedPref();

      // 1. Try to get cached data first to save a network call
      final cachedData = await prefs.getObject('employee_data');
      if (cachedData != null && cachedData is Map && cachedData.isNotEmpty) {
        debugPrint('Using cached profile data');
        try {
          final employee = Employee.fromJson(cachedData as Map<String, dynamic>);
          emit(
            state.copyWith(
              status: ProfileStatus.success,
              employee: employee,
            ),
          );
          // Optional: still fetch from server to refresh
        } catch (e) {
          debugPrint('Error parsing cached employee data: $e');
        }
      }

      // 2. Fetch from server
      final baseUrl = await prefs.getString('baseUrl');
      final db = await prefs.getString('db');
      final employeeId = await prefs.getString('employee_id');
      final sessionData = await prefs.getObject('session');

      if (baseUrl == null ||
          db == null ||
          employeeId == null ||
          sessionData == null) {
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
        debugPrint('Fetching profile from server for employeeId: $employeeId');

        final employeeResponse = await odooService.fetchEmployeeDetails(
          int.parse(employeeId),
          session.userId,
        );

        debugPrint('Profile Data Received (Main): $employeeResponse');

        // Fetch Resume and Skills in parallel
        final results = await Future.wait([
          odooService.getResumeLines(int.parse(employeeId)),
          odooService.getEmployeeSkills(int.parse(employeeId)),
        ]);

        final resumeData = results[0];
        final skillsData = results[1];

        debugPrint('Resume Data Received: $resumeData');
        debugPrint('Skills Data Received: $skillsData');

        // Merge data into the response map
        final fullData = Map<String, dynamic>.from(employeeResponse);
        fullData['resume_line_ids'] = resumeData;
        fullData['employee_skill_ids'] = skillsData;

        final employee = Employee.fromJson(fullData);
        
        // Detailed debug print for the user
        debugPrint('--- EMPLOYEE DATA DEBUG ---');
        debugPrint('ID: ${employee.id}');
        debugPrint('Name: ${employee.name}');
        debugPrint('Code: ${employee.employeeCode}');
        debugPrint('Manager: ${employee.parentId?.name}');
        debugPrint('Coach: ${employee.coachId?.name}');
        debugPrint('Department: ${employee.departmentId?.name}');
        debugPrint('Company: ${employee.companyId?.name}');
        debugPrint('Location: ${employee.workLocationId?.name}');
        debugPrint('Resume Lines Count: ${employee.resumeLines.length}');
        debugPrint('Skills Count: ${employee.skills.length}');
        debugPrint('Gender: ${employee.gender}');
        debugPrint('DOJ: ${employee.doj}');
        debugPrint('---------------------------');

        await prefs.saveObject('employee_data', fullData);

        emit(
          state.copyWith(
            status: ProfileStatus.success,
            employee: employee,
          ),
        );
      } finally {
        odooService.close();
      }
    } catch (e) {
      debugPrint('Profile Fetch Error: $e');
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
