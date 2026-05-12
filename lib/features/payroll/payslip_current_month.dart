import 'package:flutter/material.dart';

class CurrentMonthCard extends StatelessWidget {
  const CurrentMonthCard({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔹 TEMP functional values (hardcoded for now)
    double basicPay = 50000;
    double allowance = 5000;
    double deductions = 2000;

    // 🔹 Functional calculation
    double netSalary = basicPay + allowance - deductions;

    // 🔹 Current month
    final String currentMonth =
        "${DateTime.now().month}-${DateTime.now().year}";

    // 🔹 Simple formatter
    String format(double value) => "₹${value.toStringAsFixed(0)}";

    return Container(
      // margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text(
                'Current Month',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
              ),
              Text(
                currentMonth,
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Salary values
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _PayrollTile(label: 'Basic Pay', value: format(basicPay)),
              _PayrollTile(label: 'Allowance', value: format(allowance)),
              _PayrollTile(
                label: 'Deductions',
                value: format(deductions),
                isNegative: true,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Net salary
          Center(
            child: Column(
              children: [
                 Text(
                  'Net Salary',
                  style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                ),
                const SizedBox(height: 4),
                Text(
                  format(netSalary),
                  style:  TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 🔹 Local widget (same page)
class _PayrollTile extends StatelessWidget {
  final String label;
  final String value;
  final bool isNegative;

  const _PayrollTile({
    required this.label,
    required this.value,
    this.isNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isNegative ? Colors.red : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
