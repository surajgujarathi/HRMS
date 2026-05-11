import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/features/leave/cubit/leave_cubit.dart';
import 'package:flutter_app/features/leave/cubit/leave_state.dart';
import 'package:flutter_app/features/leave/models/leave_model.dart';
import 'package:flutter_app/features/leave/models/leave_type_model.dart';
import 'package:flutter_app/core/constants/app_colors.dart';
import 'package:flutter_app/routes.dart';
import 'package:intl/intl.dart';

class LeaveListScreen extends StatefulWidget {
  const LeaveListScreen({super.key});

  @override
  State<LeaveListScreen> createState() => _LeaveListScreenState();
}

class _LeaveListScreenState extends State<LeaveListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch initial data using the global Cubit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<LeaveCubit>().fetchLeavesAndTypes();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      body: BlocBuilder<LeaveCubit, LeaveState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () => context.read<LeaveCubit>().fetchLeavesAndTypes(),
            color: AppColors.primaryPurple,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildAppBar(context),
                if (state.status == LeaveStatus.loading && state.leaves.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: AppColors.primaryPurple)),
                  )
                else if (state.status == LeaveStatus.failure && state.leaves.isEmpty)
                  SliverFillRemaining(
                    child: Center(child: Text("Error: ${state.errorMessage}", style: const TextStyle(color: Colors.red))),
                  )
                else ...[
                  if (state.leaveTypes.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _BalanceSummary(leaveTypes: state.leaveTypes),
                    ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                    sliver: Builder(
                      builder: (context) {
                        final activeLeaves = state.leaves.where((l) => l.state != 'cancel' && l.state != 'refuse').toList();
                        if (activeLeaves.isEmpty) {
                          return SliverFillRemaining(hasScrollBody: false, child: _buildEmptyState(context));
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
      floatingActionButton: _buildFAB(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primaryPurple,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: const Text("My Time Off", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
        ),
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryPurple,
                AppColors.primaryPurple.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          onPressed: () => context.read<LeaveCubit>().fetchLeavesAndTypes(),
        ),
      ],
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.3),
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
        backgroundColor: AppColors.primaryPurple,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text("Request Leave", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5)
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20),
            ],
          ),
          child: Icon(Icons.event_note_rounded, size: 80, color: Colors.grey.shade300),
        ),
        const SizedBox(height: 24),
        const Text("No Leave Records", 
          style: TextStyle(fontSize: 20, color: Colors.black87, fontWeight: FontWeight.bold)
        ),
        const SizedBox(height: 12),
        Text("Your leave history will appear here\nonce you submit your first request.", 
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade500, height: 1.5)
        ),
      ],
    );
  }
}

class _BalanceSummary extends StatelessWidget {
  final List<LeaveType> leaveTypes;
  const _BalanceSummary({required this.leaveTypes});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Text("Leave Balance", 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)
          ),
        ),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: leaveTypes.length,
            itemBuilder: (context, index) {
              final type = leaveTypes[index];
              return _BalanceCard(type: type);
            },
          ),
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final LeaveType type;
  const _BalanceCard({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12, bottom: 8, top: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
       border: Border(
        
          left: BorderSide(
            color: Colors.primaries[type.hashCode % Colors.primaries.length],
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(type.name, 
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(type.remainingLeaves.toStringAsFixed(1), 
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryPurple)
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 4),
                child: Text("/ ${type.maxLeaves.toInt()}", 
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400, fontWeight: FontWeight.w500)
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text("Days Available", style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
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
      case 'validate': return const Color(0xFF4CAF50);
      case 'confirm': return const Color(0xFF2196F3);
      case 'refuse': return const Color(0xFFF44336);
      case 'cancel': return Colors.grey;
      default: return const Color(0xFFFF9800);
    }
  }

  String _getStatusText() {
    switch (leave.state) {
      case 'validate': return "Approved";
      case 'confirm': return "Pending";
      case 'refuse': return "Refused";
      case 'cancel': return "Cancelled";
      case 'draft': return "Draft";
      default: return leave.state;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border(
          left: BorderSide(
            color: Colors.primaries[ leave.hashCode % Colors.primaries.length],
            width: 4,
          ),),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
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
                      child: Text(leave.holidayStatusId?.name ?? "Leave Request", 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black87)
                      ),
                    ),
                    _StatusBadge(text: _getStatusText(), color: statusColor),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _InfoItem(icon: Icons.calendar_today_rounded, 
                      text: "${DateFormat('dd MMM').format(leave.requestDateFrom!)} - ${DateFormat('dd MMM yyyy').format(leave.requestDateTo!)}"
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(leave.durationDisplay ?? "", 
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryPurple, fontSize: 15)
                        ),
                        if (leave.payslipState != null && leave.payslipState != "false")
                          Text("Payslip: ${leave.payslipState}", 
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade400)
                          ),
                      ],
                    ),
                  ],
                ),
                if (leave.name != null && leave.name!.isNotEmpty) ...[
                  const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: Color(0xFFF0F0F0))),
                  Text(leave.name!, 
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (leave.state == 'draft' || leave.state == 'confirm' || leave.state == 'validate')
            _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (leave.state == 'draft')
            TextButton.icon(
              onPressed: () => _showDeleteDialog(context),
              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
              label: const Text("Delete Draft", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
            )
          else
            TextButton.icon(
              onPressed: () => _showCancelDialog(context),
              icon: const Icon(Icons.cancel_outlined, size: 18, color: Colors.orangeAccent),
              label: const Text("Cancel Leave", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("Cancel Request?"),
      content: const Text("Are you sure you want to cancel this leave request?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("No")),
        TextButton(onPressed: () { Navigator.pop(ctx); context.read<LeaveCubit>().cancelLeave(leave.id); },
          child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red)),
        ),
      ],
    ));
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("Delete Draft?"),
      content: const Text("This draft will be permanently removed."),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
        TextButton(onPressed: () { Navigator.pop(ctx); context.read<LeaveCubit>().deleteLeave(leave.id); },
          child: const Text("Delete", style: TextStyle(color: Colors.red)),
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
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.2)),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade400),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
