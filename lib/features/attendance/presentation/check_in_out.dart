
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_app/core/constants/app_colors.dart';
import 'package:flutter_app/features/attendance/cubit/attendance_cubit.dart';
import 'package:flutter_app/features/attendance/cubit/attendance_state.dart';
import 'package:flutter_app/l10n/app_localizations.dart';
import 'package:flutter_app/routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// Stateless widget (UI depends completely on Bloc state)
class CheckInOutCard extends StatelessWidget {
  const CheckInOutCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    double size = 150;
    double strokeWidth = 10;

    return BlocListener<AttendanceCubit, AttendanceState>(
      listener: (context, state) {
        if (state.status == AttendanceStatus.failure && state.errorMessage != null) {
          String errorText = state.errorMessage!;
          if (errorText == "Session expired") errorText = l10n.session_expired;
          if (errorText == "Session info missing") errorText = l10n.session_info_missing;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorText),
              backgroundColor: AppColors.dangerRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          context.read<AttendanceCubit>().clearMessages();
        } else if (state.successMessage != null) {
          String successText = state.successMessage!;
          if (successText == "Checked in successfully") successText = l10n.checked_in_success;
          if (successText == "Checked out successfully") successText = l10n.checked_out_success;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successText),
              backgroundColor: AppColors.successGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          context.read<AttendanceCubit>().clearMessages();
        }
      },
      child: BlocBuilder<AttendanceCubit, AttendanceState>(
        builder: (context, state) {
          final isCheckedIn = state.isCheckedIn;
          final todayHoursStr = state.todayHours;
          final isLoading = state.status == AttendanceStatus.loading;
          double workedHours = double.tryParse(todayHoursStr) ?? 0.0;
          double progress = workedHours / 8.0;
          if (progress > 1.0) progress = 1.0;

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.time, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        const SizedBox(height: 2),
                        Text(DateFormat.jm().format(DateTime.now()),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(l10n.date, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, Routes.inOutReport),
                              child: const Icon(Icons.history_rounded, size: 18, color: AppColors.primaryPurple),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(DateFormat('d MMM yyyy').format(DateTime.now()),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: size,
                      width: size,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: strokeWidth,
                        backgroundColor: AppColors.progressBg,
                        valueColor: AlwaysStoppedAnimation(isCheckedIn ? AppColors.orange : AppColors.successGreen),
                      ),
                    ),
                    Column(
                      children: [
                        Text(todayHoursStr,
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isCheckedIn ? AppColors.orange : AppColors.successGreen)),
                        const SizedBox(height: 4),
                        Text(l10n.working_hours, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCheckedIn ? AppColors.dangerRed : AppColors.successGreen,
                      foregroundColor: AppColors.cardBg,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: isLoading ? null : () => context.read<AttendanceCubit>().toggleAttendance(),
                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.cardBg),
                          )
                        : Icon(isCheckedIn ? Icons.logout_rounded : Icons.login_rounded, size: 20),
                    label: Text(
                      isLoading
                          ? (isCheckedIn ? l10n.checking_out : l10n.checking_in)
                          : (isCheckedIn ? l10n.check_out : l10n.check_in),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}