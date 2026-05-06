import 'dart:convert';
import 'package:flutter/material.dart';
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
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            l10n.personal_details,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
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
            } else if (state.status == ProfileStatus.success && state.employeeData != null) {
              final data = state.employeeData!;
              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  children: [
                    _buildHeader(data, l10n),
                    _buildSectionTitle(l10n.personal_information),
                    _buildInfoCard([
                      _buildInfoRow(l10n.employee_code, data['employee_code']),
                      _buildInfoRow(l10n.full_name, data['name']),
                      _buildInfoRow(l10n.gender, data['gender']),
                      _buildInfoRow(l10n.date_of_birth, data['birthday']),
                      _buildInfoRow(l10n.marital_status, data['marital']),
                      _buildInfoRow(l10n.blood_group, data['blood_group']),
                      _buildInfoRow(l10n.identification_id, data['identification_id']),
                      _buildInfoRow(l10n.passport_no, data['passport_id']),
                      _buildInfoRow(l10n.aadhar_no, data['aadhar_no']),
                      _buildInfoRow(l10n.pan_no, data['pan_no']),
                    ]),
                    _buildSectionTitle(l10n.work_information),
                    _buildInfoCard([
                      _buildInfoRow(l10n.job_title, data['job_title']),
                      _buildInfoRow(l10n.department, data['department_name']),
                      _buildInfoRow(l10n.work_location, data['work_location_name']),
                      _buildInfoRow(l10n.manager, data['manager']),
                      _buildInfoRow(l10n.date_of_joining, data['doj']),
                      _buildInfoRow(l10n.work_email, data['work_email']),
                      _buildInfoRow(l10n.work_phone, data['work_phone']),
                      _buildInfoRow(l10n.employment_type, data['employment_type']),
                    ]),
                    _buildSectionTitle(l10n.emergency_contact),
                    _buildInfoCard([
                      _buildInfoRow(l10n.contact_name, data['emergency_contact']),
                      _buildInfoRow(l10n.contact_phone, data['emergency_phone']),
                    ]),
                    _buildSectionTitle(l10n.bank_details),
                    _buildInfoCard([
                      _buildInfoRow(l10n.bank_name, data['bank_name']),
                      _buildInfoRow(l10n.ifsc_code, data['bank_ifsc']),
                      _buildInfoRow(l10n.account_id, data['bank_account_id']),
                    ]),
                    _buildSectionTitle(l10n.address),
                    _buildInfoCard([
                      _buildInfoRow(l10n.residential_address, data['address']),
                      _buildInfoRow(l10n.permanent_address, data['permanent_address']),
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

  Widget _buildHeader(Map<String, dynamic> data, AppLocalizations l10n) {
    Widget avatarChild;
    final picData = data['profile_pic'];

    if (picData != null && picData != false && picData.toString().isNotEmpty) {
      try {
        final bytes = base64Decode(picData.toString());
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
      } catch (e) {
        avatarChild = Icon(Icons.person, size: 60, color: Colors.blue.shade300);
      }
    } else {
      avatarChild = Icon(Icons.person, size: 60, color: Colors.blue.shade300);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
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
              child: avatarChild,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data['name'] ?? "N/A",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            data['job_title'] ?? l10n.employee,
            style: TextStyle(fontSize: 14, color: Colors.blue.shade700, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeaderStat(Icons.business_center_outlined, data['department_name'] ?? "N/A"),
              Container(width: 1, height: 15, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 16)),
              _buildHeaderStat(Icons.location_on_outlined, data['work_location_name'] ?? "N/A"),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(String title, dynamic value) {
    String displayValue = (value == null || value == false) ? "N/A" : value.toString();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade50)),
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
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
