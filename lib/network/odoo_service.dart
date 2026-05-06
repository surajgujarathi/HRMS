import 'package:intl/intl.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:flutter/foundation.dart';

class OdooService {
  final String baseUrl;
  final OdooClient _client;

  OdooService(this.baseUrl, {OdooSession? session})
    : _client = OdooClient(baseUrl, sessionId: session);

  /// Authenticates the user with the Odoo backend.
  /// [db] is the database name, [username] and [password] are the user credentials.
  Future<OdooSession> authenticate(
    String db,
    String username,
    String password,
  ) async {
    debugPrint('OdooService: authenticate db=$db username=$username');
    return _client.authenticate(db, username, password);
  }

  /// Fetches the employee record ID associated with a specific user ID.
  Future<List<dynamic>> getEmployeeRecordsForUser(int userId) async {
    debugPrint('OdooService: getEmployeeRecordsForUser userId=$userId');
    final response = await executeModelMethod(
      'hr.employee',
      'search_read',
      [],
      kwargs: {
        'context': {'bin_size': true},
        'domain': [
          ['user_id', '=', userId],
        ],
        'fields': ['id'],
      },
    );

    if (response == null || response is! List || response.isEmpty) {
      throw Exception('Employee not found for this user');
    }

    return response;
  }

  /// Fetches detailed employee information from the backend.
  /// Uses a custom Odoo method 'fetch_all_employees_info'.
  Future<Map<String, dynamic>> fetchEmployeeDetails(
    int employeeId,
    int userId,
  ) async {
    debugPrint(
      'OdooService: fetchEmployeeDetails employeeId=$employeeId userId=$userId',
    );
    final response = await executeModelMethod(
      'hr.employee',
      'fetch_all_employees_info',
      [employeeId, userId],
      kwargs: {},
    );

    if (response == null || response is! Map<String, dynamic>) {
      throw Exception('Failed to fetch complete employee details');
    }

    return response;
  }

  /// Checks if the user belongs to the 'Internal User' group (group ID 96).
  Future<bool> isInternalUser(int userId) async {
    debugPrint('OdooService: isInternalUser userId=$userId');
    final response = await executeModelMethod(
      'res.users',
      'search_read',
      [],
      kwargs: {
        'context': {'bin_size': true},
        'domain': [
          ['id', '=', userId],
        ],
        'fields': ['groups_id'],
      },
    );

    if (response == null || response is! List || response.isEmpty) {
      return false;
    }

    final groups = response[0]['groups_id'] as List<dynamic>? ?? [];
    const internalUserGroupId = 96;
    final isInternal = groups.contains(internalUserGroupId);
    debugPrint('OdooService: isInternalUser=$isInternal');
    return isInternal;
  }

  /// Generic helper method to execute any Odoo model method using callKw.
  Future<dynamic> executeModelMethod(
    String model,
    String method,
    List<dynamic> args, {
    Map<String, dynamic>? kwargs,
  }) async {
    debugPrint(
      'OdooService: executeModelMethod model=$model method=$method args=$args kwargs=$kwargs',
    );
    final payload = {
      'model': model,
      'method': method,
      'args': args,
      'kwargs': kwargs ?? {},
    };
    return _client.callKw(payload);
  }

  /// Alternative way to call a method using a pre-built payload.
  Future<dynamic> callKw(Map<String, dynamic> payload) async {
    debugPrint(
      'OdooService: callKw payload=${payload['model']}/${payload['method']}',
    );
    return executeModelMethod(
      payload['model'] as String,
      payload['method'] as String,
      payload['args'] as List<dynamic>,
      kwargs: payload['kwargs'] as Map<String, dynamic>?,
    );
  }

  /// Performs mobile check-in or check-out.
  /// Sends location (lat/long) and IP address to the server.
  Future<Map<String, dynamic>> mobileCheckInOut({
    required int employeeId,
    required bool isCheckIn,
    required double longitude,
    required double latitude,
    required String ipAddress,
  }) async {
    debugPrint(
      'OdooService: mobileCheckInOut employeeId=$employeeId isCheckIn=$isCheckIn long=$longitude lat=$latitude IP=$ipAddress',
    );
    final response = await executeModelMethod(
      'hr.employee',
      'mobile_check_in_out',
      [employeeId, isCheckIn, longitude, latitude, ipAddress],
      kwargs: {},
    );

    debugPrint('OdooService: mobileCheckInOut response=$response');

    if (response == null || response is! Map<String, dynamic>) {
      throw Exception('Failed to perform check in/out');
    }

    return response;
  }

  /// Fetches attendance records for a specific employee within a date range.
  /// Includes additional fields: overtime_hours, validated_overtime_hours, and GPS coordinates.
  Future<List<dynamic>> getAttendanceReport({
    required int employeeId,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    debugPrint(
      'OdooService: getAttendanceReport empId=$employeeId from=$fromDate to=$toDate',
    );
    
    // Odoo needs date in yyyy-MM-dd format for domain filtering
    final String fromStr = DateFormat('yyyy-MM-dd 00:00:00').format(fromDate);
    final String toStr = DateFormat('yyyy-MM-dd 23:59:59').format(toDate);

    final response = await executeModelMethod(
      'hr.attendance',
      'search_read',
      [],
      kwargs: {
        'domain': [
          ['employee_id', '=', employeeId],
          ['check_in', '>=', fromStr],
          ['check_in', '<=', toStr],
        ],
        // Fetching required fields for the detailed attendance report
        'fields': [
          'id',
          'check_in',
          'check_out',
          'worked_hours',
          'overtime_hours',
          'validated_overtime_hours',
          'in_latitude',
          'in_longitude',
          'out_latitude',
          'out_longitude'
        ],
        'order': 'check_in desc', // Show most recent records first
      },
    );

    if (response == null || response is! List) {
      return [];
    }

    return response;
  }

  /// Closes the Odoo client connection.
  void close() {
    debugPrint('OdooService: closing client');
    _client.close();
  }
}
