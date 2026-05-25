import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/constants/app_colors.dart';
import 'package:flutter_app/features/events/cubit/event_cubit.dart';
import 'package:flutter_app/features/events/cubit/event_state.dart';
import 'package:flutter_app/features/events/models/event_model.dart';
import 'package:flutter_app/routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

class EventsListPage extends StatelessWidget {
  const EventsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _EventsListView();
  }
}

class _EventsListView extends StatefulWidget {
  const _EventsListView();

  @override
  State<_EventsListView> createState() => _EventsListViewState();
}

class _EventsListViewState extends State<_EventsListView> {
  @override
  void initState() {
    super.initState();
    // Refresh events whenever the list is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<EventCubit>().fetchEvents();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: BlocBuilder<EventCubit, EventState>(
              builder: (context, state) {
                if (state.status == EventStatus.loading) {
                  return Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor));
                } else if (state.status == EventStatus.error) {
                  return _buildErrorState(context, state.errorMessage ?? l10n.unexpected_error);
                } else if (state.status == EventStatus.loaded) {
                  if (state.events.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  return RefreshIndicator(
                    onRefresh: () => context.read<EventCubit>().fetchEvents(),
                    color: AppColors.indigo,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                      physics: const BouncingScrollPhysics(),
                      itemCount: state.events.length,
                      itemBuilder: (context, index) {
                        return _EventCard(event: state.events[index]);
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.indigo, AppColors.brightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          ),
          Expanded(
            child: Text(
              l10n.company_events,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.event_available_outlined, size: 80, color: Theme.of(context).primaryColor.withOpacity(0.2)),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.no_upcoming_events,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.check_back_later_events,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.dangerRed.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded, size: 80, color: AppColors.dangerRed),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.something_went_wrong,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventModel event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateStr = event.dateBegin != null 
        ? DateFormat('EEEE, dd MMM yyyy').format(event.dateBegin!) 
        : "N/A";
    final timeStr = event.dateBegin != null 
        ? DateFormat('hh:mm a').format(event.dateBegin!) 
        : "N/A";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, Routes.eventDetails, arguments: event);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Area
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.indigo.withOpacity(0.1),
                      AppColors.brightBlue.withOpacity(0.1)
                    ],
                  ),
                ),
                child: _buildBannerImage(event.badgeImage),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.onSurface),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                        const SizedBox(width: 8),
                        Text(dateStr, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 13)),
                        const Spacer(),
                        Icon(Icons.access_time_rounded, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                        const SizedBox(width: 4),
                        Text(timeStr, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            event.addressId?.name ?? l10n.company_venue,
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (event.seatsLimited)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.indigo.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              l10n.seats_left((event.seatsMax - event.seatsTaken).toString()),
                              style: const TextStyle(color: AppColors.indigo, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          )
                        else
                          Text(
                            l10n.open_registration,
                            style: const TextStyle(color: AppColors.successGreen, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        BlocBuilder<EventCubit, EventState>(
                          builder: (context, state) {
                            if (state.registeredEventIds.contains(event.id)) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.successGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: AppColors.successGreen, size: 12),
                                    const SizedBox(width: 4),
                                    Text(
                                      l10n.registered,
                                      style: const TextStyle(color: AppColors.successGreen, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        Row(
                          children: [
                            Text(
                              l10n.view_details,
                              style: const TextStyle(color: AppColors.indigo, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.indigo),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerImage(String? base64String) {
    if (base64String == null ||
        base64String == "false" ||
        base64String.isEmpty) {
      return Center(
        child: Icon(Icons.celebration_rounded,
            size: 48, color: AppColors.indigo.withOpacity(0.3)),
      );
    }

    try {
      String cleanedData = base64String.trim();
      if (cleanedData.contains(',')) {
        cleanedData = cleanedData.split(',').last;
      }
      final bytes = base64Decode(cleanedData);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => Center(
          child: Icon(Icons.broken_image_outlined,
              size: 48, color: AppColors.indigo.withOpacity(0.3)),
        ),
      );
    } catch (e) {
      return Center(
        child: Icon(Icons.celebration_rounded,
            size: 48, color: AppColors.indigo.withOpacity(0.3)),
      );
    }
  }
}
