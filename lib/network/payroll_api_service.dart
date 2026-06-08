import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/network/odoo_service.dart';
import 'package:flutter_app/core/utils/shared_pref.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class PayrollApiService {
  final OdooService _odooService;

  OdooService get odooService => _odooService;

  PayrollApiService(this._odooService);

  Future<Map<String, dynamic>?> fetchLatestPayslipDetails(int employeeId) async {
    debugPrint('PayrollApiService: fetchLatestPayslipDetails employeeId=$employeeId');
    try {
      final payslips = await _odooService.executeModelMethod(
        'hr.payslip',
        'search_read',
        [],
        kwargs: {
          'domain': [
            ['employee_id', '=', employeeId],
            ['state', '!=', 'cancel'],
          ],
          'fields': ['id', 'name', 'line_ids', 'date_from', 'date_to'],
          'order': 'date_to desc',
          'limit': 1,
        },
      );

      if (payslips is List && payslips.isNotEmpty) {
        final payslip = Map<String, dynamic>.from(payslips.first as Map);
        final lineIds = payslip['line_ids'] as List<dynamic>? ?? [];
        if (lineIds.isNotEmpty) {
          final lines = await _odooService.executeModelMethod(
            'hr.payslip.line',
            'search_read',
            [],
            kwargs: {
              'domain': [
                ['id', 'in', lineIds],
              ],
              'fields': ['name', 'code', 'total', 'category_id', 'appears_on_payslip'],
            },
          );
          if (lines is List) {
            payslip['lines'] = lines.where((l) => l['appears_on_payslip'] != false).toList();
          }
        }
        return payslip;
      }
    } catch (e) {
      debugPrint('Error fetching latest payslip details: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> fetchEmployeeContractDetails(int employeeId) async {
    debugPrint('PayrollApiService: fetchEmployeeContractDetails employeeId=$employeeId');
    try {
      final contracts = await _odooService.executeModelMethod(
        'hr.contract',
        'search_read',
        [],
        kwargs: {
          'domain': [
            ['employee_id', '=', employeeId],
          ],
          'fields': ['id', 'wage', 'name', 'state'],
          'order': 'id desc',
          'limit': 1,
        },
      );
      if (contracts is List && contracts.isNotEmpty) {
        return Map<String, dynamic>.from(contracts.first as Map);
      }
    } catch (e) {
      debugPrint('Error fetching employee contract details: $e');
    }
    return null;
  }

  static Future<PayrollApiService> create() async {
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
      isSystem: sessionData['isSystem'] is bool ? sessionData['isSystem'] : false,
      dbName: sessionData['dbName']?.toString() ?? db,
      serverVersion: sessionData['serverVersion']?.toString() ?? "",
    );

    final odooService = OdooService(baseUrl, session: session);
    return PayrollApiService(odooService);
  }

  // ==========================================
  // 1. IT Declarations (emp.it.declaration)
  // ==========================================

  Future<List<dynamic>> fetchItDeclarations(int employeeId) async {
    debugPrint('PayrollApiService: fetchItDeclarations employeeId=$employeeId');
    final response = await _odooService.executeModelMethod(
      'emp.it.declaration',
      'search_read',
      [],
      kwargs: {
        'domain': [
          ['employee_id', '=', employeeId],
        ],
        'fields': [
          'id',
          'employee_id',
          'period_id',
          'total_investment',
          'return_reason',
          'house_rent_costing_id',
          'tax_regime',
          'state',
        ],
      },
    );
    return response is List ? response : [];
  }

  Future<int> createItDeclaration(Map<String, dynamic> vals) async {
    debugPrint('PayrollApiService: createItDeclaration vals=$vals');
    final response = await _odooService.executeModelMethod(
      'emp.it.declaration',
      'create',
      [vals],
    );
    return response is int ? response : (response is List && response.isNotEmpty ? response[0] as int : 0);
  }

  Future<bool> writeItDeclaration(int declarationId, Map<String, dynamic> vals) async {
    debugPrint('PayrollApiService: writeItDeclaration id=$declarationId vals=$vals');
    final response = await _odooService.executeModelMethod(
      'emp.it.declaration',
      'write',
      [[declarationId], vals],
    );
    return response == true;
  }

  Future<bool> unlinkItDeclaration(int declarationId) async {
    debugPrint('PayrollApiService: unlinkItDeclaration id=$declarationId');
    final response = await _odooService.executeModelMethod(
      'emp.it.declaration',
      'unlink',
      [[declarationId]],
    );
    return response == true;
  }

  Future<dynamic> toggleSectionVisibility(int declarationId) async {
    debugPrint('PayrollApiService: toggleSectionVisibility id=$declarationId');
    return await _odooService.executeModelMethod(
      'emp.it.declaration',
      'toggle_section_visibility',
      [[declarationId]],
    );
  }

  Future<bool> submitItDeclaration(int declarationId) async {
    debugPrint('PayrollApiService: submitItDeclaration id=$declarationId');
    final response = await _odooService.executeModelMethod(
      'emp.it.declaration',
      'action_submit',
      [[declarationId]],
    );
    return response == true;
  }

  Future<bool> returnItDeclarationToDraft(int declarationId, String returnReason) async {
    debugPrint('PayrollApiService: returnItDeclarationToDraft id=$declarationId reason=$returnReason');
    final response = await _odooService.executeModelMethod(
      'emp.it.declaration',
      'action_return_to_draft',
      [[declarationId]],
      kwargs: {
        'context': {'return_reason': returnReason}
      }
    );
    return response == true;
  }

  Future<String> downloadSubmissionPdf(int declarationId) async {
    debugPrint('PayrollApiService: downloadSubmissionPdf id=$declarationId');
    try {
      final response = await _odooService.executeModelMethod(
        'emp.it.declaration',
        'action_download_submission_pdf',
        [[declarationId]],
      );
      if (response is String && response.isNotEmpty) {
        return response;
      }
    } catch (e) {
      debugPrint('action_download_submission_pdf failed: $e');
    }

    // Fallback: Search in ir.attachment for this declaration record
    try {
      debugPrint('Searching ir.attachment for res_model=emp.it.declaration, res_id=$declarationId');
      final attachments = await _odooService.executeModelMethod(
        'ir.attachment',
        'search_read',
        [],
        kwargs: {
          'domain': [
            ['res_model', '=', 'emp.it.declaration'],
            ['res_id', '=', declarationId],
          ],
          'fields': ['id', 'name', 'url'],
          'limit': 1,
        },
      );
      if (attachments is List && attachments.isNotEmpty) {
        final attachment = attachments.first;
        final attachmentId = attachment['id'] as int;
        return '/web/content/ir.attachment/$attachmentId/datas';
      }
    } catch (e) {
      debugPrint('Fallback search in ir.attachment failed: $e');
    }

    return '';
  }

  // ==========================================
  // 2. Payslip Download Wizard (employee.payslip.download.wizard)
  // ==========================================

  Future<List<dynamic>> fetchPayrollPeriods() async {
    final response = await _odooService.executeModelMethod(
      'payroll.period',
      'search_read',
      [],
      kwargs: {
        'fields': ['id', 'name'],
      },
    );
    return response is List ? response : [];
  }

  Future<List<dynamic>> fetchPeriodLines(int periodId) async {
    final response = await _odooService.executeModelMethod(
      'payroll.period.line',
      'search_read',
      [],
      kwargs: {
        'domain': [
          ['period_id', '=', periodId]
        ],
        'fields': ['id', 'name'],
      },
    );
    return response is List ? response : [];
  }

  Future<Map<String, dynamic>> createPayslipDownloadWizard(Map<String, dynamic> vals) async {
    debugPrint('PayrollApiService: createPayslipDownloadWizard vals=$vals');
    final wizardId = await _odooService.executeModelMethod(
      'employee.payslip.download.wizard',
      'create',
      [vals],
    );

    if (wizardId is int) {
      // Read computed payslip count
      final readRes = await _odooService.executeModelMethod(
        'employee.payslip.download.wizard',
        'read',
        [[wizardId]],
        kwargs: {
          'fields': ['id', 'payslip_count', 'employee_id', 'download_type', 'period_id', 'period_line']
        }
      );
      if (readRes is List && readRes.isNotEmpty) {
        return readRes[0] as Map<String, dynamic>;
      }
    }
    return {};
  }

  Future<String> actionDownloadPayslips(int wizardId) async {
    debugPrint('PayrollApiService: actionDownloadPayslips wizardId=$wizardId');
    final response = await _odooService.executeModelMethod(
      'employee.payslip.download.wizard',
      'action_download_payslips',
      [[wizardId]],
    );
    // Usually returns action dict with URL or binary string
    if (response is Map && response.containsKey('url')) {
      return response['url'] as String;
    }
    return response is String ? response : '';
  }

  // ==========================================
  // 3. IT Tax Statement Wizard (it.tax.statement.wizard)
  // ==========================================

  Future<Map<String, dynamic>> createTaxStatementWizard(Map<String, dynamic> vals) async {
    debugPrint('PayrollApiService: createTaxStatementWizard vals=$vals');
    final wizardId = await _odooService.executeModelMethod(
      'it.tax.statement.wizard',
      'create',
      [vals],
    );

    if (wizardId is int) {
      final readRes = await _odooService.executeModelMethod(
        'it.tax.statement.wizard',
        'read',
        [[wizardId]],
        kwargs: {
          'fields': [
            'id', 'employee_id', 'contract_id', 'taxpayer_age', 
            'residential_status', 'parent_age', 'emp_doj', 
            'period_id', 'period_line', 'tax_regime'
          ]
        }
      );
      if (readRes is List && readRes.isNotEmpty) {
        return readRes[0] as Map<String, dynamic>;
      }
    }
    return {};
  }

  Future<Map<String, dynamic>> checkRegimeComparison(int wizardId) async {
    debugPrint('PayrollApiService: checkRegimeComparison wizardId=$wizardId');
    final response = await _odooService.executeModelMethod(
      'it.tax.statement.wizard',
      'action_check_regime_comparison',
      [[wizardId]],
    );
    if (response is Map<String, dynamic>) {
      return response;
    }
    // Alternatively read comparison fields if computed
    final readRes = await _odooService.executeModelMethod(
      'it.tax.statement.wizard',
      'read',
      [[wizardId]],
      kwargs: {
        'fields': [
          'taxable_old', 'taxable_new',
          'tax_old', 'tax_new',
          'beneficial_regime', 'regime_difference'
        ]
      }
    );
    if (readRes is List && readRes.isNotEmpty) {
      return readRes[0] as Map<String, dynamic>;
    }
    return {};
  }

  Future<String> generateTaxReport(int wizardId) async {
    debugPrint('PayrollApiService: generateTaxReport wizardId=$wizardId');
    final response = await _odooService.executeModelMethod(
      'it.tax.statement.wizard',
      'action_generate_report',
      [[wizardId]],
    );
    if (response is Map && response.containsKey('url')) {
      return response['url'] as String;
    }
    return response is String ? response : '';
  }

  Future<String> generateComparisonReport(int wizardId) async {
    debugPrint('PayrollApiService: generateComparisonReport wizardId=$wizardId');
    final response = await _odooService.executeModelMethod(
      'it.tax.statement.wizard',
      'action_generate_comparison_report',
      [[wizardId]],
    );
    if (response is Map && response.containsKey('url')) {
      return response['url'] as String;
    }
    return response is String ? response : '';
  }

  Future<String> downloadAndOpenFile(String urlPath, {String? defaultFileName}) async {
    debugPrint('PayrollApiService: downloadAndOpenFile urlPath=$urlPath');
    if (urlPath.isEmpty) throw Exception('URL path is empty');

    String? model;
    int? recordId;
    String? fieldName;

    try {
      final pathRegex = RegExp(r'\/web\/content\/([a-zA-Z0-9\._]+)\/(\d+)\/([a-zA-Z0-9\_]+)');
      final pathMatch = pathRegex.firstMatch(urlPath);
      if (pathMatch != null) {
        model = pathMatch.group(1);
        recordId = int.tryParse(pathMatch.group(2) ?? '');
        fieldName = pathMatch.group(3);
      } else {
        final uri = Uri.parse(urlPath);
        model = uri.queryParameters['model'];
        recordId = int.tryParse(uri.queryParameters['id'] ?? '');
        fieldName = uri.queryParameters['field'];
      }
    } catch (e) {
      debugPrint('Failed to parse URL for RPC download: $e');
    }

    Uint8List? fileBytes;

    if (model != null && recordId != null && fieldName != null) {
      debugPrint('Attempting RPC read for model: $model, id: $recordId, field: $fieldName');
      try {
        final readRes = await _odooService.executeModelMethod(
          model,
          'read',
          [[recordId]],
          kwargs: {
            'fields': [fieldName],
          },
        );
        if (readRes is List && readRes.isNotEmpty) {
          final datas = readRes[0][fieldName];
          if (datas is String && datas.isNotEmpty && datas != "false") {
            final cleanedDatas = datas.trim().replaceAll(RegExp(r'\s+'), '');
            final actualBase64 = cleanedDatas.contains(',') ? cleanedDatas.split(',').last : cleanedDatas;
            fileBytes = base64Decode(actualBase64);
          }
        }
      } catch (e) {
        debugPrint('RPC read failed, falling back to HTTP download: $e');
      }
    }

    if (fileBytes == null) {
      final prefs = SharedPref();
      final sobj = await prefs.getObject('session');
      final baseUrl = await prefs.getString('baseUrl');
      if (baseUrl == null || sobj == null) throw Exception('Not logged in / Session not found');
      final session = OdooSession.fromJson(sobj);

      String fullUrl = urlPath;
      if (!fullUrl.startsWith('http')) {
        fullUrl = baseUrl + (urlPath.startsWith('/') ? '' : '/') + urlPath;
      }

      final uri = Uri.parse(fullUrl);
      final response = await http.get(
        uri,
        headers: {
          'Cookie': 'session_id=${session.id}',
        },
      );
      if (response.statusCode == 200) {
        fileBytes = response.bodyBytes;
      } else {
        throw Exception('Failed to download file (HTTP status ${response.statusCode})');
      }
    }

    final downloadDir = await _getBestDownloadDirectory();
    String fileName = defaultFileName ?? 'downloaded_file';
    if (urlPath.contains('.zip') || fileName.endsWith('.zip')) {
      if (!fileName.endsWith('.zip')) fileName += '.zip';
    } else if (urlPath.contains('.pdf') || fileName.endsWith('.pdf')) {
      if (!fileName.endsWith('.pdf')) fileName += '.pdf';
    } else {
      fileName += '.pdf';
    }

    final file = File('${downloadDir.path}/$fileName');
    await file.writeAsBytes(fileBytes);
    debugPrint('Saved file to ${file.path}, opening...');
    final openRes = await OpenFile.open(file.path);
    if (openRes.type != ResultType.done) {
      if (openRes.type == ResultType.noAppToOpen) {
        debugPrint('File saved to ${file.path} but no app found to open it.');
        return file.path;
      }
      throw Exception('Could not open file: ${openRes.message}');
    }
    return file.path;
  }

  Future<Directory> _getBestDownloadDirectory() async {
    if (Platform.isAndroid) {
      // 1. Try public Download directory
      final downloadDir = Directory('/storage/emulated/0/Download');
      if (await downloadDir.exists()) {
        try {
          final testFile = File('${downloadDir.path}/.test_write');
          await testFile.writeAsString('test');
          await testFile.delete();
          return downloadDir;
        } catch (e) {
          debugPrint('Cannot write to public Download directory: $e');
        }
      }

      // 2. Try user-accessible external files directory
      try {
        final extDir = await getExternalStorageDirectory();
        if (extDir != null) {
          return extDir;
        }
      } catch (e) {
        debugPrint('Failed to get external storage directory: $e');
      }
    } else if (Platform.isIOS) {
      // On iOS, use App Documents which can be made visible in Files app
      try {
        final docsDir = await getApplicationDocumentsDirectory();
        return docsDir;
      } catch (e) {
        debugPrint('Failed to get ApplicationDocumentsDirectory: $e');
      }
    }

    return await getTemporaryDirectory();
  }

  Future<List<dynamic>> fetchEmployeePayslips(int employeeId) async {
    debugPrint('PayrollApiService: fetchEmployeePayslips employeeId=$employeeId');
    try {
      final response = await _odooService.executeModelMethod(
        'hr.payslip',
        'search_read',
        [],
        kwargs: {
          'domain': [
            ['employee_id', '=', employeeId],
            ['state', '!=', 'cancel'],
          ],
          'fields': ['id', 'name', 'date_from', 'date_to', 'line_ids'],
          'order': 'date_to desc',
        },
      );
      return response is List ? response : [];
    } catch (e) {
      debugPrint('Error fetching employee payslips: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchPayslipLines(Map<String, dynamic> payslip) async {
    debugPrint('PayrollApiService: fetchPayslipLines payslipId=${payslip['id']}');
    try {
      final lineIds = payslip['line_ids'] as List<dynamic>? ?? [];
      if (lineIds.isNotEmpty) {
        final lines = await _odooService.executeModelMethod(
          'hr.payslip.line',
          'search_read',
          [],
          kwargs: {
            'domain': [
              ['id', 'in', lineIds],
            ],
            'fields': ['name', 'code', 'total', 'category_id', 'appears_on_payslip'],
          },
        );
        if (lines is List) {
          final updated = Map<String, dynamic>.from(payslip);
          updated['lines'] = lines.where((l) => l['appears_on_payslip'] != false).toList();
          return updated;
        }
      }
    } catch (e) {
      debugPrint('Error fetching payslip lines: $e');
    }
    return payslip;
  }
}
