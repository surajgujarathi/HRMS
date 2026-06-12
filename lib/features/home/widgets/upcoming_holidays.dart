import 'package:flutter/material.dart';
import 'package:flutter_app/features/profile/cubit/holiday_cubit.dart';
import 'package:flutter_app/features/profile/cubit/holiday_state.dart';
import 'package:flutter_app/features/profile/models/holiday_model.dart';
import 'package:flutter_app/routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class UpcomingHolidaysSection extends StatelessWidget {
  const UpcomingHolidaysSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HolidayCubit, HolidayState>(
      builder: (context, state) {
        if (state is HolidayLoading) {
          return const SizedBox.shrink();
        }

        if (state is HolidayLoaded) {
          final now = DateTime.now();
          // Filter for upcoming holidays
          final upcomingHolidays = state.holidays
              .where((h) => h.dateFrom != null && h.dateFrom!.isAfter(now.subtract(const Duration(hours: 24))))
              .toList();

          if (upcomingHolidays.isEmpty) {
            return const SizedBox.shrink();
          }

          // Take top 3
          final displayHolidays = upcomingHolidays.take(3).toList();

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.beach_access_rounded, color: Colors.orange, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Upcoming Holidays',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.2, color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ],
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => Navigator.pushNamed(context, Routes.holidayCalendar),
                      child: const Text('View All', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...displayHolidays.map((holiday) => _buildHolidayItem(context, holiday)),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHolidayItem(BuildContext context, HolidayModel holiday) {
    final dateStr = holiday.dateFrom != null ? DateFormat('MMM dd').format(holiday.dateFrom!) : "";
    final dayStr = holiday.dateFrom != null ? DateFormat('EEEE').format(holiday.dateFrom!) : "";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  holiday.name,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  dayStr,
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              dateStr,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
