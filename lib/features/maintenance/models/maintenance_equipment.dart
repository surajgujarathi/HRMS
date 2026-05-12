import 'package:flutter_app/core/models/odoo_models.dart';

class MaintenanceEquipment {
  final int id;
  final String name;
  final ManyToOne? categoryId;
  final ManyToOne? companyId;
  final String? equipmentAssignTo; // 'employee', 'department', 'other'
  final ManyToOne? departmentId;
  final ManyToOne? employeeId;
  final ManyToOne? maintenanceTeamId;
  final ManyToOne? technicianUserId;
  final DateTime? scrapDate;
  final String? note; // HTML
  
  // Product Information
  final ManyToOne? partnerId;
  final String? partnerRef;
  final String? model;
  final String? serialNo;
  final String? compSerialNo;
  final DateTime? effectiveDate;
  final double? cost;
  final DateTime? warrantyDate;
  
  // Maintenance Information
  final double? expectedMtbf;
  final double? mtbf;
  final DateTime? estimatedNextFailure;
  final DateTime? latestFailureDate;
  final double? mttr;

  MaintenanceEquipment({
    required this.id,
    required this.name,
    this.categoryId,
    this.companyId,
    this.equipmentAssignTo,
    this.departmentId,
    this.employeeId,
    this.maintenanceTeamId,
    this.technicianUserId,
    this.scrapDate,
    this.note,
    this.partnerId,
    this.partnerRef,
    this.model,
    this.serialNo,
    this.compSerialNo,
    this.effectiveDate,
    this.cost,
    this.warrantyDate,
    this.expectedMtbf,
    this.mtbf,
    this.estimatedNextFailure,
    this.latestFailureDate,
    this.mttr,
  });

  factory MaintenanceEquipment.fromJson(Map<String, dynamic> json) {
    return MaintenanceEquipment(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      categoryId: ManyToOne.tryParse(json['category_id']),
      companyId: ManyToOne.tryParse(json['company_id']),
      equipmentAssignTo: json['equipment_assign_to']?.toString(),
      departmentId: ManyToOne.tryParse(json['department_id']),
      employeeId: ManyToOne.tryParse(json['employee_id']),
      maintenanceTeamId: ManyToOne.tryParse(json['maintenance_team_id']),
      technicianUserId: ManyToOne.tryParse(json['technician_user_id']),
      scrapDate: json['scrap_date'] != null && json['scrap_date'] != false 
          ? DateTime.tryParse(json['scrap_date'].toString()) 
          : null,
      note: json['note']?.toString(),
      partnerId: ManyToOne.tryParse(json['partner_id']),
      partnerRef: json['partner_ref']?.toString(),
      model: json['model']?.toString(),
      serialNo: json['serial_no']?.toString(),
      compSerialNo: json['comp_serial_no']?.toString(),
      effectiveDate: json['effective_date'] != null && json['effective_date'] != false 
          ? DateTime.tryParse(json['effective_date'].toString()) 
          : null,
      cost: (json['cost'] ?? 0.0).toDouble(),
      warrantyDate: json['warranty_date'] != null && json['warranty_date'] != false 
          ? DateTime.tryParse(json['warranty_date'].toString()) 
          : null,
      expectedMtbf: (json['expected_mtbf'] ?? 0.0).toDouble(),
      mtbf: (json['mtbf'] ?? 0.0).toDouble(),
      estimatedNextFailure: json['estimated_next_failure'] != null && json['estimated_next_failure'] != false 
          ? DateTime.tryParse(json['estimated_next_failure'].toString()) 
          : null,
      latestFailureDate: json['latest_failure_date'] != null && json['latest_failure_date'] != false 
          ? DateTime.tryParse(json['latest_failure_date'].toString()) 
          : null,
      mttr: (json['mttr'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category_id': categoryId?.id,
      'company_id': companyId?.id,
      'equipment_assign_to': equipmentAssignTo,
      'department_id': departmentId?.id,
      'employee_id': employeeId?.id,
      'maintenance_team_id': maintenanceTeamId?.id,
      'technician_user_id': technicianUserId?.id,
      'scrap_date': scrapDate?.toIso8601String().split('T')[0],
      'note': note,
      'partner_id': partnerId?.id,
      'partner_ref': partnerRef,
      'model': model,
      'serial_no': serialNo,
      'comp_serial_no': compSerialNo,
      'effective_date': effectiveDate?.toIso8601String().split('T')[0],
      'cost': cost,
      'warranty_date': warrantyDate?.toIso8601String().split('T')[0],
      'expected_mtbf': expectedMtbf,
      'mtbf': mtbf,
      'estimated_next_failure': estimatedNextFailure?.toIso8601String().split('T')[0],
      'latest_failure_date': latestFailureDate?.toIso8601String().split('T')[0],
      'mttr': mttr,
    };
  }
}
