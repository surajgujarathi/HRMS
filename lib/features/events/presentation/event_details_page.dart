import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/constants/app_colors.dart';
import 'package:flutter_app/features/events/cubit/event_cubit.dart';
import 'package:flutter_app/features/events/models/event_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_app/features/events/cubit/event_cubit.dart';
import 'package:flutter_app/features/events/cubit/event_state.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

class EventDetailsPage extends StatefulWidget {
  final EventModel event;

  const EventDetailsPage({super.key, required this.event});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  int? _selectedTicketId;

  @override
  void initState() {
    super.initState();
    // Default to first ticket if available
    if (widget.event.tickets.isNotEmpty) {
      _selectedTicketId = widget.event.tickets.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildScheduleCard(context),
                  const SizedBox(height: 20),
                  _buildVenueCard(context),
                  if (widget.event.note != null && widget.event.note != "false" && widget.event.note!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(l10n.about_event, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                    const SizedBox(height: 12),
                    Text(
                      _stripHtml(widget.event.note!),
                      style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), height: 1.6),
                    ),
                  ],
                  const SizedBox(height: 20),
                  _buildOrganizerCard(context),
                  if (widget.event.ticketInstructions != null && widget.event.ticketInstructions!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(l10n.important_instructions, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                    const SizedBox(height: 12),
                    _buildInstructionsCard(context),
                  ],
                  if (widget.event.tickets.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(l10n.select_ticket, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                    const SizedBox(height: 16),
                    ...widget.event.tickets.map((t) => _buildTicketCard(context, t)),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomAction(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        child: Stack(
          children: [
            // Background Image/Gradient
            Container(
              height: 280,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.indigo, AppColors.brightBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: _buildHeaderImage(widget.event.badgeImage),
            ),
            // Overlay for readability
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                  const SizedBox(height: 40),
                  Text(
                    widget.event.name,
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (widget.event.eventTypeId != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.event.eventTypeId!.name,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context) {
    final startStr = widget.event.dateBegin != null ? DateFormat('EEEE, dd MMMM yyyy').format(widget.event.dateBegin!) : "N/A";
    final timeRange = widget.event.dateBegin != null && widget.event.dateEnd != null 
        ? "${DateFormat('hh:mm a').format(widget.event.dateBegin!)} - ${DateFormat('hh:mm a').format(widget.event.dateEnd!)}"
        : "N/A";

    return _WhiteCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.indigo.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.calendar_today_rounded, color: AppColors.indigo),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(startStr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 4),
                Text(timeRange, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openMap(String? address) async {
    if (address == null || address.isEmpty) return;
    final Uri url = Uri.parse("https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch $url");
    }
  }

  Widget _buildVenueCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final addressName = widget.event.addressId?.name ?? l10n.company_venue;
    return InkWell(
      onTap: () => _openMap(addressName),
      borderRadius: BorderRadius.circular(24),
      child: _WhiteCard(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.successGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.location_on_rounded, color: AppColors.successGreen),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(addressName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 4),
                  Text(l10n.tap_view_map, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.map_outlined, color: AppColors.indigo, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOrganizerCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _WhiteCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.person_pin_rounded, color: Colors.orange),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.event.organizerId?.name ?? l10n.employee, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 4),
                Text(l10n.host_contact_person, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.indigo.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.indigo.withOpacity(0.1)),
      ),
      child: Text(
        widget.event.ticketInstructions ?? "",
        style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface, height: 1.5),
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context, EventTicket ticket) {
    final isSelected = _selectedTicketId == ticket.id;
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<EventCubit, EventState>(
      builder: (context, state) {
        final isRegistered = state.registeredEventIds.contains(widget.event.id);
        
        return GestureDetector(
          onTap: isRegistered ? null : () {
            setState(() {
              _selectedTicketId = ticket.id;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: isSelected 
                  ? Border.all(color: AppColors.indigo, width: 2) 
                  : Border.all(color: Colors.transparent, width: 2),
              boxShadow: [BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(ticket.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
                          if (isSelected) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.check_circle, color: AppColors.indigo, size: 18),
                          ],
                        ],
                      ),
                      if (ticket.description != null && ticket.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(ticket.description!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ),
                      const SizedBox(height: 12),
                      Text(
                        ticket.price > 0 ? "₹ ${ticket.price.toStringAsFixed(2)}" : "FREE",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.indigo, fontSize: 15),
                      ),
                    ],
                  ),
                ),
                if (ticket.seatsMax > 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("${ticket.seatsMax - ticket.seatsReserved}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.onSurface)),
                      Text(l10n.left, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                    ],
                  ),
              ],
            ),
          ),
        );
      }
    );
  }  Widget _buildBottomAction(BuildContext context) {
    return BlocBuilder<EventCubit, EventState>(
      builder: (context, state) {
        final isRegistered = state.registeredEventIds.contains(widget.event.id);
        final l10n = AppLocalizations.of(context)!;
        
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            boxShadow: [BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.1), blurRadius: 10)],
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    
                    if (isRegistered) {
                      // Cancellation logic
                      scaffoldMessenger.showSnackBar(
                        SnackBar(content: Text(l10n.cancelling_registration)),
                      );
                      final success = await context.read<EventCubit>().cancelRegistration(widget.event.id);
                      scaffoldMessenger.hideCurrentSnackBar();
                      if (success) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(content: Text(l10n.registration_cancelled_success), backgroundColor: AppColors.successGreen),
                        );
                      } else {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(content: Text(l10n.failed_cancel_registration), backgroundColor: Colors.redAccent),
                        );
                      }
                    } else {
                      // Registration logic
                      if (widget.event.tickets.isNotEmpty && _selectedTicketId == null) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(content: Text(l10n.please_select_ticket_first), backgroundColor: Colors.orange),
                        );
                        return;
                      }

                      // Check for mandatory questions (Warning for now)
                      if (widget.event.questions.any((q) => q.isMandatoryAnswer)) {
                        debugPrint('Event has mandatory questions. Form handling would go here.');
                      }

                      scaffoldMessenger.showSnackBar(
                        SnackBar(content: Text(l10n.registering_event)),
                      );
                      final success = await context.read<EventCubit>().registerForEvent(
                        widget.event.id,
                        ticketId: _selectedTicketId,
                      );
                      scaffoldMessenger.hideCurrentSnackBar();
                      if (success) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(content: Text(l10n.successfully_registered), backgroundColor: AppColors.successGreen),
                        );
                      } else {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(content: Text(l10n.registration_failed), backgroundColor: Colors.redAccent),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isRegistered ? Colors.redAccent.withOpacity(0.1) : AppColors.indigo,
                    foregroundColor: isRegistered ? Colors.redAccent : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                    side: isRegistered ? const BorderSide(color: Colors.redAccent, width: 1.5) : null,
                  ),
                  child: Text(
                    isRegistered ? l10n.cancel_registration : l10n.register_now, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderImage(String? base64String) {
    if (base64String == null || base64String == "false" || base64String.isEmpty) {
      return const SizedBox.shrink();
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
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  String _stripHtml(String htmlString) {
    // Basic regex to remove HTML tags
    final RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    String stripped = htmlString.replaceAll(exp, '');
    // Replace common HTML entities
    stripped = stripped.replaceAll('&nbsp;', ' ');
    stripped = stripped.replaceAll('&amp;', '&');
    stripped = stripped.replaceAll('&quot;', '"');
    stripped = stripped.replaceAll('&#39;', "'");
    return stripped.trim();
  }
}

class _WhiteCard extends StatelessWidget {
  final Widget child;
  const _WhiteCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }
}
