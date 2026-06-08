import 'package:flutter/material.dart';
import 'package:flutter_app/core/constants/app_colors.dart';

class CurrentMonthCard extends StatelessWidget {
  final Map<String, dynamic>? payslipData;

  const CurrentMonthCard({super.key, this.payslipData});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    double basicPay = 0;
    double allowance = 0;
    double deductions = 0;
    double netSalary = 0;

    double hra = 0;
    double conveyance = 0;
    double professionalTax = 0;
    double incomeTax = 0;

    if (payslipData != null && payslipData!.containsKey('lines')) {
      final lines = payslipData!['lines'] as List<dynamic>;
      for (final line in lines) {
        final code = line['code']?.toString().toUpperCase() ?? '';
        final name = line['name']?.toString().toLowerCase() ?? '';
        final total = (line['total'] is num) ? (line['total'] as num).toDouble() : 0.0;

        if (code == 'BASIC' || code == 'BASIC_SALARY' || name.contains('basic')) {
          basicPay = total;
        } else if (code == 'NET') {
          netSalary = total;
        } else if (code == 'HRA') {
          hra = total;
        } else if (name.contains('conveyance') || code == 'CONV') {
          conveyance = total;
        } else if (name.contains('professional tax') || code == 'PT') {
          professionalTax = total;
        } else if (name.contains('income tax') || name.contains('tds') || code == 'IT' || code == 'TDS') {
          incomeTax = total;
        } else {
          final category = line['category_id'];
          if (category is List && category.length > 1) {
            final catName = category[1].toString().toLowerCase();
            if (catName.contains('deduction') || code.contains('DED')) {
              deductions += total;
            } else if (catName.contains('allowance') || catName.contains('earning') || code.contains('ALW')) {
              allowance += total;
            }
          }
        }
      }

      double rawEarnings = basicPay + allowance + hra + conveyance;
      double rawDeductions = deductions + professionalTax + incomeTax;

      if (rawEarnings < 0) {
        basicPay = 0.0;
        hra = 0.0;
        conveyance = 0.0;
        allowance = 0.0;
      } else {
        allowance = allowance + hra + conveyance;
        // Make sure individual components are positive for display when overall is positive
        basicPay = basicPay.abs();
        hra = hra.abs();
        conveyance = conveyance.abs();
        allowance = allowance.abs();
      }

      deductions = rawDeductions.abs();
      netSalary = ((rawEarnings < 0 ? 0.0 : rawEarnings) - deductions).abs();
    } else {
      basicPay = 0;
      allowance = 0;
      deductions = 0;
      netSalary = 0;
    }

    String currentMonth = "${DateTime.now().month}-${DateTime.now().year}";
    if (payslipData != null) {
      if (payslipData!.containsKey('date_to') && payslipData!['date_to'] != null) {
        try {
          final dateStr = payslipData!['date_to'].toString();
          final parsedDate = DateTime.parse(dateStr);
          currentMonth = "${parsedDate.month}-${parsedDate.year}";
        } catch (e) {
          debugPrint('Error parsing date_to: $e');
        }
      } else if (payslipData!.containsKey('name') && payslipData!['name'] != null) {
        currentMonth = payslipData!['name'].toString();
      }
    }
    String format(double value) => "₹${value.toStringAsFixed(0)}";

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: isDark 
              ? [const Color(0xFF1F1C2C), const Color(0xFF928DAB)] 
              :  [AppColors.indigo, AppColors.brightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF4e54c8)).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -50,
              top: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              currentMonth,
                              style: const TextStyle(
                                fontSize: 13, 
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        'ESTIMATED PAY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Net Salary',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    format(netSalary),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  Container(
                    height: 1,
                    color: Colors.white.withOpacity(0.15),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniCol('Basic Pay', format(basicPay), Colors.white),
                      _buildMiniCol('Allowance', format(allowance), Colors.white),
                      _buildMiniCol('Deductions', '- ${format(deductions)}', const Color(0xFFFF8A8A)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniCol(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
