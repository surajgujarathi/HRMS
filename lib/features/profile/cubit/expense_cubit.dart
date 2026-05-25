import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/core/utils/shared_pref.dart';
import 'package:flutter_app/network/odoo_service.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_app/features/profile/models/expense_model.dart';
import 'expense_state.dart';

class ExpenseCubit extends Cubit<ExpenseState> {
  ExpenseCubit() : super(ExpenseInitial());

  List<dynamic> products = [];
  List<dynamic> currencies = [];
  List<dynamic> taxes = [];
  List<dynamic> vendors = [];

  Future<void> fetchInitialData() async {
    try {
      final prefs = SharedPref();
      final baseUrl = await prefs.getString('baseUrl');
      final sessionData = await prefs.getObject('session');

      if (baseUrl == null || sessionData == null) return;

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
        dbName: sessionData['dbName']?.toString() ?? "",
        serverVersion: sessionData['serverVersion']?.toString() ?? "",
      );

      final odooService = OdooService(baseUrl, session: session);

      try {
        products = await odooService.fetchExpenseProducts();
        currencies = await odooService.fetchCurrencies();
        taxes = await odooService.fetchTaxes();
        vendors = await odooService.fetchVendors();
        debugPrint('Fetched ${products.length} products, ${currencies.length} currencies, ${taxes.length} taxes, ${vendors.length} vendors');
      } finally {
        odooService.close();
      }
    } catch (e) {
      debugPrint('Initial Data Fetch Error: $e');
    }
  }

  Future<void> fetchExpenses() async {
    emit(ExpenseLoading());

    try {
      final prefs = SharedPref();
      
      final baseUrl = await prefs.getString('baseUrl');
      final db = await prefs.getString('db');
      final employeeId = await prefs.getString('employee_id');
      final sessionData = await prefs.getObject('session');

      if (baseUrl == null || db == null || employeeId == null || sessionData == null) {
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
        final response = await odooService.fetchExpenses(int.parse(employeeId));
        debugPrint('Expense API Response: $response');
        
        final expenses = response
            .map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>))
            .toList();

        emit(ExpenseLoaded(expenses));
      } finally {
        odooService.close();
      }
    } catch (e) {
      debugPrint('Expense Fetch Error: $e');
      emit(ExpenseError(e.toString()));
    }
  }

  Future<bool> addExpense(Map<String, dynamic> data, {File? file}) async {
    try {
      emit(ExpenseLoading());
      debugPrint('Adding Expense with Payload: $data');
      final prefs = SharedPref();
      final baseUrl = await prefs.getString('baseUrl');
      final db = await prefs.getString('db');
      final employeeId = await prefs.getString('employee_id');
      final sessionData = await prefs.getObject('session');

      if (baseUrl == null || db == null || employeeId == null || sessionData == null) {
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
        data['employee_id'] = int.parse(employeeId);
        final expenseId = await odooService.createExpense(data);
        debugPrint('Created Expense ID: $expenseId');

        if (file != null && expenseId != 0) {
          await uploadReceipt(expenseId, file);
        }

        await fetchExpenses(); // Refresh list
        return true;
      } finally {
        odooService.close();
      }
    } catch (e) {
      debugPrint('Expense Create Error: $e');
      emit(ExpenseError(e.toString()));
      return false;
    }
  }

  Future<void> submitExpense(int id) async {
    try {
      debugPrint('Submitting Expense ID: $id');
      final prefs = SharedPref();
      final baseUrl = await prefs.getString('baseUrl');
      final sessionData = await prefs.getObject('session');

      if (baseUrl == null || sessionData == null) return;

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
        dbName: sessionData['dbName']?.toString() ?? "",
        serverVersion: sessionData['serverVersion']?.toString() ?? "",
      );

      final odooService = OdooService(baseUrl, session: session);

      try {
        await odooService.actionSubmitExpenses([id]);
        debugPrint('Expense Submitted successfully');
        fetchExpenses();
      } finally {
        odooService.close();
      }
    } catch (e) {
      debugPrint('Expense Submit Error: $e');
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> uploadReceipt(int expenseId, File file) async {
    try {
      debugPrint('Uploading Receipt for Expense ID: $expenseId');
      final bytes = await file.readAsBytes();
      final base64Content = base64Encode(bytes);
      final fileName = file.path.split('/').last;

      final prefs = SharedPref();
      final baseUrl = await prefs.getString('baseUrl');
      final sessionData = await prefs.getObject('session');

      if (baseUrl == null || sessionData == null) return;

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
        dbName: sessionData['dbName']?.toString() ?? "",
        serverVersion: sessionData['serverVersion']?.toString() ?? "",
      );

      final odooService = OdooService(baseUrl, session: session);

      try {
        await odooService.uploadAttachment(
          name: fileName,
          base64Content: base64Content,
          resModel: 'hr.expense',
          resId: expenseId,
        );
        debugPrint('Receipt uploaded successfully');
      } finally {
        odooService.close();
      }
    } catch (e) {
      debugPrint('Upload Receipt Error: $e');
    }
  }

  Future<void> splitExpense(int id) async {
    try {
      debugPrint('Splitting Expense ID: $id');
      final prefs = SharedPref();
      final baseUrl = await prefs.getString('baseUrl');
      final sessionData = await prefs.getObject('session');

      if (baseUrl == null || sessionData == null) return;

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
        dbName: sessionData['dbName']?.toString() ?? "",
        serverVersion: sessionData['serverVersion']?.toString() ?? "",
      );

      final odooService = OdooService(baseUrl, session: session);

      try {
        await odooService.actionSplitWizard(id);
        debugPrint('Expense split wizard opened/processed');
        fetchExpenses();
      } finally {
        odooService.close();
      }
    } catch (e) {
      debugPrint('Split Expense Error: $e');
    }
  }
}
