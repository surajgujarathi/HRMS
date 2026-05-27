import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/features/leave/cubit/leave_cubit.dart';
import 'package:flutter_app/features/leave/cubit/leave_state.dart';
import 'package:flutter_app/features/leave/models/leave_model.dart';
import 'package:flutter_app/features/leave/models/leave_type_model.dart';
import 'package:flutter_app/core/constants/app_colors.dart';
import 'package:flutter_app/routes.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/l10n/app_localizations.dart';
import 'package:flutter_app/core/utils/responsive_util.dart';

class LeaveListScreen extends StatefulWidget {
  const LeaveListScreen({super.key});

  @override
  State<LeaveListScreen> createState() => _LeaveListScreenState();
}

class _LeaveListScreenState extends State<LeaveListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<LeaveCubit>().fetchLeavesAndTypes();
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
          _buildHeader(context, l10n),
          Expanded(
            child: BlocBuilder<LeaveCubit, LeaveState>(
              builder: (context, state) {
                return RefreshIndicator(
                  onRefresh: () => context.read<LeaveCubit>().fetchLeavesAndTypes(),
                  color: AppColors.indigo,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      if (state.status == LeaveStatus.loading && state.leaves.isEmpty)
                        const SliverFillRemaining(
                          child: Center(child: CircularProgressIndicator(color: AppColors.indigo)),
                        )
                      else if (state.status == LeaveStatus.failure && state.leaves.isEmpty)
                        SliverFillRemaining(
                          child: Center(child: Text("Error: ${state.errorMessage}", style: const TextStyle(color: Colors.red))),
                        )
                      else ...[
                        if (state.leaveTypes.isNotEmpty)
                          SliverToBoxAdapter(
                            child: _BalanceSummary(leaveTypes: state.leaveTypes, l10n: l10n),
                          ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                          sliver: Builder(
                            builder: (context) {
                              final activeLeaves = state.leaves.where((l) => l.state != 'cancel' && l.state != 'refuse').toList();
                              if (activeLeaves.isEmpty) {
                                return SliverFillRemaining(hasScrollBody: false, child: _buildEmptyState(context, l10n));
                              }
                              return SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => _LeaveCard(leave: activeLeaves[index]),
                                  childCount: activeLeaves.length,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(context, l10n),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
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
              l10n.my_time_off,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
            onPressed: () => context.read<LeaveCubit>().fetchLeavesAndTypes(),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.indigo.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, Routes.applyLeave);
          if (result == true && mounted) {
            context.read<LeaveCubit>().fetchLeavesAndTypes();
          }
        },
        backgroundColor: AppColors.indigo,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(l10n.request_leave, 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5)
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.05), blurRadius: 20),
            ],
          ),
          child: Icon(Icons.event_note_rounded, size: 80, color: AppColors.indigo.withOpacity(0.1)),
        ),
        const SizedBox(height: 24),
        Text(l10n.no_leave_records, 
          style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)
        ),
        const SizedBox(height: 12),
        Text(l10n.leave_history_info, 
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), height: 1.5)
        ),
      ],
    );
  }
}

class _BalanceSummary extends StatelessWidget {
  final List<LeaveType> leaveTypes;
  final AppLocalizations l10n;
  const _BalanceSummary({required this.leaveTypes, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
          child: Text(l10n.leave_balance, 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveUtil.getCrossAxisCount(context, mobile: 2, tablet: 4),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: ResponsiveUtil.isTablet(context) ? 1.0 : 1.2,
            ),
            itemCount: leaveTypes.length,
            itemBuilder: (context, index) {
              final type = leaveTypes[index];
              return _BalanceCard(type: type, l10n: l10n);
            },
          ),
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final LeaveType type;
  final AppLocalizations l10n;
  const _BalanceCard({required this.type, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final color = Colors.primaries[(type.name.hashCode).abs() % Colors.primaries.length];
    
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(type.name, 
            style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.bold),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(type.remainingLeaves.toStringAsFixed(1), 
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 4),
                child: Text("/ ${type.maxLeaves.toInt()}", 
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.w500)
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(l10n.days_available, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4))),
        ],
      ),
    );
  }
}

class _LeaveCard extends StatelessWidget {
  final LeaveRequest leave;
  const _LeaveCard({required this.leave});

  Color _getStatusColor() {
    switch (leave.state) {
      case 'validate': return AppColors.successGreen;
      case 'confirm': return Colors.blue;
      case 'refuse': return AppColors.dangerRed;
      case 'cancel': return Colors.grey;
      default: return Colors.orange;
    }
  }

  String _getStatusText(AppLocalizations l10n) {
    switch (leave.state) {
      case 'validate': return l10n.approved;
      case 'confirm': return l10n.pending;
      case 'refuse': return l10n.refused;
      case 'cancel': return l10n.cancelled;
      case 'draft': return l10n.draft;
      default: return leave.state;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final statusColor = _getStatusColor();
    final typeColor = Colors.primaries[(leave.holidayStatusId?.name.hashCode ?? 0).abs() % Colors.primaries.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                color: typeColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(leave.holidayStatusId?.name ?? "Leave Request", 
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)
                              ),
                            ),
                          ],
                        ),
                      ),
                      _StatusBadge(text: _getStatusText(l10n), color: statusColor),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                      const SizedBox(width: 8),
                      Text(
                        "${DateFormat('dd MMM').format(leave.requestDateFrom!)} - ${DateFormat('dd MMM yyyy').format(leave.requestDateTo!)}",
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      Text(leave.durationDisplay ?? "", 
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryPurple, fontSize: 16)
                      ),
                    ],
                  ),
                  if (leave.name != null && leave.name!.isNotEmpty) ...[
                    const Divider(height: 32),
                    Text(leave.name!, 
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 12, height: 1.4),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (leave.state == 'draft' || leave.state == 'confirm' || leave.state == 'validate')
              _buildActions(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant ?? Theme.of(context).dividerColor.withOpacity(0.1),
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (leave.state == 'draft')
            TextButton.icon(
              onPressed: () => _showDeleteDialog(context, l10n),
              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
              label: Text(l10n.delete_draft, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
            )
          else
            TextButton.icon(
              onPressed: () => _showCancelDialog(context, l10n),
              icon: const Icon(Icons.cancel_outlined, size: 18, color: Colors.orangeAccent),
              label: Text(l10n.cancel_leave, style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(l10n.cancel_request_q, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      content: Text(l10n.cancel_request_confirm, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.no)),
        TextButton(onPressed: () { Navigator.pop(ctx); context.read<LeaveCubit>().cancelLeave(leave.id); },
          child: Text(l10n.yes_cancel, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ),
      ],
    ));
  }

  void _showDeleteDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(l10n.delete_draft_q, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      content: Text(l10n.delete_draft_confirm, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
        TextButton(onPressed: () { Navigator.pop(ctx); context.read<LeaveCubit>().deleteLeave(leave.id); },
          child: Text(l10n.delete, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ),
      ],
    ));
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  const _StatusBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
