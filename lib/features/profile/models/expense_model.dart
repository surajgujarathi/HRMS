import 'package:flutter_app/core/models/odoo_models.dart';

class ExpenseModel {
  final int id;
  final String name;
  final ManyToOne? productId;
  final double totalAmountCurrency;
  final ManyToOne? currencyId;
  final List<int> taxIds;
  final double taxAmountCurrency;
  final ManyToOne? employeeId;
  final String paymentMode; // 'own_account' or 'company_account'
  final ManyToOne? vendorId;
  final DateTime? date;
  final String? description;
  final String state; // 'draft', 'reported', 'approved', 'done', 'refused'

  ExpenseModel({
    required this.id,
    required this.name,
    this.productId,
    this.totalAmountCurrency = 0.0,
    this.currencyId,
    this.taxIds = const [],
    this.taxAmountCurrency = 0.0,
    this.employeeId,
    this.paymentMode = 'own_account',
    this.vendorId,
    this.date,
    this.description,
    this.state = 'draft',
  });

  static int _toInt(dynamic val) {
    if (val == null || val == false) return 0;
    if (val is int) return val;
    return int.tryParse(val.toString()) ?? 0;
  }

  static double _toDouble(dynamic val) {
    if (val == null || val == false) return 0.0;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      productId: ManyToOne.tryParse(json['product_id']),
      totalAmountCurrency: _toDouble(json['total_amount_currency']),
      currencyId: ManyToOne.tryParse(json['currency_id']),
      taxIds: json['tax_ids'] is List ? List<int>.from(json['tax_ids']) : [],
      taxAmountCurrency: _toDouble(json['tax_amount_currency']),
      employeeId: ManyToOne.tryParse(json['employee_id']),
      paymentMode: json['payment_mode']?.toString() ?? 'own_account',
      vendorId: ManyToOne.tryParse(json['vendor_id']),
      date: json['date'] != null && json['date'] != false
          ? DateTime.tryParse(json['date'].toString())
          : null,
      description: json['description']?.toString(),
      state: json['state']?.toString() ?? 'draft',
    );
  }
}
