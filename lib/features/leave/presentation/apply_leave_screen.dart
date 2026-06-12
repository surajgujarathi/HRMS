import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/utils/shared_pref.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/features/leave/cubit/leave_cubit.dart';
import 'package:flutter_app/features/leave/cubit/leave_state.dart';
import 'package:flutter_app/features/leave/models/leave_type_model.dart';
import 'package:flutter_app/core/constants/app_colors.dart';
import 'package:flutter_app/l10n/app_localizations.dart';
import 'package:flutter_app/core/utils/responsive_util.dart';

class ApplyLeaveScreen extends StatefulWidget {
  const ApplyLeaveScreen({super.key});

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  
  LeaveType? _selectedType;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  bool _isHalfDay = false;
  String _halfDayPeriod = 'am'; // 'am' or 'pm'
  
  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context, AppLocalizations l10n) async {
    if (_formKey.currentState!.validate() && _selectedType != null) {
      // 1. Calculate requested duration
      double requestedDays = 0;
      if (_isHalfDay) {
        requestedDays = 0.5;
      } else {
        if (_endDate.isBefore(_startDate)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.end_date_error), backgroundColor: Colors.red),
          );
          return;
        }
        // Difference in days inclusive
        requestedDays = _endDate.difference(_startDate).inDays.toDouble() + 1;
      }

      // 2. Check against balance
      final isUnpaid = _selectedType!.name.toLowerCase().contains('unpaid');
      if (!isUnpaid && requestedDays > _selectedType!.remainingLeaves) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.insufficient_balance(requestedDays.toString(), _selectedType!.remainingLeaves.toString())),
            backgroundColor: Colors.orange.shade800,
          ),
        );
        return;
      }

      final prefs = SharedPref();
      final employeeData = await prefs.getObject('employee_data');
      if (employeeData == null) return;

      final data = {
        'holiday_status_id': _selectedType!.id,
        'employee_id': employeeData['id'],
        'request_date_from': DateFormat('yyyy-MM-dd').format(_startDate),
        'request_date_to': DateFormat('yyyy-MM-dd').format(_endDate),
        'name': _descriptionController.text,
        'request_unit_half': _isHalfDay,
        'request_date_from_period': _isHalfDay ? _halfDayPeriod : null,
      };

      if (mounted) {
        context.read<LeaveCubit>().applyLeave(data);
      }
    } else if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.please_select_leave_type)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<LeaveCubit, LeaveState>(
      listener: (context, state) {
        if (state.status == LeaveStatus.submitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.successMessage ?? "Success"), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        } else if (state.status == LeaveStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? "Error"), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close_rounded, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(l10n.request_time_off, 
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<LeaveCubit, LeaveState>(
          builder: (context, state) {
            return Form(
              key: _formKey,
              child: ResponsiveUtil.buildConstrained(
                context,
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(l10n.leave_type, Icons.category_outlined),
                      const SizedBox(height: 12),
                      _buildLeaveTypeSelector(state, l10n),
                      
                      const SizedBox(height: 32),
                      _buildSectionHeader(l10n.date_duration, Icons.calendar_month_outlined),
                      const SizedBox(height: 12),
                      _buildDatePickerSection(l10n),
                      
                      const SizedBox(height: 24),
                      _buildHalfDayToggle(l10n),
                      
                      const SizedBox(height: 32),
                      _buildSectionHeader(l10n.additional_details, Icons.description_outlined),
                      const SizedBox(height: 12),
                      _buildDescriptionField(l10n),
                      
                      const SizedBox(height: 48),
                      _buildSubmitButton(context, state, l10n),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryPurple),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }

  Widget _buildLeaveTypeSelector(LeaveState state, AppLocalizations l10n) {
    if (state.status == LeaveStatus.loading) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Shimmer.fromColors(
        baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
        highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
        child: Container(
          height: 54,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: DropdownButtonFormField<LeaveType>(
        value: _selectedType,
        dropdownColor: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          hintText: l10n.select_leave_type,
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
        ),
        items: state.leaveTypes
            .where((type) => type.remainingLeaves > 0 || type.name.toLowerCase().contains('unpaid'))
            .map((type) {
          return DropdownMenuItem(value: type, child: Text(type.name));
        }).toList(),
        onChanged: (val) => setState(() => _selectedType = val),
      ),
    );
  }

  Widget _buildDatePickerSection(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(child: _buildDateTile(l10n.start_date, _startDate, (date) => setState(() => _startDate = date))),
        const SizedBox(width: 16),
        Expanded(child: _buildDateTile(l10n.end_date, _endDate, (date) => setState(() => _endDate = date))),
      ],
    );
  }

  Widget _buildDateTile(String label, DateTime date, Function(DateTime) onDateSelected) {
    return InkWell(
      onTap: () async {
        final selected = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now().subtract(const Duration(days: 30)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.primaryPurple),
            ),
            child: child!,
          ),
        );
        if (selected != null) onDateSelected(selected);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
            const SizedBox(height: 6),
            Text(DateFormat('dd MMM yyyy').format(date), 
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHalfDayToggle(AppLocalizations l10n) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
              ),
            ],
          ),
          child: SwitchListTile(
            title: Text(l10n.half_day, style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
            value: _isHalfDay,
            activeColor: AppColors.primaryPurple,
            onChanged: (val) => setState(() {
              _isHalfDay = val;
              if (val) _endDate = _startDate;
            }),
          ),
        ),
        if (_isHalfDay) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              _buildChoiceChip(l10n.morning_am, _halfDayPeriod == 'am', () => setState(() => _halfDayPeriod = 'am')),
              const SizedBox(width: 12),
              _buildChoiceChip(l10n.afternoon_pm, _halfDayPeriod == 'pm', () => setState(() => _halfDayPeriod = 'pm')),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildChoiceChip(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryPurple : Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppColors.primaryPurple : Colors.grey.shade200),
          ),
          child: Text(label, 
            style: TextStyle(color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.bold, fontSize: 13)
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionField(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: TextFormField(
        controller: _descriptionController,
        maxLines: 4,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: l10n.reason_time_off_hint,
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4), fontSize: 14),
          contentPadding: const EdgeInsets.all(16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
        validator: (val) => val == null || val.isEmpty ? l10n.required_field : null,
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, LeaveState state, AppLocalizations l10n) {
    final isLoading = state.status == LeaveStatus.submitting;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : () => _submit(context, l10n),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(l10n.submit_request, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}
