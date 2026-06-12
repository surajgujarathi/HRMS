import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/constants/app_colors.dart';
import 'package:flutter_app/features/profile/models/employee_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/features/profile/cubit/profile_cubit.dart';
import 'package:flutter_app/features/profile/cubit/profile_state.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

class ProfileFullDetailsPage extends StatelessWidget {
  const ProfileFullDetailsPage({super.key});

  String _cleanValue(dynamic value) {
    if (value == null) return "N/A";
    final valStr = value.toString().trim();
    if (valStr.isEmpty ||
        valStr.toLowerCase() == "false" ||
        valStr.toLowerCase() == "null" ||
        valStr.toLowerCase() == "n/a") {
      return "N/A";
    }
    return valStr;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => ProfileCubit()..fetchProfile(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.indigo,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            l10n.personal_details,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
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
                      _buildInfoRow(context, Icons.badge_outlined, AppColors.indigo, l10n.employee_code, employee.employeeCode),
                      _buildInfoRow(context, Icons.person_outline, AppColors.brightBlue, l10n.full_name, employee.name),
                      _buildInfoRow(context, Icons.wc_outlined, AppColors.primaryPurple, l10n.gender, employee.gender),
                      _buildInfoRow(context, Icons.cake_outlined, AppColors.teal, l10n.date_of_birth, employee.birthday?.toString().split(' ')[0]),
                      _buildInfoRow(context, Icons.favorite_border, AppColors.dangerRed, l10n.marital_status, employee.marital),
                      _buildInfoRow(context, Icons.bloodtype_outlined, AppColors.red, l10n.blood_group, employee.bloodGroup),
                      _buildInfoRow(context, Icons.assignment_ind_outlined, AppColors.orange, l10n.identification_id, employee.identificationId),
                      _buildInfoRow(context, Icons.flight_takeoff_outlined, AppColors.blue, l10n.passport_no, employee.passportId),
                      _buildInfoRow(context, Icons.credit_card_outlined, AppColors.teal, l10n.aadhar_no, employee.aadharNo),
                      _buildInfoRow(context, Icons.wallet_outlined, AppColors.violet, l10n.pan_no, employee.panNo),
                    ]),
                    _buildSectionTitle(context, l10n.work_information),
                    _buildInfoCard(context, [
                      _buildInfoRow(context, Icons.work_outline, AppColors.indigo, l10n.job_title, employee.jobTitle),
                      _buildInfoRow(context, Icons.business_outlined, AppColors.brightBlue, l10n.department, employee.departmentId?.name),
                      _buildInfoRow(context, Icons.domain, AppColors.primaryPurple, l10n.company, employee.companyId?.name),
                      _buildInfoRow(context, Icons.location_on_outlined, AppColors.teal, l10n.work_location, employee.workLocationId?.name),
                      _buildInfoRow(context, Icons.supervisor_account_outlined, AppColors.orange, l10n.manager, employee.parentId?.name),
                      _buildInfoRow(context, Icons.sports_outlined, AppColors.blue, l10n.coach, employee.coachId?.name),
                      _buildInfoRow(context, Icons.calendar_today_outlined, AppColors.violet, l10n.date_of_joining, employee.doj?.toString().split(' ')[0]),
                      _buildInfoRow(context, Icons.mail_outlined, AppColors.indigo, l10n.work_email, employee.workEmail),
                      _buildInfoRow(context, Icons.phone_outlined, AppColors.successGreen, l10n.work_phone, employee.workPhone),
                      _buildInfoRow(context, Icons.phone_android_outlined, AppColors.successGreen, l10n.mobile, employee.mobilePhone),
                      _buildInfoRow(context, Icons.category_outlined, AppColors.orange, l10n.employment_type, employee.empType?.name),
                    ]),
                    _buildSectionTitle(context, l10n.emergency_contact),
                    _buildInfoCard(context, [
                      _buildInfoRow(context, Icons.contact_phone_outlined, AppColors.dangerRed, l10n.contact_name, employee.emergencyContact),
                      _buildInfoRow(context, Icons.phone_android_outlined, AppColors.successGreen, l10n.contact_phone, employee.emergencyPhone),
                    ]),
                    _buildSectionTitle(context, l10n.bank_details),
                    _buildInfoCard(context, [
                      _buildInfoRow(context, Icons.account_balance_outlined, AppColors.indigo, l10n.bank_name, employee.bankName),
                      _buildInfoRow(context, Icons.qr_code_outlined, AppColors.teal, l10n.ifsc_code, employee.bankIfsc),
                      _buildInfoRow(context, Icons.account_balance_wallet_outlined, AppColors.brightBlue, l10n.account_id, employee.bankAccountId),
                    ]),
                    _buildSectionTitle(context, l10n.address),
                    _buildInfoCard(context, [
                      _buildInfoRow(context, Icons.home_outlined, AppColors.primaryPurple, l10n.residential_address, employee.address),
                      _buildInfoRow(context, Icons.pin_drop_outlined, AppColors.teal, l10n.permanent_address, employee.permanentAddress),
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
    Uint8List? imageBytes;

    if (picData != null && picData.isNotEmpty) {
      try {
        String cleanedPicData = picData.trim().replaceAll('\n', '').replaceAll('\r', '').replaceAll(' ', '');
        if (cleanedPicData.contains(',')) {
          cleanedPicData = cleanedPicData.split(',').last;
        }
        final bytes = base64Decode(cleanedPicData);
        final header = String.fromCharCodes(bytes.take(10));

        if (!header.contains('<?xml') && !header.contains('<svg')) {
          imageBytes = bytes;
          avatarChild = ClipOval(
            child: Image.memory(
              bytes,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              gaplessPlayback: true,
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
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
      decoration: const BoxDecoration(
        color: AppColors.indigo,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              if (imageBytes != null) {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) => Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: const EdgeInsets.all(16),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        InteractiveViewer(
                          panEnabled: true,
                          minScale: 0.5,
                          maxScale: 4.0,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(
                              imageBytes!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Positioned(
                          top: -40,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 30),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.15),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                child: avatarChild ?? const Icon(Icons.person, size: 60, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _cleanValue(employee.name),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _cleanValue(employee.jobTitle ?? l10n.employee),
              style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeaderStat(Icons.business_center_outlined, _cleanValue(employee.departmentId?.name)),
              Container(width: 1, height: 15, color: Colors.white.withValues(alpha: 0.3), margin: const EdgeInsets.symmetric(horizontal: 16)),
              _buildHeaderStat(Icons.location_on_outlined, _cleanValue(employee.workLocationId?.name)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
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
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(children.length, (index) {
          if (index < children.length - 1) {
            return Column(
              children: [
                children[index],
                Padding(
                  padding: const EdgeInsets.only(left: 60),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade100,
                  ),
                ),
              ],
            );
          }
          return children[index];
        }),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, Color themeColor, String title, dynamic value) {
    String displayValue = _cleanValue(value);
    final isNA = displayValue == "N/A";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: themeColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  displayValue,
                  style: TextStyle(
                    color: isNA ? Colors.grey.shade400 : Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: isNA ? FontWeight.normal : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
