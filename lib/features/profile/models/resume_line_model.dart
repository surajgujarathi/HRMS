import 'package:flutter_app/core/models/odoo_models.dart';

class ResumeLine {
  final int id;
  final String name;
  final ManyToOne? lineTypeId;
  final DateTime? dateStart;
  final DateTime? dateEnd;
  final String? displayType;
  final String? description;

  ResumeLine({
    required this.id,
    required this.name,
    this.lineTypeId,
    this.dateStart,
    this.dateEnd,
    this.displayType,
    this.description,
  });

  static int _toInt(dynamic val) {
    if (val == null || val == false) return 0;
    if (val is int) return val;
    if (val is double) return val.toInt();
    return int.tryParse(val.toString()) ?? 0;
  }

  factory ResumeLine.fromJson(Map<String, dynamic> json) {
    return ResumeLine(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      lineTypeId: ManyToOne.tryParse(json['line_type_id']),
      dateStart: json['date_start'] != null && json['date_start'] != false
          ? DateTime.tryParse(json['date_start'].toString())
          : null,
      dateEnd: json['date_end'] != null && json['date_end'] != false
          ? DateTime.tryParse(json['date_end'].toString())
          : null,
      displayType: json['display_type']?.toString(),
      description: json['description']?.toString(),
    );
  }
}
