import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:flutter_app/features/maintenance/models/maintenance_equipment.dart';
import 'package:flutter_app/network/odoo_service.dart';
import 'package:flutter_app/core/utils/shared_pref.dart';
import 'package:flutter_app/core/constants/api_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum MaintenanceStatus { initial, loading, success, failure, submitting, submitted }

class MaintenanceState extends Equatable {
  final MaintenanceStatus status;
  final List<MaintenanceEquipment> equipments;
  final String? errorMessage;
  final String? employeeName;
  
  // Master data for form
  final List<dynamic> categories;
  final List<dynamic> companies;
  final List<dynamic> teams;
  final List<dynamic> departments;
  final List<dynamic> employees;
  final List<dynamic> vendors;
  final List<dynamic> technicians;

  const MaintenanceState({
    this.status = MaintenanceStatus.initial,
    this.equipments = const [],
    this.errorMessage,
    this.employeeName,
    this.categories = const [],
    this.companies = const [],
    this.teams = const [],
    this.departments = const [],
    this.employees = const [],
    this.vendors = const [],
    this.technicians = const [],
  });

  MaintenanceState copyWith({
    MaintenanceStatus? status,
    List<MaintenanceEquipment>? equipments,
    String? errorMessage,
    String? employeeName,
    List<dynamic>? categories,
    List<dynamic>? companies,
    List<dynamic>? teams,
    List<dynamic>? departments,
    List<dynamic>? employees,
    List<dynamic>? vendors,
    List<dynamic>? technicians,
  }) {
    return MaintenanceState(
      status: status ?? this.status,
      equipments: equipments ?? this.equipments,
      errorMessage: errorMessage ?? this.errorMessage,
      employeeName: employeeName ?? this.employeeName,
      categories: categories ?? this.categories,
      companies: companies ?? this.companies,
      teams: teams ?? this.teams,
      departments: departments ?? this.departments,
      employees: employees ?? this.employees,
      vendors: vendors ?? this.vendors,
      technicians: technicians ?? this.technicians,
    );
  }

  @override
  List<Object?> get props => [
        status,
        equipments,
        errorMessage,
        employeeName,
        categories,
        companies,
        teams,
        departments,
        employees,
        vendors,
        technicians,
      ];
}

class MaintenanceCubit extends Cubit<MaintenanceState> {
  final OdooService _odooService = OdooService(ApiConfig.baseUrl);

  MaintenanceCubit() : super(const MaintenanceState());

  Future<void> fetchAssignedEquipment() async {
    emit(state.copyWith(status: MaintenanceStatus.loading));
    try {
      final prefs = SharedPref();
      final sessionData = await prefs.getObject('session');
      if (sessionData != null) {
        final session = OdooSession.fromJson(sessionData);
        _odooService.setSession(session);
      }
      
      final empIdStr = await prefs.getString('employee_id');
      final deptIdStr = await prefs.getString('department_id');
      final employeeData = await prefs.getObject('employee_data');
      
      int? employeeId = int.tryParse(empIdStr ?? '');
      int? departmentId = int.tryParse(deptIdStr ?? '');
      String? employeeName;
      
      if (employeeData != null && employeeData is Map) {
        debugPrint('MaintenanceCubit: Full Employee Data: $employeeData');
        employeeName = employeeData['name'];
        final dept = employeeData['department_id'];
        if (dept != null && dept != false) {
          if (dept is List && dept.isNotEmpty) {
            departmentId = dept[0] is int ? dept[0] : int.tryParse(dept[0].toString());
          } else if (dept is Map) {
            departmentId = dept['id'];
          } else if (dept is int) {
            departmentId = dept;
          }
        }
      }
      
      debugPrint('MaintenanceCubit: fetchAssignedEquipment employeeId=$employeeId departmentId=$departmentId');
      
      final response = await _odooService.fetchAssignedEquipment(
        employeeId: employeeId,
        departmentId: departmentId,
      );
      final equipments = response.map((e) => MaintenanceEquipment.fromJson(e)).toList();
      
      emit(state.copyWith(
        status: MaintenanceStatus.success,
        equipments: equipments,
        employeeName: employeeName,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MaintenanceStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> fetchMasterData() async {
    try {
      final prefs = SharedPref();
      final sessionData = await prefs.getObject('session');
      if (sessionData != null) {
        final session = OdooSession.fromJson(sessionData);
        _odooService.setSession(session);
      }
      
      final categories = await _odooService.fetchEquipmentCategories();
      final companies = await _odooService.fetchCompanies();
      final teams = await _odooService.fetchMaintenanceTeams();
      final departments = await _odooService.fetchDepartments();
      final employees = await _odooService.fetchEmployees();
      final vendors = await _odooService.fetchVendors();
      
      emit(state.copyWith(
        categories: categories,
        companies: companies,
        teams: teams,
        departments: departments,
        employees: employees,
        vendors: vendors,
      ));
    } catch (e) {
      debugPrint('Error fetching master data: $e');
    }
  }

  Future<void> createEquipment(Map<String, dynamic> data) async {
    emit(state.copyWith(status: MaintenanceStatus.submitting));
    try {
      final prefs = SharedPref();
      final sessionData = await prefs.getObject('session');
      if (sessionData != null) {
        final session = OdooSession.fromJson(sessionData);
        _odooService.setSession(session);
      }
      
      await _odooService.createEquipment(data);
      emit(state.copyWith(status: MaintenanceStatus.submitted));
      fetchAssignedEquipment(); // Refresh list
    } catch (e) {
      emit(state.copyWith(
        status: MaintenanceStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
