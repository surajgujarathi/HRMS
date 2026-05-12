import 'package:intl/intl.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:flutter/foundation.dart';

class OdooService {
  final String baseUrl;
  OdooClient _client;

  OdooService(this.baseUrl, {OdooSession? session})
    : _client = OdooClient(baseUrl, sessionId: session);

  /// Sets the session for the Odoo client.
  void setSession(OdooSession session) {
    _client.close();
    _client = OdooClient(baseUrl, sessionId: session);
  }

  void close() {
    _client.close();
  }

  /// Authenticates the user with the Odoo backend.
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
        'fields': ['id', 'department_id'],
      },
    );

    if (response == null || response is! List || response.isEmpty) {
      throw Exception('Employee not found for this user');
    }

    return response;
  }

  /// Fetches detailed employee information from the backend.
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
    return executeModelMethod(
      payload['model'] as String,
      payload['method'] as String,
      payload['args'] as List<dynamic>,
      kwargs: payload['kwargs'] as Map<String, dynamic>?,
    );
  }

  /// Performs mobile check-in or check-out.
  Future<Map<String, dynamic>> mobileCheckInOut({
    required int employeeId,
    required bool isCheckIn,
    required double longitude,
    required double latitude,
    required String ipAddress,
  }) async {
    final response = await executeModelMethod(
      'hr.employee',
      'mobile_check_in_out',
      [employeeId, isCheckIn, longitude, latitude, ipAddress],
      kwargs: {},
    );

    if (response == null || response is! Map<String, dynamic>) {
      throw Exception('Failed to perform check in/out');
    }

    return response;
  }

  /// Fetches attendance records for a specific employee within a date range.
  Future<List<dynamic>> getAttendanceReport({
    required int employeeId,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
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
        'order': 'check_in desc',
      },
    );

    return response is List ? response : [];
  }

  /// Fetches resume lines for a specific employee.
  Future<List<dynamic>> getResumeLines(int employeeId) async {
    final response = await executeModelMethod(
      'hr.resume.line',
      'search_read',
      [],
      kwargs: {
        'domain': [['employee_id', '=', employeeId]],
        'fields': [
          'id',
          'name',
          'line_type_id',
          'date_start',
          'date_end',
          'display_type',
          'description',
        ],
      },
    );
    return response is List ? response : [];
  }

  /// Fetches skills for a specific employee.
  Future<List<dynamic>> getEmployeeSkills(int employeeId) async {
    final response = await executeModelMethod(
      'hr.employee.skill',
      'search_read',
      [],
      kwargs: {
        'domain': [['employee_id', '=', employeeId]],
        'fields': [
          'id',
          'skill_type_id',
          'skill_id',
          'skill_level_id',
          'level_progress',
          'color',
        ],
      },
    );
    return response is List ? response : [];
  }

  /// Fetches leave requests for a specific employee.
  Future<List<dynamic>> fetchMyLeaves(int employeeId) async {
    final response = await executeModelMethod(
      'hr.leave',
      'search_read',
      [],
      kwargs: {
        'domain': [['employee_id', '=', employeeId]],
        'fields': [
          'id',
          'display_name',
          'holiday_status_id',
          'payslip_state',
          'request_date_from',
          'request_date_to',
          'duration_display',
          'name',
          'supported_attachment_ids',
          'request_unit_half',
          'request_date_from_period',
          'request_unit_hours',
          'request_hour_from',
          'request_hour_to',
          'state',
        ],
        'order': 'request_date_from desc',
      },
    );
    return response is List ? response : [];
  }

  /// Fetches public holidays from resource.calendar.leaves.
  Future<List<dynamic>> fetchHolidays({int? calendarId}) async {
    final List<dynamic> domain = [
      ['resource_id', '=', false],
    ];

    if (calendarId != null) {
      domain.insert(0, '|');
      domain.add(['calendar_id', '=', false]);
      domain.add(['calendar_id', '=', calendarId]);
    }

    final response = await executeModelMethod(
      'resource.calendar.leaves',
      'search_read',
      [],
      kwargs: {
        'domain': domain,
        'fields': [
          'id',
          'name',
          'calendar_id',
          'date_from',
          'date_to',
          'work_entry_type_id',
        ],
        'order': 'date_from asc',
      },
    );
    return response is List ? response : [];
  }

  /// Fetches expenses for a specific employee.
  Future<List<dynamic>> fetchExpenses(int employeeId) async {
    final response = await executeModelMethod(
      'hr.expense',
      'search_read',
      [],
      kwargs: {
        'domain': [['employee_id', '=', employeeId]],
        'fields': [
          'id',
          'name',
          'product_id',
          'total_amount_currency',
          'currency_id',
          'tax_ids',
          'tax_amount_currency',
          'employee_id',
          'payment_mode',
          'vendor_id',
          'date',
          'description',
          'state',
        ],
        'order': 'date desc',
      },
    );
    return response is List ? response : [];
  }

  /// Creates a new expense.
  Future<int> createExpense(Map<String, dynamic> data) async {
    final response = await executeModelMethod(
      'hr.expense',
      'create',
      [data],
    );
    return response is int ? response : 0;
  }

  /// Fetches products that can be used for expenses.
  Future<List<dynamic>> fetchExpenseProducts() async {
    final response = await executeModelMethod(
      'product.product',
      'search_read',
      [],
      kwargs: {
        'domain': [['can_be_expensed', '=', true]],
        'fields': ['id', 'name'],
      },
    );
    return response is List ? response : [];
  }

  /// Fetches currencies.
  Future<List<dynamic>> fetchCurrencies() async {
    final response = await executeModelMethod(
      'res.currency',
      'search_read',
      [],
      kwargs: {
        'fields': ['id', 'name', 'symbol'],
      },
    );
    return response is List ? response : [];
  }

  /// Fetches taxes.
  Future<List<dynamic>> fetchTaxes() async {
    final response = await executeModelMethod(
      'account.tax',
      'search_read',
      [],
      kwargs: {
        'fields': ['id', 'name', 'amount'],
      },
    );
    return response is List ? response : [];
  }

  /// Fetches vendors.
  Future<List<dynamic>> fetchVendors() async {
    final response = await executeModelMethod(
      'res.partner',
      'search_read',
      [],
      kwargs: {
        'domain': ['|', ['supplier_rank', '>', 0], ['is_company', '=', true]],
        'fields': ['id', 'name'],
      },
    );
    return response is List ? response : [];
  }

  /// Submits expenses (creates expense sheet).
  Future<dynamic> actionSubmitExpenses(List<int> ids) async {
    return await executeModelMethod(
      'hr.expense',
      'action_submit_expenses',
      [ids],
    );
  }

  /// Uploads an attachment to an expense.
  Future<int> uploadAttachment({
    required String name,
    required String base64Content,
    required String resModel,
    required int resId,
  }) async {
    final response = await executeModelMethod(
      'ir.attachment',
      'create',
      [{
        'name': name,
        'datas': base64Content,
        'res_model': resModel,
        'res_id': resId,
      }],
    );
    return response is int ? response : 0;
  }

  /// Opens the split wizard for an expense.
  Future<dynamic> actionSplitWizard(int expenseId) async {
    return await executeModelMethod(
      'hr.expense',
      'action_split_wizard',
      [expenseId],
    );
  }

  /// Fetches available leave types.
  Future<List<dynamic>> fetchLeaveTypes({int? employeeId}) async {
    final response = await executeModelMethod(
      'hr.leave.type',
      'search_read',
      [],
      kwargs: {
        'fields': ['id', 'name', 'virtual_remaining_leaves', 'max_leaves'],
        'context': employeeId != null ? {'employee_id': employeeId} : {},
      },
    );
    debugPrint('OdooService: fetchLeaveTypes RAW RESPONSE: $response');
    return response is List ? response : [];
  }

  /// Creates a new leave request.
  Future<int> createLeaveRequest(Map<String, dynamic> data) async {
    final response = await executeModelMethod(
      'hr.leave',
      'create',
      [data],
    );
    return response is int ? response : 0;
  }

  /// Executes a leave action (submit, cancel, etc.)
  Future<dynamic> executeLeaveAction(int leaveId, String action) async {
    debugPrint('OdooService: executeLeaveAction leaveId=$leaveId action=$action');
    
    // Odoo 18 action_cancel returns a wizard (hr.holidays.cancel.leave)
    // We need to create the wizard and call its action_cancel_leave method
    if (action == 'action_cancel') {
      try {
        debugPrint('OdooService: Handling cancellation wizard for Odoo 18');
        final wizardId = await executeModelMethod(
          'hr.holidays.cancel.leave',
          'create',
          [{'leave_id': leaveId, 'reason': 'Cancelled via Mobile App'}],
        );
        
        if (wizardId is int) {
          return await executeModelMethod(
            'hr.holidays.cancel.leave',
            'action_cancel_leave',
            [[wizardId]],
          );
        }
      } catch (e) {
        debugPrint('OdooService: Wizard cancellation failed, trying direct action: $e');
        // Fallback to direct action if wizard fails (some setups might differ)
      }
    }

    final response = await executeModelMethod(
      'hr.leave',
      action,
      [[leaveId]],
    );
    debugPrint('OdooService: action response: $response');
    return response;
  }

  /// Fetches maintenance equipment assigned to a specific employee or department.
  Future<List<dynamic>> fetchAssignedEquipment({int? employeeId, int? departmentId}) async {
    final List<dynamic> domain = [];
    if (employeeId != null && departmentId != null) {
      domain.addAll(['|', ['employee_id', '=', employeeId], ['department_id', '=', departmentId]]);
    } else if (employeeId != null) {
      domain.add(['employee_id', '=', employeeId]);
    } else if (departmentId != null) {
      domain.add(['department_id', '=', departmentId]);
    } else {
      debugPrint('OdooService: fetchAssignedEquipment - Both IDs are null, returning empty list');
      return [];
    }
    
    debugPrint('OdooService: fetchAssignedEquipment DOMAIN: $domain');

    var response = await executeModelMethod(
      'maintenance.equipment',
      'search_read',
      [],
      kwargs: {
        'domain': domain,
        'fields': [
          'id', 'name', 'category_id', 'company_id', 'equipment_assign_to',
          'department_id', 'employee_id', 'maintenance_team_id', 'technician_user_id',
          'scrap_date', 'note', 'partner_id', 'partner_ref', 'model', 'serial_no',
          'comp_serial_no', 'effective_date', 'cost', 'warranty_date',
          'expected_mtbf', 'mtbf', 'estimated_next_failure', 'latest_failure_date', 'mttr'
        ],
      },
    );

    debugPrint('OdooService: fetchAssignedEquipment RAW RESPONSE: $response');

    // DEBUG: If empty, let's fetch any 3 records to see what the data looks like
    if (response is List && response.isEmpty) {
      debugPrint('OdooService: Primary search empty. Fetching any 3 records for debugging...');
      final debugResponse = await executeModelMethod(
        'maintenance.equipment',
        'search_read',
        [],
        kwargs: {
          'domain': [],
          'limit': 3,
          'fields': ['id', 'name', 'employee_id', 'department_id', 'equipment_assign_to'],
        },
      );
      debugPrint('OdooService: DEBUG FALLBACK RESPONSE: $debugResponse');
    }

    return response is List ? response : [];
  }

  /// Fetches equipment categories.
  Future<List<dynamic>> fetchEquipmentCategories() async {
    final response = await executeModelMethod(
      'maintenance.equipment.category',
      'search_read',
      [],
      kwargs: {
        'fields': ['id', 'name'],
      },
    );
    return response is List ? response : [];
  }

  /// Fetches maintenance teams.
  Future<List<dynamic>> fetchMaintenanceTeams() async {
    final response = await executeModelMethod(
      'maintenance.team',
      'search_read',
      [],
      kwargs: {
        'fields': ['id', 'name'],
      },
    );
    return response is List ? response : [];
  }

  /// Fetches departments.
  Future<List<dynamic>> fetchDepartments() async {
    final response = await executeModelMethod(
      'hr.department',
      'search_read',
      [],
      kwargs: {
        'fields': ['id', 'name'],
      },
    );
    return response is List ? response : [];
  }

  /// Fetches notifications for a specific partner.
  Future<List<dynamic>> fetchNotifications(int partnerId) async {
    debugPrint('OdooService: fetchNotifications partnerId=$partnerId - Fetching metadata...');
    // 1. Fetch notification metadata
    final notifications = await executeModelMethod(
      'mail.notification',
      'search_read',
      [],
      kwargs: {
        'domain': [['res_partner_id', '=', partnerId]],
        'fields': [
          'id', 'notification_status', 'mail_message_id', 'notification_type',
          'is_read', 'read_date', 'failure_type', 'failure_reason', 'res_partner_id'
        ],
        'order': 'id desc',
        'limit': 50,
      },
    );

    debugPrint('OdooService: fetchNotifications Metadata Response: $notifications');

    if (notifications is! List || notifications.isEmpty) {
      debugPrint('OdooService: fetchNotifications - No notifications found.');
      return [];
    }

    // 2. Extract message IDs and fetch their details (Subject, Body, Date)
    final messageIds = notifications
        .map((n) => n['mail_message_id'])
        .where((m) => m is List && m.isNotEmpty)
        .map((m) => m[0] as int)
        .toSet()
        .toList();

    debugPrint('OdooService: fetchNotifications - Fetching details for ${messageIds.length} messages...');

    if (messageIds.isEmpty) return notifications;

    final messages = await executeModelMethod(
      'mail.message',
      'search_read',
      [],
      kwargs: {
        'domain': [['id', 'in', messageIds]],
        'fields': ['id', 'subject', 'body', 'date'],
      },
    );

    debugPrint('OdooService: fetchNotifications Message Details Response: $messages');

    // 3. Map message details back to notifications
    if (messages is List) {
      final messageMap = {for (var m in messages) m['id']: m};
      for (var n in notifications) {
        final mId = n['mail_message_id'];
        if (mId is List && mId.isNotEmpty) {
          final mDetails = messageMap[mId[0]];
          if (mDetails != null) {
            n['message_subject'] = mDetails['subject'];
            n['message_body'] = mDetails['body'];
            n['message_date'] = mDetails['date'];
          }
        }
      }
    }

    return notifications;
  }

  /// Marks a notification as read.
  Future<void> markNotificationAsRead(int notificationId) async {
    debugPrint('OdooService: markNotificationAsRead notificationId=$notificationId');
    await executeModelMethod(
      'mail.notification',
      'write',
      [[notificationId], {
        'is_read': true,
        'read_date': DateTime.now().toUtc().toIso8601String(),
      }],
    );
    debugPrint('OdooService: markNotificationAsRead - Success');
  }

  /// Fetches companies.
  Future<List<dynamic>> fetchCompanies() async {
    final response = await executeModelMethod(
      'res.company',
      'search_read',
      [],
      kwargs: {
        'fields': ['id', 'name'],
      },
    );
    return response is List ? response : [];
  }

  /// Fetches employees.
  Future<List<dynamic>> fetchEmployees() async {
    final response = await executeModelMethod(
      'hr.employee',
      'search_read',
      [],
      kwargs: {
        'fields': ['id', 'name'],
      },
    );
    return response is List ? response : [];
  }

  /// Creates a new maintenance equipment.
  Future<int> createEquipment(Map<String, dynamic> data) async {
    final response = await executeModelMethod(
      'maintenance.equipment',
      'create',
      [data],
    );
    return response is int ? response : 0;
  }

  /// Changes the user's password using the Odoo wizard workflow.
  Future<void> changePassword({
    required int userId,
    required String userLogin,
    required String newPassword,
  }) async {
    debugPrint('OdooService: changePassword userId=$userId login=$userLogin');
    
    // 1. Create the wizard
    final wizardId = await executeModelMethod(
      'change.password.wizard',
      'create',
      [{}],
    );

    if (wizardId is! int) {
      throw Exception('Failed to create change password wizard');
    }

    // 2. Create the wizard line (change.password.user)
    await executeModelMethod(
      'change.password.user',
      'create',
      [{
        'wizard_id': wizardId,
        'user_id': userId,
        'user_login': userLogin,
        'new_passwd': newPassword,
      }],
    );

    // 3. Execute the password change button
    await executeModelMethod(
      'change.password.wizard',
      'change_password_button',
      [[wizardId]],
    );
    
    debugPrint('OdooService: changePassword successful');
  }

  /// Fetches events from event.event.
  Future<List<dynamic>> fetchEvents() async {
    debugPrint('OdooService: fetchEvents - Requesting data from event.event');
    final response = await executeModelMethod(
      'event.event',
      'search_read',
      [],
      kwargs: {
        'fields': [
          'id',
          'name',
          'date_begin',
          'date_end',
          'date_tz',
          'lang',
          'event_type_id',
          'tag_ids',
          'organizer_id',
          'user_id',
          'company_id',
          'address_id',
          'website_published',
          'website_visibility',
          'seats_limited',
          'seats_max',
          'seats_taken',
          'badge_format',
          'badge_image',
          'event_ticket_ids',
          'question_ids',
          'note',
          'ticket_instructions'
        ],
        'order': 'date_begin asc',
      },
    );
    return response is List ? response : [];
  }

  /// Fetches details for specific event tickets.
  Future<List<dynamic>> fetchEventTickets(List<int> ticketIds) async {
    if (ticketIds.isEmpty) return [];
    final response = await executeModelMethod(
      'event.event.ticket',
      'search_read',
      [],
      kwargs: {
        'domain': [['id', 'in', ticketIds]],
        'fields': [
          'id', 'name', 'product_id', 'description', 'price',
          'start_sale_datetime', 'end_sale_datetime', 'seats_max', 'seats_reserved'
        ],
      },
    );
    return response is List ? response : [];
  }

  /// Fetches details for specific event questions.
  Future<List<dynamic>> fetchEventQuestions(List<int> questionIds) async {
    if (questionIds.isEmpty) return [];
    final response = await executeModelMethod(
      'event.question',
      'search_read',
      [],
      kwargs: {
        'domain': [['id', 'in', questionIds]],
        'fields': ['id', 'title', 'is_mandatory_answer', 'once_per_order', 'question_type', 'answer_ids'],
      },
    );
    return response is List ? response : [];
  }

}
