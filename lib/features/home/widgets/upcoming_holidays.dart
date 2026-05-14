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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Upcoming Holidays',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        const Text('🌴', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, Routes.holidayCalendar),
                      child: const Text('View All', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.orange.withOpacity(0.1),
            ),
            child: const Center(
              child: Icon(Icons.beach_access_rounded, color: Colors.orange, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  holiday.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  dayStr,
                  style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              dateStr,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
