import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/core/constants/app_colors.dart';
import 'package:flutter_app/features/payroll/cubit/it_declaration_cubit.dart';
import 'package:flutter_app/features/profile/cubit/profile_cubit.dart';
import 'package:flutter_app/network/payroll_api_service.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

class ItDeclarationPage extends StatefulWidget {
  const ItDeclarationPage({super.key});

  @override
  State<ItDeclarationPage> createState() => _ItDeclarationPageState();
}

class _ItDeclarationPageState extends State<ItDeclarationPage> {
  ItDeclarationCubit? _cubit;
  PayrollApiService? _apiService;
  int? _employeeId;
  bool _initializing = true;

  @override
  void initState() {
    super.initState();
    _initService();
  }

  Future<void> _initService() async {
    try {
      final apiService = await PayrollApiService.create();
      _apiService = apiService;
      _cubit = ItDeclarationCubit(apiService);
      final profileState = context.read<ProfileCubit>().state;
      _employeeId = profileState.employee?.id;

      if (_employeeId != null) {
        await _cubit!.loadInitialData(_employeeId!);
      }
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

  void _showCreateDialog() {
    int? selectedPeriodId;
    String selectedRegime = 'new';
    final amountController = TextEditingController();

    if (_cubit!.state.periods.isNotEmpty) {
      selectedPeriodId = _cubit!.state.periods.first['id'];
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              backgroundColor: isDark ? const Color(0xFF1E1E2C) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.new_it_declaration,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.select_period_regime_info,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    DropdownButtonFormField<int>(
                      value: selectedPeriodId,
                      decoration: InputDecoration(
                        labelText: l10n.payroll_period,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      items: _cubit!.state.periods.map<DropdownMenuItem<int>>((p) {
                        return DropdownMenuItem<int>(
                          value: p['id'] as int,
                          child: Text(p['name'].toString()),
                        );
                      }).toList(),
                      onChanged: (val) => setDialogState(() => selectedPeriodId = val),
                    ),
                    const SizedBox(height: 16),
                    
                    Text(
                      l10n.tax_regime,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setDialogState(() => selectedRegime = 'new'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: selectedRegime == 'new'
                                    ? const Color(0xFF4e54c8)
                                    : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selectedRegime == 'new'
                                      ? const Color(0xFF4e54c8)
                                      : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade300),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  l10n.new_regime,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: selectedRegime == 'new'
                                        ? Colors.white
                                        : (isDark ? Colors.white70 : Colors.black87),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setDialogState(() => selectedRegime = 'old'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: selectedRegime == 'old'
                                    ? const Color(0xFF4e54c8)
                                    : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selectedRegime == 'old'
                                      ? const Color(0xFF4e54c8)
                                      : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade300),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  l10n.old_regime,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: selectedRegime == 'old'
                                        ? Colors.white
                                        : (isDark ? Colors.white70 : Colors.black87),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.investment_amount_inr,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey.shade600,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          child: Text(l10n.cancel, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (selectedPeriodId != null && _employeeId != null) {
                              final amountVal = double.tryParse(amountController.text) ?? 0.0;
                              _cubit!.createDeclaration({
                                'employee_id': _employeeId,
                                'period_id': selectedPeriodId,
                                'tax_regime': selectedRegime,
                                'total_investment': amountVal,
                                'state': 'draft',
                              }, _employeeId!);
                              Navigator.pop(dialogContext);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4e54c8),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          child: Text(l10n.create_label, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStateBadge(String state) {
    Color color;
    IconData icon;
    switch (state) {
      case 'submitted':
        color = Colors.green;
        icon = Icons.check_circle_rounded;
        break;
      default:
        color = Colors.orange;
        icon = Icons.hourglass_empty_rounded;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            state.toUpperCase(),
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMiniCard({required String title, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w500),
              ),
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final l10n = AppLocalizations.of(context)!;

    if (_initializing || _cubit == null) {
      return Scaffold(
        backgroundColor: isDark ? Theme.of(context).scaffoldBackgroundColor : Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          title: Text(l10n.income_tax_declarations, style: const TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF4e54c8)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? Theme.of(context).scaffoldBackgroundColor : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(l10n.income_tax_declarations, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        backgroundColor: const Color(0xFF4e54c8),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocConsumer<ItDeclarationCubit, ItDeclarationState>(
        bloc: _cubit!,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!), backgroundColor: AppColors.dangerRed),
            );
          }
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!), backgroundColor: Colors.green),
            );
          }
        },
        builder: (context, state) {
          if (state.status == ItDeclarationStatus.loading && state.declarations.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF4e54c8)));
          }

          double totalDeclared = 0.0;
          int totalSubmittedCount = 0;
          for (final d in state.declarations) {
            final double val = (d['total_investment'] is num) ? (d['total_investment'] as num).toDouble() : 0.0;
            totalDeclared += val;
            final String s = d['state'] is String ? d['state'] as String : '';
            if (s == 'submitted') {
              totalSubmittedCount++;
            }
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top dashboard overview card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.indigo, AppColors.brightBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4e54c8).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.investment_overview,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.shield_outlined, color: Colors.white, size: 12),
                                SizedBox(width: 4),
                                Text(
                                  'IT Declarations',
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '₹${totalDeclared.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryMiniCard(
                              title: l10n.declarations_label,
                              value: '${state.declarations.length}',
                              icon: Icons.folder_open_outlined,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryMiniCard(
                              title: l10n.submitted_label,
                              value: '$totalSubmittedCount',
                              icon: Icons.check_circle_outline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (state.declarations.isEmpty) ...[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            l10n.no_it_declarations_found,
                            style: TextStyle(color: Colors.grey[600], fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.tap_plus_to_create,
                            style: TextStyle(color: Colors.grey[500], fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  Text(
                    l10n.active_submissions,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...state.declarations.map((dec) {
                    final decId = dec['id'] as int;
                    final periodName = (dec['period_id'] is List && (dec['period_id'] as List).length > 1)
                        ? dec['period_id'][1].toString()
                        : 'Unknown Period';
                    final taxRegime = dec['tax_regime'] is String ? dec['tax_regime'].toString().toUpperCase() : '';
                    final totalInv = (dec['total_investment'] is num) ? (dec['total_investment'] as num).toDouble() : 0.0;
                    final returnReason = dec['return_reason'] is String ? dec['return_reason'] as String : '';
                    final decState = dec['state'] is String ? dec['state'] as String : 'draft';
                    final isDraft = decState == 'draft';

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
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          iconColor: const Color(0xFF4e54c8),
                          collapsedIconColor: Colors.grey,
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  periodName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _buildStateBadge(decState),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4e54c8).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    taxRegime == 'OLD'
                                        ? l10n.old_regime
                                        : (taxRegime == 'NEW' ? l10n.new_regime : '$taxRegime Regime'),
                                    style: const TextStyle(
                                      color: Color(0xFF4e54c8),
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${l10n.total}: ₹${totalInv.toStringAsFixed(0)}',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(height: 16),
                                  const SizedBox(height: 8),
                                  if (returnReason.isNotEmpty) ...[
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      margin: const EdgeInsets.only(bottom: 16),
                                      decoration: BoxDecoration(
                                        color: AppColors.dangerRed.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.dangerRed.withOpacity(0.2)),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.warning_amber_rounded, color: AppColors.dangerRed, size: 20),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              '${l10n.returned_label}: $returnReason',
                                              style: const TextStyle(color: AppColors.dangerRed, fontSize: 12.5, fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  if (isDraft) ...[
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              elevation: 0,
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                            ),
                                            onPressed: () {
                                              _cubit!.submitDeclaration(decId, _employeeId!);
                                            },
                                            icon: const Icon(Icons.send_rounded, size: 16, color: Colors.white),
                                            label: Text(l10n.submit, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                  ],

                                  Row(
                                    children: [
                                      if (isDraft) ...[
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: AppColors.dangerRed,
                                              side: BorderSide(color: AppColors.dangerRed.withOpacity(0.5)),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                            ),
                                            onPressed: () {
                                              _cubit!.deleteDeclaration(decId, _employeeId!);
                                            },
                                            icon: const Icon(Icons.delete_outline, size: 16),
                                            label: Text(l10n.delete, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
