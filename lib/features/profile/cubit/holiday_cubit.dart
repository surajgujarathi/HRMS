import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/core/utils/shared_pref.dart';
import 'package:flutter_app/network/odoo_service.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/features/profile/models/holiday_model.dart';
import 'holiday_state.dart';

class HolidayCubit extends Cubit<HolidayState> {
  HolidayCubit() : super(HolidayInitial());

  void clearData() {
    emit(HolidayInitial());
  }

  Future<void> fetchHolidays() async {
    emit(HolidayLoading());

    try {
      final prefs = SharedPref();
      
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
        final response = await odooService.fetchHolidays();
        debugPrint('Holiday API Response: $response');
        
        final holidays = response
            .map((e) => HolidayModel.fromJson(e as Map<String, dynamic>))
            .toList();
        
        debugPrint('Parsed Holidays: ${holidays.length}');
        for (var h in holidays) {
          debugPrint('Holiday: ${h.name}, Date: ${h.dateFrom}');
        }

        emit(HolidayLoaded(holidays));
      } finally {
        odooService.close();
      }
    } catch (e) {
      debugPrint('Holiday Fetch Error: $e');
      emit(HolidayError(e.toString()));
    }
  }
}
