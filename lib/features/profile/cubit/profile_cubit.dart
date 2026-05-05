import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/core/utils/shared_pref.dart';
import 'package:flutter_app/network/odoo_service.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'profile_state.dart';
import 'package:flutter/foundation.dart';

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
        emit(
          state.copyWith(
            status: ProfileStatus.success,
            employeeData: cachedData as Map<String, dynamic>,
          ),
        );
        // We can still fetch in background if we want to refresh,
        // but for now, let's just return to satisfy the user's point.
        return;
      }

      // 2. If no cache, fetch from server
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

      // Reconstruction of OdooSession from saved data
      // OdooSession usually has a fromJson factory in recent versions
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

        debugPrint('Profile Data Received: $employeeResponse');

        final freshData = employeeResponse;
        await prefs.saveObject('employee_data', freshData);

        emit(
          state.copyWith(
            status: ProfileStatus.success,
            employeeData: freshData,
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
