import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/constants/app_colors.dart';
import 'package:flutter_app/features/attendance/cubit/attendance_report_cubit.dart';
import 'package:flutter_app/features/attendance/cubit/attendance_report_state.dart';
import 'package:flutter_app/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Main page for displaying the Check-In/Check-Out attendance report.
class InOutReportPage extends StatelessWidget {
  const InOutReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      // Initialize the cubit and fetch the initial report
      create: (context) => AttendanceReportCubit()..fetchReport(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            const _ReportHeader(), // Sticky header with date range selector
            Expanded(
              child: BlocBuilder<AttendanceReportCubit, AttendanceReportState>(
                builder: (context, state) {
                  // Show loading spinner while fetching data
                  if (state.status == ReportStatus.loading) {
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    return Shimmer.fromColors(
                      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: 4,
                        itemBuilder: (context, index) => Container(
                          height: 120,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    );
                  }
                  
                  // Show empty state if no records exist for the selected range
                  if (state.records.isEmpty) {
                    return _buildEmptyState(context, l10n);
                  }
                  
                  // Display the list of attendance records
                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: state.records.length,
                    itemBuilder: (context, index) {
                      final record = state.records[index];
                      return _AttendanceCard(record: record);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper widget to show when no records are found.
  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 80, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(
            l10n.no_records_found,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

/// Header widget containing the title and date range picker buttons.
class _ReportHeader extends StatelessWidget {
  const _ReportHeader();

  /// Opens the date picker and updates the cubit state.
  Future<void> _selectDate(BuildContext context, bool isFrom, AttendanceReportState state) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? state.fromDate : state.toDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryPurple,
              onPrimary: AppColors.cardBg,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final cubit = context.read<AttendanceReportCubit>();
      if (isFrom) {
        cubit.updateDateRange(picked, state.toDate);
      } else {
        cubit.updateDateRange(state.fromDate, picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<AttendanceReportCubit, AttendanceReportState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
         decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.indigo, AppColors.brightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: Column(
            children: [
              // Back button and Page Title
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios, color: AppColors.cardBg, size: 20),
                  ),
                  Expanded(
                    child: Text(
                      l10n.attendance_report,
                      style: const TextStyle(color: AppColors.cardBg, fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 24),
              // From and To date selection buttons
              Row(
                children: [
                  Expanded(
                    child: _DateButton(
                      label: l10n.from,
                      date: state.fromDate,
                      onTap: () => _selectDate(context, true, state),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(Icons.arrow_forward, color: AppColors.lightPurple, size: 16),
                  ),
                  Expanded(
                    child: _DateButton(
                      label: l10n.to,
                      date: state.toDate,
                      onTap: () => _selectDate(context, false, state),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Custom button for the date picker.
class _DateButton extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateButton({required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBg.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBg.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.lightPurple, fontSize: 11)),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd MMM, yyyy').format(date),
              style: const TextStyle(color: AppColors.cardBg, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual card representing one attendance record.
/// Handles parsing and displaying worked hours, overtime, and location data.
class _AttendanceCard extends StatelessWidget {
  final dynamic record;
  const _AttendanceCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Extract raw data from the Odoo response map
    final rawCheckIn = record['check_in'];
    final rawCheckOut = record['check_out'];
    final workedHours = (record['worked_hours'] ?? 0.0).toDouble();
    final overtimeHours = (record['overtime_hours'] ?? 0.0).toDouble();
    final validatedOT = (record['validated_overtime_hours'] ?? 0.0).toDouble();
    
    final inLat = record['in_latitude'];
    final inLong = record['in_longitude'];
    final outLat = record['out_latitude'];
    final outLong = record['out_longitude'];

    // Early exit if check-in is missing
    if (rawCheckIn == null || rawCheckIn == false) return const SizedBox.shrink();

    // Parse Odoo UTC date strings (converting "yyyy-MM-dd HH:mm:ss" to ISO format first)
    final String checkInStr = rawCheckIn.toString();
    final DateTime checkIn = DateTime.parse("${checkInStr.replaceAll(' ', 'T')}Z").toLocal();
    
    DateTime? checkOut;
    if (rawCheckOut != null && rawCheckOut is String && rawCheckOut.isNotEmpty) {
      checkOut = DateTime.parse("${rawCheckOut.replaceAll(' ', 'T')}Z").toLocal();
    }

    final bool isClosed = checkOut != null;

    // Check if location data was captured
    final bool hasInLoc = inLat != null && inLat != 0.0;
    final bool hasOutLoc = outLat != null && outLat != 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border(
          left: BorderSide(
            color: Colors.primaries[record.hashCode % Colors.primaries.length],
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Upper section: Status icon, Date, and Worked Hours
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isClosed ? AppColors.successGreen : AppColors.orange).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isClosed ? Icons.check_circle_outline : Icons.timer_outlined,
                    color: isClosed ? AppColors.successGreen : AppColors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, dd MMM').format(checkIn),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isClosed ? l10n.completed : l10n.still_working,
                        style: TextStyle(
                          color: isClosed ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6) : AppColors.orange,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${workedHours.toStringAsFixed(2)} hrs',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).primaryColor),
                    ),
                    if (overtimeHours > 0)
                      Text(
                        '+${overtimeHours.toStringAsFixed(2)} OT',
                        style: const TextStyle(fontSize: 11, color: AppColors.successGreen, fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Lower section: Time Details (In, Out, Break) and Locations
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTimeInfo(context, l10n.in_label, DateFormat('hh:mm:ss a').format(checkIn), AppColors.blue, 
                      subtitle: hasInLoc ? '${inLat.toStringAsFixed(2)}, ${inLong.toStringAsFixed(2)}' : null),
                    _buildTimeInfo(
                      context,
                      l10n.out, 
                      isClosed ? DateFormat('hh:mm:ss a').format(checkOut) : '--:--', 
                      isClosed ? AppColors.dangerRed : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      subtitle: hasOutLoc ? '${outLat.toStringAsFixed(2)}, ${outLong.toStringAsFixed(2)}' : null
                    ),
                  ],
                ),
                // Show Validated Overtime row if applicable
                if (validatedOT > 0) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.verified_outlined, size: 14, color: AppColors.successGreen),
                      const SizedBox(width: 6),
                      Text(
                        '${l10n.validated_overtime}: ${validatedOT.toStringAsFixed(2)} hrs',
                        style: const TextStyle(fontSize: 12, color: AppColors.successGreen, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to build a column for time info (Label, Time, and optional Subtitle like GPS).
  Widget _buildTimeInfo(BuildContext context, String label, String time, Color color, {String? subtitle}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4), fontSize: 9),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
