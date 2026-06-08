import 'package:flutter/material.dart';
import 'package:flutter_app/core/constants/app_colors.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

class TaxPlannerPage extends StatefulWidget {
  const TaxPlannerPage({super.key});

  @override
  State<TaxPlannerPage> createState() => _TaxPlannerPageState();
}

class _TaxPlannerPageState extends State<TaxPlannerPage> {
  // Controllers
  final ctcCtrl = TextEditingController();
  final hraCtrl = TextEditingController();
  final rentCtrl = TextEditingController();
  final sec80cCtrl = TextEditingController();
  final sec80dCtrl = TextEditingController();

  String regime = 'Old';
  double yearlyTax = 0;
  double monthlyTds = 0;

  /// ---------------- TAX CALCULATION ----------------
  void calculateTax() {
    final ctc = double.tryParse(ctcCtrl.text) ?? 0;
    final hra = double.tryParse(hraCtrl.text) ?? 0;
    final rent = double.tryParse(rentCtrl.text) ?? 0;
    final sec80c = double.tryParse(sec80cCtrl.text) ?? 0;
    final sec80d = double.tryParse(sec80dCtrl.text) ?? 0;

    double taxableIncome = ctc;

    if (regime == 'Old') {
      final hraExemption = (rent - (0.1 * ctc)).clamp(0, hra);
      taxableIncome -= hraExemption;
      taxableIncome -= sec80c.clamp(0, 150000);
      taxableIncome -= sec80d.clamp(0, 25000);
    } else {
      taxableIncome -= 50000; // standard deduction
    }

    yearlyTax = _calculateSlabTax(taxableIncome);
    monthlyTds = yearlyTax / 12;

    setState(() {});
  }

  double _calculateSlabTax(double income) {
    double tax = 0;

    if (income <= 250000) return 0;

    if (income > 250000) {
      tax += (income.clamp(250001, 500000) - 250000) * 0.05;
    }
    if (income > 500000) {
      tax += (income.clamp(500001, 1000000) - 500000) * 0.20;
    }
    if (income > 1000000) {
      tax += (income - 1000000) * 0.30;
    }

    return tax * 1.04; // 4% cess
  }

  /// ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.tax_planner),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _card(
              context: context,
              title: l10n.tax_regime,
              child: DropdownButtonFormField(
                value: regime,
                dropdownColor: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                items: [
                  DropdownMenuItem(value: 'Old', child: Text(l10n.old_regime)),
                  DropdownMenuItem(value: 'New', child: Text(l10n.new_regime)),
                ],
                onChanged: (v) => setState(() => regime = v!),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),

            _card(
              context: context,
              title: l10n.salary_details,
              child: _input(context, l10n.annual_ctc, ctcCtrl),
            ),

            if (regime == 'Old') ...[
              _card(
                context: context,
                title: 'HRA',
                child: Column(
                  children: [
                    _input(context, l10n.hra_received, hraCtrl),
                    _input(context, l10n.rent_paid_yearly, rentCtrl),
                  ],
                ),
              ),
              _card(
                context: context,
                title: l10n.deductions,
                child: Column(
                  children: [
                    _input(context, l10n.section_80c, sec80cCtrl),
                    _input(context, l10n.section_80d, sec80dCtrl),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: calculateTax,
                child: Text(l10n.calculate_tax, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 20),

            _resultTile(context, l10n.yearly_tax, '₹${yearlyTax.toStringAsFixed(0)}'),
            _resultTile(context, l10n.monthly_tds, '₹${monthlyTds.toStringAsFixed(0)}'),
          ],
        ),
      ),
    );
  }

  /// ---------------- COMPONENTS ----------------
  Widget _card({required BuildContext context, required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
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
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600, 
              fontSize: 15,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _input(BuildContext context, String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).dividerTheme.color ?? Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _resultTile(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label, 
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), 
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600, 
              fontSize: 18,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
