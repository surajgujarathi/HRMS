import 'dart:io';
import 'dart:convert';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/core/constants/app_images.dart';
import 'package:flutter_app/l10n/app_localizations.dart';
import 'package:flutter_app/features/payroll/presentation/payslip_download_wizard_dialog.dart';
import 'package:flutter_app/features/payroll/payslip_current_month.dart';
import 'package:flutter_app/features/payroll/Salary_breakdown.dart';
import 'package:flutter_app/features/profile/cubit/profile_cubit.dart';
import 'package:flutter_app/routes.dart';
import 'package:flutter_app/network/payroll_api_service.dart';

class PayrollScreen extends StatefulWidget {
  const PayrollScreen({super.key});

  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _payslipData;
  List<dynamic> _allPayslips = [];
  int? _selectedPayslipId;
  PayrollApiService? _apiService;
  bool _showSalary = false;

  @override
  void initState() {
    super.initState();
    _loadDynamicData();
  }

  Future<void> _loadDynamicData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final api = await PayrollApiService.create();
      _apiService = api;
      final profileState = context.read<ProfileCubit>().state;
      final employeeId = profileState.employee?.id;
      if (employeeId != null) {
        final payslips = await api.fetchEmployeePayslips(employeeId);
        Map<String, dynamic>? data;

        if (payslips.isNotEmpty) {
          final latest = payslips.first;
          data = await api.fetchPayslipLines(latest);
        }

        if (data == null) {
          final contract = await api.fetchEmployeeContractDetails(employeeId);
          if (contract != null) {
            final wage = (contract['wage'] is num) ? (contract['wage'] as num).toDouble() : 0.0;
            data = {
              'lines': [
                {
                  'code': 'BASIC',
                  'name': 'Basic Pay',
                  'total': wage,
                }
              ]
            };
          }
        }
        if (mounted) {
          setState(() {
            _allPayslips = payslips;
            if (payslips.isNotEmpty) {
              _selectedPayslipId = payslips.first['id'];
            }
            _payslipData = data;
          });
          if (data != null && data['lines'] != null) {
            debugPrint('PAYSLIP_DEBUG_LINES: ${jsonEncode(data['lines'])}');
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading dynamic payslip details: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onPayslipChanged(int? payslipId) async {
    if (payslipId == null || _apiService == null || payslipId == _selectedPayslipId) return;
    setState(() {
      _selectedPayslipId = payslipId;
      _isLoading = true;
    });
    try {
      final payslip = _allPayslips.firstWhere((p) => p['id'] == payslipId);
      final detailed = await _apiService!.fetchPayslipLines(payslip);
      if (mounted) {
        setState(() {
          _payslipData = detailed;
        });
        if (detailed != null && detailed['lines'] != null) {
          debugPrint('PAYSLIP_DEBUG_LINES: ${jsonEncode(detailed['lines'])}');
        }
      }
    } catch (e) {
      debugPrint('Error switching payslip: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildMenuCard(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade100,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4e54c8).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon, 
                    color: const Color(0xFF4e54c8), 
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 14.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade500, 
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios, 
                  size: 13, 
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final profileState = context.read<ProfileCubit>().state;
    final employeeName = profileState.employee?.name ?? 'Employee';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.my_pay,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).colorScheme.onSurface),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Premium Custom Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.hello(employeeName),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: isDarkMode ? Colors.white : Colors.black87,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context)!.manage_payslips_declarations,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                 
                ],
              ),
              const SizedBox(height: 24),

              if (!_isLoading && _allPayslips.isNotEmpty) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: DropdownButtonFormField<int>(
                    value: _selectedPayslipId,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.payslip_month,
                      labelStyle: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      filled: true,
                      fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: isDarkMode ? Colors.white24 : Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: isDarkMode ? Colors.white12 : Colors.grey.shade200),
                      ),
                    ),
                    dropdownColor: isDarkMode ? Colors.grey[900] : Colors.white,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    items: _allPayslips.map((p) {
                      return DropdownMenuItem<int>(
                        value: p['id'] as int,
                        child: Text(p['name'].toString()),
                      );
                    }).toList(),
                    onChanged: _onPayslipChanged,
                  ),
                ),
              ],

              if (_isLoading)
                Shimmer.fromColors(
                  baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                  highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
                  child: Column(
                    children: [
                      Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 240,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                if (_payslipData == null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.amber),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.no_active_contract_or_payslip,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDarkMode ? Colors.amber[200] : Colors.amber[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                // 1. Current Month Salary Card
                CurrentMonthCard(
                  payslipData: _payslipData,
                  showSalary: _showSalary,
                  onToggleShowSalary: () {
                    setState(() {
                      _showSalary = !_showSalary;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // 2. Salary Breakdown Card
                SalaryBreakdownCard(
                  payslipData: _payslipData,
                  showSalary: _showSalary,
                ),
              ],
              const SizedBox(height: 24),

              // 3. Odoo Payroll Services Actions
              Text(
                AppLocalizations.of(context)!.payroll_services,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              
              _buildMenuCard(
                context,
                AppLocalizations.of(context)!.income_tax_declarations,
                AppLocalizations.of(context)!.income_tax_declarations_desc,
                Icons.description_outlined,
                () => Navigator.pushNamed(context, Routes.itDeclarations),
              ),
              // _buildMenuCard(
              //   context,
              //   'Tax Regime Comparison',
              //   'Compare savings under Old vs New tax slabs',
              //   Icons.compare_arrows_rounded,
              //   () => Navigator.pushNamed(context, Routes.taxComparison),
              // ),
              _buildMenuCard(
                context,
                AppLocalizations.of(context)!.download_payslip,
                AppLocalizations.of(context)!.payslip_download_desc,
                Icons.file_download_outlined,
                () {
                  showDialog(
                    context: context,
                    builder: (context) => const PayslipDownloadWizardDialog(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
