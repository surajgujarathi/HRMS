import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/features/profile/models/employee_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/features/profile/cubit/profile_cubit.dart';
import 'package:flutter_app/features/profile/cubit/profile_state.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

class ProfileFullDetailsPage extends StatelessWidget {
  const ProfileFullDetailsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => ProfileCubit()..fetchProfile(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).colorScheme.onSurface, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            l10n.personal_details,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
          // actions: [
          //   IconButton(
          //     icon: const Icon(Icons.edit_outlined, color: Colors.blue),
          //     onPressed: () {},
          //   ),
          //   const SizedBox(width: 8),
          // ],
        ),
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state.status == ProfileStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.status == ProfileStatus.failure) {
              return Center(child: Text("Error: ${state.errorMessage}"));
            } else if (state.status == ProfileStatus.success && state.employee != null) {
              final employee = state.employee!;
              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  children: [
                    _buildHeader(context, employee, l10n),
                    _buildSectionTitle(context, l10n.personal_information),
                    _buildInfoCard(context, [
                      _buildInfoRow(context, l10n.employee_code, employee.employeeCode),
                      _buildInfoRow(context, l10n.full_name, employee.name),
                      _buildInfoRow(context, l10n.gender, employee.gender),
                      _buildInfoRow(context, l10n.date_of_birth, employee.birthday?.toString().split(' ')[0]),
                      _buildInfoRow(context, l10n.marital_status, employee.marital),
                      _buildInfoRow(context, l10n.blood_group, employee.bloodGroup),
                      _buildInfoRow(context, l10n.identification_id, employee.identificationId),
                      _buildInfoRow(context, l10n.passport_no, employee.passportId),
                      _buildInfoRow(context, l10n.aadhar_no, employee.aadharNo),
                      _buildInfoRow(context, l10n.pan_no, employee.panNo),
                    ]),
                    _buildSectionTitle(context, l10n.work_information),
                    _buildInfoCard(context, [
                      _buildInfoRow(context, l10n.job_title, employee.jobTitle),
                      _buildInfoRow(context, l10n.department, employee.departmentId?.name),
                      _buildInfoRow(context, l10n.company, employee.companyId?.name),
                      _buildInfoRow(context, l10n.work_location, employee.workLocationId?.name),
                      _buildInfoRow(context, l10n.manager, employee.parentId?.name),
                      _buildInfoRow(context, l10n.coach, employee.coachId?.name),
                      _buildInfoRow(context, l10n.date_of_joining, employee.doj?.toString().split(' ')[0]),
                      _buildInfoRow(context, l10n.work_email, employee.workEmail),
                      _buildInfoRow(context, l10n.work_phone, employee.workPhone),
                      _buildInfoRow(context, l10n.employment_type, employee.empType?.name),
                    ]),
                    _buildSectionTitle(context, l10n.emergency_contact),
                    _buildInfoCard(context, [
                      _buildInfoRow(context, l10n.contact_name, employee.emergencyContact),
                      _buildInfoRow(context, l10n.contact_phone, employee.emergencyPhone),
                    ]),
                    _buildSectionTitle(context, l10n.bank_details),
                    _buildInfoCard(context, [
                      _buildInfoRow(context, l10n.bank_name, employee.bankName),
                      _buildInfoRow(context, l10n.ifsc_code, employee.bankIfsc),
                      _buildInfoRow(context, l10n.account_id, employee.bankAccountId),
                    ]),
                    _buildSectionTitle(context, l10n.address),
                    _buildInfoCard(context, [
                      _buildInfoRow(context, l10n.residential_address, employee.address),
                      _buildInfoRow(context, l10n.permanent_address, employee.permanentAddress),
                    ]),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Employee employee, AppLocalizations l10n) {
    Widget? avatarChild;
    final picData = employee.image1920;

    if (picData != null && picData.isNotEmpty) {
      try {
        final bytes = base64Decode(picData);
        // Check if it's an SVG (Odoo default avatars are often SVGs)
        final header = String.fromCharCodes(bytes.take(10));

        if (!header.contains('<?xml') && !header.contains('<svg')) {
          avatarChild = ClipOval(
            child: Image.memory(
              bytes,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.person, size: 60, color: Colors.blue.shade300);
              },
            ),
          );
        }
      } catch (e) {
        debugPrint('Error decoding avatar: $e');
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue.withOpacity(0.2), width: 2),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade100,
              child: avatarChild ?? Icon(Icons.person, size: 60, color: Colors.blue.shade300),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            employee.name ?? "N/A",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            employee.jobTitle ?? l10n.employee,
            style: TextStyle(fontSize: 14, color: Colors.blue.shade700, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeaderStat(Icons.business_center_outlined, employee.departmentId?.name ?? "N/A"),
              Container(width: 1, height: 15, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 16)),
              _buildHeaderStat(Icons.location_on_outlined, employee.workLocationId?.name ?? "N/A"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(BuildContext context, String title, dynamic value) {
    String displayValue = (value == null || value == false) ? "N/A" : value.toString();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              displayValue,
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
