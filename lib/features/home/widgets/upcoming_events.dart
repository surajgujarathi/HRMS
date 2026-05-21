import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/features/events/cubit/event_cubit.dart';
import 'package:flutter_app/features/events/cubit/event_state.dart';
import 'package:flutter_app/features/events/models/event_model.dart';
import 'package:flutter_app/routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class UpcomingEventsSection extends StatelessWidget {
  const UpcomingEventsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventCubit, EventState>(
      builder: (context, state) {
        if (state.status == EventStatus.loading) {
          return const SizedBox.shrink();
        }

        // Filter for upcoming events
        final now = DateTime.now();
        final upcomingEvents = state.events.where((e) => e.dateBegin != null && e.dateBegin!.isAfter(now.subtract(const Duration(hours: 24)))).toList();

        if (upcomingEvents.isEmpty) {
          return const SizedBox.shrink();
        }

        // Take top 3
        final displayEvents = upcomingEvents.take(3).toList();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
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
                          color: Theme.of(context).primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.celebration_rounded, color: Theme.of(context).primaryColor, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Upcoming Events',
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
                    onPressed: () => Navigator.pushNamed(context, Routes.events),
                    child: const Text('See All', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...displayEvents.map((event) => _buildEventItem(context, event)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventItem(BuildContext context, EventModel event) {
    final dateStr = event.dateBegin != null ? DateFormat('MMM dd').format(event.dateBegin!) : "";
    
    return InkWell(
      onTap: () => Navigator.pushNamed(context, Routes.eventDetails, arguments: event),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.1), width: 1),
        ),
        child: Row(
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
              child: _buildEventImage(event.badgeImage),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.addressId?.name ?? "Company Venue",
                          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                dateStr,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventImage(String? base64String) {
    if (base64String == null || base64String == "false" || base64String.isEmpty) {
      return Center(child: Icon(Icons.event, size: 24, color: Colors.white.withOpacity(0.5)));
    }

    try {
      String cleanedData = base64String.trim();
      if (cleanedData.contains(',')) {
        cleanedData = cleanedData.split(',').last;
      }
      final bytes = base64Decode(cleanedData);
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.memory(bytes, fit: BoxFit.cover),
      );
    } catch (e) {
      return Center(child: Icon(Icons.event, size: 24, color: Colors.white.withOpacity(0.5)));
    }
  }
}
