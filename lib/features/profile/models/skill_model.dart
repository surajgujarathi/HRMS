import 'package:flutter_app/core/models/odoo_models.dart';

class EmployeeSkill {
  final int id;
  final ManyToOne? skillTypeId;
  final ManyToOne? skillId;
  final ManyToOne? skillLevelId;
  final int levelProgress;
  final int color;

  EmployeeSkill({
    required this.id,
    this.skillTypeId,
    this.skillId,
    this.skillLevelId,
    this.levelProgress = 0,
    this.color = 0,
  });

  static int _toInt(dynamic val) {
    if (val == null || val == false) return 0;
    if (val is int) return val;
    if (val is double) return val.toInt();
    return int.tryParse(val.toString()) ?? 0;
  }

  factory EmployeeSkill.fromJson(Map<String, dynamic> json) {
    return EmployeeSkill(
      id: _toInt(json['id']),
      skillTypeId: ManyToOne.tryParse(json['skill_type_id']),
      skillId: ManyToOne.tryParse(json['skill_id']),
      skillLevelId: ManyToOne.tryParse(json['skill_level_id']),
      levelProgress: _toInt(json['level_progress']),
      color: _toInt(json['color']),
    );
  }
}
