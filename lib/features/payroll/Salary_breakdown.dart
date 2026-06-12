import 'package:flutter/material.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

class SalaryBreakdownCard extends StatelessWidget {
  final Map<String, dynamic>? payslipData;
  final bool showSalary;

  const SalaryBreakdownCard({super.key, this.payslipData, this.showSalary = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    double basicPay = 0;
    double hra = 0;
    double conveyance = 0;
    double professionalTax = 0;
    double incomeTax = 0;

    double totalEarnings = 0;
    double totalDeductions = 0;
    double netSalary = 0;

    if (payslipData != null && payslipData!.containsKey('lines')) {
      final lines = payslipData!['lines'] as List<dynamic>;
      for (final line in lines) {
        final code = line['code']?.toString().toUpperCase() ?? '';
        final name = line['name']?.toString().toLowerCase() ?? '';
        final total = (line['total'] is num) ? (line['total'] as num).toDouble() : 0.0;

        if (code == 'BASIC' || code == 'BASIC_SALARY' || name.contains('basic')) {
          basicPay = total;
        } else if (code == 'HRA') {
          hra = total;
        } else if (name.contains('conveyance') || code == 'CONV') {
          conveyance = total;
        } else if (name.contains('professional tax') || code == 'PT') {
          professionalTax = total;
        } else if (name.contains('income tax') || name.contains('tds') || code == 'IT' || code == 'TDS') {
          incomeTax = total;
        } else if (code == 'NET') {
          netSalary = total;
        } else {
          final category = line['category_id'];
          if (category is List && category.length > 1) {
            final catName = category[1].toString().toLowerCase();
            if (catName.contains('deduction') || code.contains('DED')) {
              totalDeductions += total;
            } else if (catName.contains('allowance') || catName.contains('earning') || code.contains('ALW')) {
              totalEarnings += total;
            }
          }
        }
      }

      double rawEarnings = basicPay + totalEarnings + hra + conveyance;
      double rawDeductions = totalDeductions + professionalTax + incomeTax;

      if (rawEarnings < 0) {
        totalEarnings = 0.0;
        basicPay = 0.0;
        hra = 0.0;
        conveyance = 0.0;
      } else {
        totalEarnings = rawEarnings;
        basicPay = basicPay.abs();
        hra = hra.abs();
        conveyance = conveyance.abs();
      }

      totalDeductions = rawDeductions.abs();
      professionalTax = professionalTax.abs();
      incomeTax = incomeTax.abs();

      netSalary = (totalEarnings - totalDeductions).abs();
    } else {
      basicPay = 0;
      hra = 0;
      conveyance = 0;
      professionalTax = 0;
      incomeTax = 0;
      totalEarnings = 0;
      totalDeductions = 0;
      netSalary = 0;
    }

    String format(double value) => "₹${value.toStringAsFixed(0)}";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.salary_structure_breakdown,
            style: const TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 20),

          // Earnings Section
          _buildSectionHeader(AppLocalizations.of(context)!.earnings, format(totalEarnings), Colors.green),
          const SizedBox(height: 10),
          _buildItemRow(AppLocalizations.of(context)!.basic_pay, basicPay, totalEarnings, const Color(0xFF4e54c8)),
          if (hra > 0) _buildItemRow(AppLocalizations.of(context)!.house_rent_allowance, hra, totalEarnings, const Color(0xFF4e54c8)),
          if (conveyance > 0) _buildItemRow(AppLocalizations.of(context)!.conveyance_allowance, conveyance, totalEarnings, const Color(0xFF4e54c8)),

          const SizedBox(height: 24),
          
          // Deductions Section
          _buildSectionHeader(AppLocalizations.of(context)!.deductions.toUpperCase(), '- ${format(totalDeductions)}', Colors.red),
          const SizedBox(height: 10),
          if (professionalTax > 0) _buildItemRow(AppLocalizations.of(context)!.professional_tax, professionalTax, totalDeductions, Colors.redAccent, isDeduction: true),
          if (incomeTax > 0) _buildItemRow(AppLocalizations.of(context)!.income_tax, incomeTax, totalDeductions, Colors.redAccent, isDeduction: true),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(height: 1, thickness: 1),
          ),

          // Total Net Pay
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.take_home_salary,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4e54c8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  showSalary ? format(netSalary) : '₹ ••••••',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF4e54c8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String totalValue, Color totalColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: Colors.grey.shade500,
            letterSpacing: 1.0,
          ),
        ),
        Text(
          showSalary ? totalValue : (title.contains('DEDUCTIONS') ? '- ₹ •••••' : '₹ •••••'),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: totalColor,
          ),
        ),
      ],
    );
  }

  Widget _buildItemRow(String label, double value, double total, Color barColor, {bool isDeduction = false}) {
    final ratio = total > 0 ? (value / total) : 0.0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                showSalary 
                    ? "${isDeduction ? '-' : ''}₹${value.toStringAsFixed(0)}"
                    : "${isDeduction ? '-' : ''}₹ ••••",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 4,
              width: double.infinity,
              color: barColor.withOpacity(0.1),
              child: Row(
                children: [
                  Expanded(
                    flex: (ratio * 100).toInt(),
                    child: Container(color: barColor),
                  ),
                  Expanded(
                    flex: ((1.0 - ratio) * 100).toInt(),
                    child: Container(color: Colors.transparent),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
