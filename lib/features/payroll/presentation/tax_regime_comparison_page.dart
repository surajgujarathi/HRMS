import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/core/constants/app_colors.dart';
import 'package:flutter_app/features/payroll/cubit/tax_statement_cubit.dart';
import 'package:flutter_app/features/profile/cubit/profile_cubit.dart';
import 'package:flutter_app/network/payroll_api_service.dart';

class TaxRegimeComparisonPage extends StatefulWidget {
  const TaxRegimeComparisonPage({super.key});

  @override
  State<TaxRegimeComparisonPage> createState() => _TaxRegimeComparisonPageState();
}

class _TaxRegimeComparisonPageState extends State<TaxRegimeComparisonPage> {
  TaxStatementCubit? _cubit;
  PayrollApiService? _apiService;
  bool _initializing = true;

  int? _employeeId;

  // Form selections
  List<dynamic> _periods = [];
  int? _selectedPeriodId;
  String _selectedRegime = 'both';
  int _taxpayerAge = 30;
  String _residentialStatus = 'resident';
  int _parentAge = 60;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initService();
  }

  Future<void> _initService() async {
    try {
      _apiService = await PayrollApiService.create();
      _cubit = TaxStatementCubit(_apiService!);
      final profileState = context.read<ProfileCubit>().state;
      _employeeId = profileState.employee?.id;

      await _loadPeriods();
    } catch (e) {
      debugPrint('Error initializing PayrollApiService: $e');
    } finally {
      if (mounted) {
        setState(() {
          _initializing = false;
        });
      }
    }
  }

  Future<void> _loadPeriods() async {
    if (_apiService == null) return;
    setState(() => _isLoading = true);
    try {
      final periods = await _apiService!.fetchPayrollPeriods();
      setState(() {
        _periods = periods;
        if (_periods.isNotEmpty) {
          _selectedPeriodId = _periods.first['id'];
        }
      });
    } catch (e) {
      debugPrint('Error loading periods: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _compare() async {
    if (_selectedPeriodId == null || _employeeId == null || _apiService == null || _cubit == null) return;
    try {
      // 1. Create Odoo wizard
      final wizard = await _apiService!.createTaxStatementWizard({
        'employee_id': _employeeId,
        'taxpayer_age': _taxpayerAge,
        'residential_status': _residentialStatus,
        'parent_age': _parentAge,
        'period_id': _selectedPeriodId,
        'tax_regime': _selectedRegime,
      });

      final wizardId = wizard['id'] as int;

      // 2. Call comparison action
      await _cubit!.compareRegimes(wizardId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Comparison failed: $e'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    }
  }

  Widget _buildSummaryCard(String title, dynamic taxable, dynamic tax, Color accentColor) {
    final fmtTaxable = taxable != null ? '₹${taxable.toString()}' : 'N/A';
    final fmtTax = tax != null ? '₹${tax.toString()}' : 'N/A';

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accentColor.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: accentColor),
            ),
            const SizedBox(height: 12),
            Text(
              'Taxable Income:',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
            ),
            Text(
              fmtTaxable,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Tax Liability:',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
            ),
            Text(
              fmtTax,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_initializing || _cubit == null) {
      return Scaffold(
        backgroundColor: isDark ? Theme.of(context).scaffoldBackgroundColor : Colors.grey[50],
        appBar: AppBar(
          title: const Text('Tax Regime Comparison'),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.indigo),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? Theme.of(context).scaffoldBackgroundColor : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Tax Regime Comparison'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Settings form
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Planning Details',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<int>(
                    value: _selectedPeriodId,
                    decoration: const InputDecoration(labelText: 'Payroll Period'),
                    items: _periods.map((p) {
                      return DropdownMenuItem<int>(
                        value: p['id'] as int,
                        child: Text(p['name'].toString()),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedPeriodId = val),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    initialValue: _taxpayerAge.toString(),
                    decoration: const InputDecoration(labelText: 'Taxpayer Age'),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      final parsed = int.tryParse(val);
                      if (parsed != null) _taxpayerAge = parsed;
                    },
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: _residentialStatus,
                    decoration: const InputDecoration(labelText: 'Residential Status'),
                    items: const [
                      DropdownMenuItem(value: 'resident', child: Text('Resident')),
                      DropdownMenuItem(value: 'non-resident', child: Text('Non-Resident')),
                    ],
                    onChanged: (val) => setState(() => _residentialStatus = val!),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    initialValue: _parentAge.toString(),
                    decoration: const InputDecoration(labelText: 'Parent Age'),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      final parsed = int.tryParse(val);
                      if (parsed != null) _parentAge = parsed;
                    },
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brightBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isLoading ? null : _compare,
                      child: const Text(
                        'RUN COMPARISON',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            BlocBuilder<TaxStatementCubit, TaxStatementState>(
              bloc: _cubit!,
              builder: (context, state) {
                if (state.status == TaxStatementStatus.comparing) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.indigo));
                }

                if (state.comparisonResult.isEmpty) {
                  return const SizedBox.shrink();
                }

                final comparison = state.comparisonResult;
                final boolRegime = comparison['beneficial_regime'].toString().toUpperCase();
                final diff = comparison['regime_difference'] as dynamic ?? 0.0;

                return Column(
                  children: [
                    Row(
                      children: [
                        _buildSummaryCard(
                          'Old Regime',
                          comparison['taxable_old'],
                          comparison['tax_old'],
                          AppColors.brightBlue,
                        ),
                        const SizedBox(width: 12),
                        _buildSummaryCard(
                          'New Regime',
                          comparison['taxable_new'],
                          comparison['tax_new'],
                          AppColors.indigo,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Beneficial notification card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green.withOpacity(0.2), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.stars_rounded, color: Colors.green, size: 28),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Recommendation',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'The $boolRegime Regime is more beneficial. You will save ₹${diff.toString()} by selecting it.',
                                  style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
