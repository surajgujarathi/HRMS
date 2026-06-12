import 'package:flutter_app/core/models/odoo_models.dart';
import 'package:flutter_app/features/profile/models/resume_line_model.dart';
import 'package:flutter_app/features/profile/models/skill_model.dart';

class Employee {
  final int id;
  final String? image1920;
  final String? name; // Standard Odoo name
  final ManyToOne? employeeId; // As requested: "Employee Name" Many2one
  final String? employeeCode;
  final String? jobTitle;
  final ManyToOne? userId;
  final ManyToOne? departmentId;
  final ManyToOne? jobId;
  final ManyToOne? empType;
  final String? workEmail;
  final String? mobilePhone;
  final String? workPhone;
  final DateTime? doj;
  final ManyToOne? companyId;
  final ManyToOne? parentId;
  final ManyToOne? coachId;
  final bool active;
  final List<int> attendanceIds;
  final List<int> categoryIds;

  // Work Information
  final ManyToOne? addressId;
  final ManyToOne? workLocationId;
  final ManyToOne? leaveManagerId;

  // Related lists
  final List<ResumeLine> resumeLines;
  final List<EmployeeSkill> skills;

  // Personal Information
  final String? gender;
  final DateTime? birthday;
  final String? marital;
  final String? bloodGroup;
  final String? identificationId;
  final String? passportId;
  final String? aadharNo;
  final String? panNo;

  // Emergency Contact
  final String? emergencyContact;
  final String? emergencyPhone;

  // Bank Details
  final String? bankName;
  final String? bankIfsc;
  final String? bankAccountId;

  // Address
  final String? address;
  final String? permanentAddress;

  Employee({
    required this.id,
    this.image1920,
    this.name,
    this.employeeId,
    this.employeeCode,
    this.jobTitle,
    this.userId,
    this.departmentId,
    this.jobId,
    this.empType,
    this.workEmail,
    this.mobilePhone,
    this.workPhone,
    this.doj,
    this.companyId,
    this.parentId,
    this.coachId,
    this.active = true,
    this.attendanceIds = const [],
    this.categoryIds = const [],
    this.addressId,
    this.workLocationId,
    this.leaveManagerId,
    this.resumeLines = const [],
    this.skills = const [],
    this.gender,
    this.birthday,
    this.marital,
    this.bloodGroup,
    this.identificationId,
    this.passportId,
    this.aadharNo,
    this.panNo,
    this.emergencyContact,
    this.emergencyPhone,
    this.bankName,
    this.bankIfsc,
    this.bankAccountId,
    this.address,
    this.permanentAddress,
  });

  static int _toInt(dynamic val) {
    if (val == null || val == false) return 0;
    if (val is int) return val;
    if (val is double) return val.toInt();
    return int.tryParse(val.toString()) ?? 0;
  }

  static List<int> _toIntList(dynamic val) {
    if (val is List) {
      return val.map((e) => _toInt(e)).toList();
    }
    return [];
  }

