import 'package:flutter/material.dart';
import 'package:flutter_app/core/constants/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/features/profile/cubit/expense_cubit.dart';
import 'package:flutter_app/features/profile/cubit/expense_state.dart';
import 'package:flutter_app/features/profile/models/expense_model.dart';
import 'package:flutter_app/features/profile/pages/new_expense_page.dart';

class ReimbursementPage extends StatelessWidget {
  const ReimbursementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExpenseCubit()..fetchExpenses(),
      child: const _ReimbursementView(),
    );
  }
}

class _ReimbursementView extends StatelessWidget {
  const _ReimbursementView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: BlocBuilder<ExpenseCubit, ExpenseState>(
              builder: (context, state) {
                if (state is ExpenseLoading || state is ExpenseInitial) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple));
                } else if (state is ExpenseError) {
                  return Center(child: Text("Error: ${state.message}"));
                } else if (state is ExpenseLoaded) {
                  final expenses = state.expenses;
                  double totalAmount = 0;
                  double pendingAmount = 0;
                  double rejectedAmount = 0;

                  for (var e in expenses) {
                    totalAmount += e.totalAmountCurrency;
                    if (e.state == 'reported' || e.state == 'draft') {
                      pendingAmount += e.totalAmountCurrency;
                    } else if (e.state == 'refused') {
                      rejectedAmount += e.totalAmountCurrency;
                    }
                  }

                  return RefreshIndicator(
                    color: AppColors.primaryPurple,
                    onRefresh: () => context.read<ExpenseCubit>().fetchExpenses(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          /// Claim Amount Card
                          _buildClaimCard(context, totalAmount, pendingAmount, rejectedAmount),

                          const SizedBox(height: 24),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               Text(
                                "My Expenses",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                DateFormat('MMM yyyy').format(DateTime.now()),
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          if (expenses.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Column(
                                children: [
                                  Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.textSecondary.withOpacity(0.3)),
                                  const SizedBox(height: 12),
                                  const Text("No reimbursement records found.", style: TextStyle(color: AppColors.textSecondary)),
                                ],
                              ),
                            ),

                          /// Reimbursement List
                          ...expenses.map((e) => _buildReimbursementCard(context, e)),
                          const SizedBox(height: 80), // Space for FAB
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 4,
        backgroundColor: AppColors.indigo,
        onPressed: () {
          final cubit = context.read<ExpenseCubit>();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: cubit,
                child: const NewExpensePage(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
          const Expanded(
            child: Text(
              'Reimbursement',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildClaimCard(BuildContext context, double total, double pending, double rejected) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            blurRadius: 15,
            color: Theme.of(context).shadowColor.withOpacity(0.08),
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Total Expenses",
            style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            "₹${NumberFormat('#,##,###.##').format(total)}",
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.indigo),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SummaryItem(title: "Pending", amount: "₹${pending.toStringAsFixed(0)}", color: Colors.orange),
              Container(width: 1, height: 30, color: Colors.grey.shade100),
              _SummaryItem(title: "Rejected", amount: "₹${rejected.toStringAsFixed(0)}", color: Colors.red),
              Container(width: 1, height: 30, color: Colors.grey.shade100),
              _SummaryItem(title: "Verified", amount: "₹${(total - pending - rejected).toStringAsFixed(0)}", color: Colors.teal),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReimbursementCard(BuildContext context, ExpenseModel expense) {
    Color statusColor = Colors.grey;
    String statusLabel = expense.state.toUpperCase();

    switch (expense.state) {
      case 'draft':
        statusColor = Colors.blue;
        break;
      case 'reported':
        statusColor = Colors.orange;
        statusLabel = 'SUBMITTED';
        break;
      case 'approved':
        statusColor = Colors.green;
        break;
      case 'done':
        statusColor = Colors.teal;
        statusLabel = 'PAID';
        break;
      case 'refused':
        statusColor = Colors.red;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Theme.of(context).shadowColor.withOpacity(0.04),
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
              Expanded(
                child: Text(
                  expense.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                expense.date != null ? DateFormat('EEE, d MMM yyyy').format(expense.date!) : "No date",
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "₹${expense.totalAmountCurrency.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.indigo),
              ),
              if (expense.state == 'draft')
                ElevatedButton(
                  onPressed: () => context.read<ExpenseCubit>().submitExpense(expense.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.indigo,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    minimumSize: const Size(0, 36),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("SUBMIT", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                )
              else if (expense.productId != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.lavenderBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    expense.productId!.name,
                    style: const TextStyle(color: AppColors.indigo, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;

  const _SummaryItem({required this.title, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          amount,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
