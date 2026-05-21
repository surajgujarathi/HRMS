
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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
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
                        Text(l10n.time.toUpperCase(), style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        const SizedBox(height: 4),
                        Text(DateFormat.jm().format(DateTime.now()),
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(l10n.date.toUpperCase(), style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                            const SizedBox(width: 8),
                            // GestureDetector(
                            //   onTap: () => Navigator.pushNamed(context, Routes.inOutReport),
                            //   child: Container(
                            //     padding: const EdgeInsets.all(4),
                            //     decoration: BoxDecoration(
                            //       color: AppColors.lightPurple.withOpacity(0.3),
                            //       borderRadius: BorderRadius.circular(8),
                            //     ),
                            //     child: const Icon(Icons.history_rounded, size: 16, color: AppColors.primaryPurple),
                            //   ),
                            // ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(DateFormat('d MMM yyyy').format(DateTime.now()),
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: size,
                      width: size,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: strokeWidth,
                        strokeCap: StrokeCap.round,
                        backgroundColor: AppColors.progressBg.withOpacity(0.5),
                        valueColor: AlwaysStoppedAnimation(isCheckedIn ? AppColors.orange : AppColors.successGreen),
                      ),
                    ),
                    Column(
                      children: [
                        Text(todayHoursStr,
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: isCheckedIn ? AppColors.orange : AppColors.successGreen)),
                        const SizedBox(height: 4),
                        Text(l10n.working_hours, style: const TextStyle(color: AppColors.textGrey, fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: (isCheckedIn ? AppColors.dangerRed : AppColors.successGreen).withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCheckedIn ? AppColors.dangerRed : AppColors.successGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    onPressed: isLoading ? null : () => context.read<AttendanceCubit>().toggleAttendance(),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(isCheckedIn ? Icons.logout_rounded : Icons.login_rounded, size: 22),
                              const SizedBox(width: 12),
                              Text(
                                isCheckedIn ? l10n.check_out : l10n.check_in,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                              ),
                            ],
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