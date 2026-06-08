import 'package:flutter/material.dart';
import 'package:flutter_app/core/constants/app_colors.dart';
import 'package:flutter_app/network/payroll_api_service.dart';

class PayslipDownloadWizardDialog extends StatefulWidget {
  const PayslipDownloadWizardDialog({super.key});

  @override
  State<PayslipDownloadWizardDialog> createState() => _PayslipDownloadWizardDialogState();
}

class _PayslipDownloadWizardDialogState extends State<PayslipDownloadWizardDialog> {
  PayrollApiService? _apiService;
  bool _isLoading = false;
  bool _initializing = true;

  List<dynamic> _periods = [];
  List<dynamic> _periodLines = [];

  int? _selectedPeriodId;
  int? _selectedPeriodLineId;
  List<String> _validDownloadTypes = ['single', 'zip'];
  String _downloadType = 'single'; 
  int _payslipCount = 0;

  @override
  void initState() {
    super.initState();
    _initService();
  }

  String get _zipDownloadType {
    return _validDownloadTypes.firstWhere((t) => t != 'single', orElse: () => 'zip');
  }

  Future<void> _initService() async {
    try {
      _apiService = await PayrollApiService.create();
      try {
        final fields = await _apiService!.odooService.executeModelMethod(
          'employee.payslip.download.wizard',
          'fields_get',
          [],
          kwargs: {
            'allfields': ['download_type']
          },
        );
        if (fields is Map && fields.containsKey('download_type')) {
          final selection = fields['download_type']['selection'];
          if (selection is List) {
            setState(() {
              _validDownloadTypes = selection.map((opt) => opt[0].toString()).toList();
            });
            debugPrint('Payroll Wizard dynamic download types: $_validDownloadTypes');
          }
        }
      } catch (e) {
        debugPrint('Error fetching selection options: $e');
      }
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
          _loadPeriodLines(_selectedPeriodId!);
        }
      });
    } catch (e) {
      debugPrint('Error loading periods: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPeriodLines(int periodId) async {
    if (_apiService == null) return;
    try {
      final lines = await _apiService!.fetchPeriodLines(periodId);
      setState(() {
        _periodLines = lines;
        if (_periodLines.isNotEmpty) {
          _selectedPeriodLineId = _periodLines.first['id'];
        } else {
          _selectedPeriodLineId = null;
        }
      });
      _updatePayslipCount();
    } catch (e) {
      debugPrint('Error loading period lines: $e');
    }
  }

  Future<void> _updatePayslipCount() async {
    if (_selectedPeriodId == null || _apiService == null) return;
    try {
      // Mock create wizard to fetch dynamic compute payslip count
      final wizard = await _apiService!.createPayslipDownloadWizard({
        'download_type': _downloadType,
        'period_id': _selectedPeriodId,
        'period_line': _downloadType == 'single' ? _selectedPeriodLineId : false,
      });
      setState(() {
        _payslipCount = wizard['payslip_count'] as int? ?? 0;
      });
    } catch (e) {
      debugPrint('Error updating payslip count: $e');
    }
  }

  Future<void> _download() async {
    if (_selectedPeriodId == null || _apiService == null) return;
    setState(() => _isLoading = true);
    try {
      final wizard = await _apiService!.createPayslipDownloadWizard({
        'download_type': _downloadType,
        'period_id': _selectedPeriodId,
        'period_line': _downloadType == 'single' ? _selectedPeriodLineId : false,
      });
      final wizardId = wizard['id'] as int;
      final url = await _apiService!.actionDownloadPayslips(wizardId);
      if (url.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Downloading and opening payslip file...'),
              backgroundColor: Colors.green,
            ),
          );
        }
        final isZip = _downloadType != 'single';
        final savedPath = await _apiService!.downloadAndOpenFile(
          url,
          defaultFileName: isZip ? 'payslips.zip' : 'payslip.pdf',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Saved to: $savedPath'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 6),
            ),
          );
        }
      } else {
        throw Exception('No URL returned from backend');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download: $e'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? Theme.of(context).scaffoldBackgroundColor : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Payslip Download',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              if (_initializing || (_isLoading && _periods.isEmpty))
                const Center(child: CircularProgressIndicator(color: AppColors.indigo))
              else ...[
                // Download type selection
                Text(
                  'Download Option',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Single Month (PDF)'),
                        selected: _downloadType == 'single',
                        onSelected: (val) {
                          if (val) {
                            setState(() => _downloadType = 'single');
                            _updatePayslipCount();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Full Period (ZIP)'),
                        selected: _downloadType != 'single',
                        onSelected: (val) {
                          if (val) {
                            setState(() => _downloadType = _zipDownloadType);
                            _updatePayslipCount();
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Period Dropdown
                Text(
                  'Payroll Period',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: _selectedPeriodId,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: _periods.map((p) {
                    return DropdownMenuItem<int>(
                      value: p['id'] as int,
                      child: Text(p['name'].toString()),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedPeriodId = val);
                      _loadPeriodLines(val);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Month Dropdown (visible if 'single')
                if (_downloadType == 'single') ...[
                  Text(
                    'Month',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: _selectedPeriodLineId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: _periodLines.map((l) {
                      return DropdownMenuItem<int>(
                        value: l['id'] as int,
                        child: Text(l['name'].toString()),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedPeriodLineId = val);
                        _updatePayslipCount();
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Payslips found count badge
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.brightBlue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.brightBlue.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.brightBlue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Available Payslips: $_payslipCount',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brightBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A4E69),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _payslipCount > 0 && !_isLoading ? _download : null,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'DOWNLOAD NOW',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
