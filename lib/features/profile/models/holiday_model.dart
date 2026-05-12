import 'package:flutter_app/core/models/odoo_models.dart';

class HolidayModel {
  final int id;
  final String name;
  final ManyToOne? calendarId;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final ManyToOne? workEntryTypeId;

  HolidayModel({
    required this.id,
    required this.name,
    this.calendarId,
    this.dateFrom,
    this.dateTo,
    this.workEntryTypeId,
  });

  static int _toInt(dynamic val) {
    if (val == null || val == false) return 0;
    if (val is int) return val;
    return int.tryParse(val.toString()) ?? 0;
  }

  factory HolidayModel.fromJson(Map<String, dynamic> json) {
    return HolidayModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      calendarId: ManyToOne.tryParse(json['calendar_id']),
      dateFrom: json['date_from'] != null && json['date_from'] != false
          ? DateTime.tryParse(json['date_from'].toString())
          : null,
      dateTo: json['date_to'] != null && json['date_to'] != false
          ? DateTime.tryParse(json['date_to'].toString())
          : null,
      workEntryTypeId: ManyToOne.tryParse(json['work_entry_type_id']),
    );
  }
}