  static DateTime? _parseDate(dynamic val) {
    if (val == null || val == false || val.toString().isEmpty || val.toString().toLowerCase() == 'false' || val.toString().toLowerCase() == 'null') {
      return null;
    }
    final strVal = val.toString().trim();
    // Try standard ISO parsing
    final parsed = DateTime.tryParse(strVal);
    if (parsed != null) return parsed;

    // Try parsing dd-MM-yyyy format
    final parts = strVal.split('-');
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day != null && month != null && year != null) {
        if (year > 1000) {
          return DateTime(year, month, day);
        } else if (day > 1000) {
          return DateTime(day, month, year);
        }
      }
    }
    return null;
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: _toInt(json['id']),
      image1920: (json['image_1920'] is String && json['image_1920'].isNotEmpty)
          ? json['image_1920']
          : (json['profile_pic'] is String && json['profile_pic'].isNotEmpty)
              ? json['profile_pic']
              : null,
      name: json['name']?.toString(),
      employeeId: ManyToOne.tryParse(json['employee_id']),
      employeeCode: json['employee_code']?.toString(),
      jobTitle: json['job_title']?.toString(),
      userId: ManyToOne.tryParse(json['user_id']),
      departmentId: ManyToOne.tryParse(json['department_id']) ??
          (json['department_name'] != null && json['department_name'] != false
              ? ManyToOne(id: 0, name: json['department_name'].toString())
              : null),
      jobId: ManyToOne.tryParse(json['job_id']),
      empType: ManyToOne.tryParse(json['emp_type']) ??
          (json['employment_type'] != null && json['employment_type'] != false
              ? ManyToOne(id: 0, name: json['employment_type'].toString())
              : (json['employee_type'] != null && json['employee_type'] != false
                  ? ManyToOne(id: 0, name: json['employee_type'].toString())
                  : null)),
      workEmail: json['work_email']?.toString(),
      mobilePhone: json['mobile_phone']?.toString(),
      workPhone: json['work_phone']?.toString(),
      doj: _parseDate(json['doj']),
      companyId: ManyToOne.tryParse(json['company_id']) ??
          (json['company'] != null && json['company'] != false
              ? ManyToOne(id: 0, name: json['company'].toString())
              : (json['company_name'] != null && json['company_name'] != false
                  ? ManyToOne(id: 0, name: json['company_name'].toString())
                  : null)),
      parentId: ManyToOne.tryParse(json['parent_id']) ??
          (json['manager'] != null && json['manager'] != false
              ? ManyToOne(id: 0, name: json['manager'].toString())
              : null),
      coachId: ManyToOne.tryParse(json['coach_id']) ??
          (json['coach'] != null && json['coach'] != false
              ? ManyToOne(id: 0, name: json['coach'].toString())
              : (json['coach_name'] != null && json['coach_name'] != false
                  ? ManyToOne(id: 0, name: json['coach_name'].toString())
                  : null)),
      active: json['active'] is bool ? json['active'] : true,
      attendanceIds: _toIntList(json['attendance_id']),
      categoryIds: _toIntList(json['category_ids']),
      addressId: ManyToOne.tryParse(json['address_id']),
      workLocationId: ManyToOne.tryParse(json['work_location_id']) ??
          (json['work_location_name'] != null && json['work_location_name'] != false
              ? ManyToOne(id: 0, name: json['work_location_name'].toString())
              : (json['work_location'] != null && json['work_location'] != false
                  ? ManyToOne(id: 0, name: json['work_location'].toString())
                  : null)),
      leaveManagerId: ManyToOne.tryParse(json['leave_manager_id']),
      resumeLines: (json['resume_line_ids'] is List)
          ? (json['resume_line_ids'] as List)
              .map((e) => ResumeLine.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      skills: (json['employee_skill_ids'] is List)
          ? (json['employee_skill_ids'] as List)
              .map((e) => EmployeeSkill.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      gender: json['gender']?.toString(),
      birthday: _parseDate(json['birthday']),
      marital: json['marital']?.toString(),
      bloodGroup: json['blood_group']?.toString(),
      identificationId: json['identification_id']?.toString(),
      passportId: json['passport_id']?.toString(),
      aadharNo: json['aadhar_no']?.toString(),
      panNo: json['pan_no']?.toString(),
      emergencyContact: json['emergency_contact']?.toString(),
      emergencyPhone: json['emergency_phone']?.toString(),
      bankName: json['bank_name']?.toString(),
      bankIfsc: json['bank_ifsc']?.toString(),
      bankAccountId: json['bank_account_id']?.toString(),
      address: json['address']?.toString(),
      permanentAddress: json['permanent_street'] != null && json['permanent_street'] != false
          ? json['permanent_street'].toString()
          : (json['permanent_address'] != null && json['permanent_address'] != false
              ? json['permanent_address'].toString()
              : (json['x_permanent_address'] != null && json['x_permanent_address'] != false
                  ? json['x_permanent_address'].toString()
                  : null)),
    );
  }
}
