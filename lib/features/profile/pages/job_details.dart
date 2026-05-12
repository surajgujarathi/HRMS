import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/constants/app_colors.dart';
import 'package:flutter_app/features/profile/cubit/profile_cubit.dart';
import 'package:flutter_app/features/profile/cubit/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class JobDetailsPage extends StatelessWidget {
  const JobDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
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
          return const Scaffold(
            body: Center(child: Text("No employee data found")),
          );
        }

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Column(
              children: [
                _buildHeader(context, employee),
                _buildTabBar(context),
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

  Widget _buildHeader(BuildContext context, dynamic employee) {
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
              const Expanded(
                child: Text(
                  'Employee Details',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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

  Widget _buildTabBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Theme.of(context).shadowColor.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: const TabBar(
        indicator: BoxDecoration(
          color: AppColors.indigo,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        tabs: [
          Tab(text: "Personal"),
          Tab(text: "Work & Bank"),
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
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildCard(
          context: context,
          title: "Contact Information",
          icon: Icons.contact_mail_outlined,
          children: [
            _detailRow(context, "Work Email", employee.workEmail),
            _detailRow(context, "Mobile", employee.mobilePhone),
            _detailRow(context, "Work Phone", employee.workPhone),
          ],
        ),
        const SizedBox(height: 16),
        _buildCard(
          context: context,
          title: "Personal Details",
          icon: Icons.person_outline_rounded,
          children: [
            _detailRow(context, "Gender", employee.gender),
            _detailRow(context, "Birthday", employee.birthday != null ? DateFormat('dd MMM yyyy').format(employee.birthday!) : null),
            _detailRow(context, "Marital Status", employee.marital),
            _detailRow(context, "Blood Group", employee.bloodGroup),
          ],
        ),
        const SizedBox(height: 16),
        _buildCard(
          context: context,
          title: "Documentation",
          icon: Icons.assignment_ind_outlined,
          children: [
            _detailRow(context, "Aadhar No", employee.aadharNo),
            _detailRow(context, "PAN No", employee.panNo),
            _detailRow(context, "Passport ID", employee.passportId),
            _detailRow(context, "Identification ID", employee.identificationId),
          ],
        ),
        const SizedBox(height: 16),
        _buildCard(
          context: context,
          title: "Addresses",
          icon: Icons.location_on_outlined,
          children: [
            _detailRow(context, "Current Address", employee.address),
            _detailRow(context, "Permanent Address", employee.permanentAddress),
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
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildCard(
          context: context,
          title: "Employment Details",
          icon: Icons.work_outline_rounded,
          children: [
            _detailRow(context, "Department", employee.departmentId?.name),
            _detailRow(context, "Reporting Manager", employee.parentId?.name),
            _detailRow(context, "Coach", employee.coachId?.name),
            _detailRow(context, "Joining Date", employee.doj != null ? DateFormat('dd MMM yyyy').format(employee.doj!) : null),
            _detailRow(context, "Employment Type", employee.empType?.name),
            _detailRow(context, "Work Location", employee.workLocationId?.name),
          ],
        ),
        const SizedBox(height: 16),
        _buildCard(
          context: context,
          title: "Bank Information",
          icon: Icons.account_balance_outlined,
          children: [
            _detailRow(context, "Bank Name", employee.bankName),
            _detailRow(context, "Account Number", employee.bankAccountId),
            _detailRow(context, "IFSC Code", employee.bankIfsc),
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
