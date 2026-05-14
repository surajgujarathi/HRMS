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
                        'Upcoming Events',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      const Text('🚀', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, Routes.events),
                    child: const Text('See All', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
              child: _buildEventImage(event.badgeImage),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    event.addressId?.name ?? "Company Venue",
                    style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                dateStr,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
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
      return const Center(child: Icon(Icons.event, size: 20));
    }

    try {
      String cleanedData = base64String.trim();
      if (cleanedData.contains(',')) {
        cleanedData = cleanedData.split(',').last;
      }
      final bytes = base64Decode(cleanedData);
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(bytes, fit: BoxFit.cover),
      );
    } catch (e) {
      return const Center(child: Icon(Icons.event, size: 20));
    }
  }
}
