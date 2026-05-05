import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:flutter/foundation.dart';

class OdooService {
  final String baseUrl;
  final OdooClient _client;

  OdooService(this.baseUrl, {OdooSession? session})
    : _client = OdooClient(baseUrl, sessionId: session);

  Future<OdooSession> authenticate(
    String db,
    String username,
    String password,
  ) async {
    debugPrint('OdooService: authenticate db=$db username=$username');
    return _client.authenticate(db, username, password);
  }

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

  void close() {
    debugPrint('OdooService: closing client');
    _client.close();
  }
}
