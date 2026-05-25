import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/constants/app_colors.dart';
import 'package:flutter_app/features/profile/cubit/profile_cubit.dart';
import 'package:flutter_app/features/profile/cubit/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

class JobDetailsPage extends StatelessWidget {
  const JobDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state.status == ProfileStatus.loading) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor)),
          );
        }

        final employee = state.employee;
        if (employee == null) {
          return Scaffold(
            body: Center(child: Text(l10n.no_employee_data_found)),
          );
        }

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Column(
              children: [
                _buildHeader(context, employee, l10n),
                _buildTabBar(context, l10n),
                Expanded(
                  child: TabBarView(
                    children: [
                      _ProfileTab(employee: employee),
                      _WorkTab(employee: employee),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, dynamic employee, AppLocalizations l10n) {
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
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
              ),
              Expanded(
                child: Text(
                  l10n.employee_details,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildAvatar(employee.image1920),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.name ?? "User",
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      employee.jobTitle ?? "Employee",
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        employee.employeeCode ?? "N/A",
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? picData) {
    Widget? avatarImage;
    if (picData != null && picData != "false" && picData.isNotEmpty) {
      try {
        final bytes = base64Decode(picData);
        avatarImage = ClipOval(
          child: Image.memory(
            bytes,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 40, color: Colors.white),
          ),
        );
      } catch (e) {
        debugPrint('Error decoding avatar: $e');
      }
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
      ),
      child: CircleAvatar(
        radius: 40,
        backgroundColor: Colors.white.withOpacity(0.2),
        child: avatarImage ?? const Icon(Icons.person, size: 40, color: Colors.white),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: TabBar(
        indicator: const BoxDecoration(
          color: AppColors.indigo,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        tabs: [
          Tab(text: l10n.personal),
          Tab(text: l10n.work_bank),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  final dynamic employee;
  const _ProfileTab({required this.employee});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildCard(
          context: context,
          title: l10n.contact_information,
          icon: Icons.contact_mail_outlined,
          children: [
            _detailRow(context, l10n.work_email, employee.workEmail),
            _detailRow(context, l10n.mobile, employee.mobilePhone),
            _detailRow(context, l10n.work_phone, employee.workPhone),
          ],
        ),
        const SizedBox(height: 16),
        _buildCard(
          context: context,
          title: l10n.personal_details,
          icon: Icons.person_outline_rounded,
          children: [
            _detailRow(context, l10n.gender, employee.gender),
            _detailRow(context, l10n.birthday, employee.birthday != null ? DateFormat('dd MMM yyyy').format(employee.birthday!) : null),
            _detailRow(context, l10n.marital_status, employee.marital),
            _detailRow(context, l10n.blood_group, employee.bloodGroup),
          ],
        ),
        const SizedBox(height: 16),
        _buildCard(
          context: context,
          title: l10n.documentation,
          icon: Icons.assignment_ind_outlined,
          children: [
            _detailRow(context, l10n.aadhar_no, employee.aadharNo),
            _detailRow(context, l10n.pan_no, employee.panNo),
            _detailRow(context, l10n.passport_id, employee.passportId),
            _detailRow(context, l10n.identification_id, employee.identificationId),
          ],
        ),
        const SizedBox(height: 16),
        _buildCard(
          context: context,
          title: l10n.addresses,
          icon: Icons.location_on_outlined,
          children: [
            _detailRow(context, l10n.current_address, employee.address),
            _detailRow(context, l10n.permanent_address, employee.permanentAddress),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _WorkTab extends StatelessWidget {
  final dynamic employee;
  const _WorkTab({required this.employee});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildCard(
          context: context,
          title: l10n.employment_details,
          icon: Icons.work_outline_rounded,
          children: [
            _detailRow(context, l10n.department, employee.departmentId?.name),
            _detailRow(context, l10n.reporting_manager, employee.parentId?.name),
            _detailRow(context, l10n.coach, employee.coachId?.name),
            _detailRow(context, l10n.date_of_joining, employee.doj != null ? DateFormat('dd MMM yyyy').format(employee.doj!) : null),
            _detailRow(context, l10n.employment_type, employee.empType?.name),
            _detailRow(context, l10n.work_location, employee.workLocationId?.name),
          ],
        ),
        const SizedBox(height: 16),
        _buildCard(
          context: context,
          title: l10n.bank_information,
          icon: Icons.account_balance_outlined,
          children: [
            _detailRow(context, l10n.bank_name, employee.bankName),
            _detailRow(context, l10n.account_number, employee.bankAccountId),
            _detailRow(context, l10n.ifsc_code, employee.bankIfsc),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

Widget _buildCard({required BuildContext context, required String title, required IconData icon, required List<Widget> children}) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.indigo, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
            ),
          ],
        ),
        const Divider(height: 24),
        ...children,
      ],
    ),
  );
}

Widget _detailRow(BuildContext context, String label, String? value) {
  if (value == null || value == "false" || value.isEmpty) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12, fontWeight: FontWeight.w600),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    ),
  );
}
