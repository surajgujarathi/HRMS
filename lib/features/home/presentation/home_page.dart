// import 'dart:math' as math;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/features/auth/login/cubit/login_cubit.dart';
import 'package:flutter_app/routes.dart';
import 'package:flutter_app/core/utils/shared_pref.dart';
import 'package:flutter_app/core/constants/app_colors.dart';
import 'package:flutter_app/core/widget/custome_search_bar.dart';
import 'package:flutter_app/features/home/widgets/action_card.dart';
import 'package:flutter_app/features/home/widgets/anniversary.dart';
import 'package:flutter_app/features/home/widgets/birth_days.dart';

import 'package:flutter_app/features/attendance/widgets/check_in_out.dart';
import 'package:flutter_app/features/home/widgets/circular.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leadingWidth: 200,

        leading: Padding(
          padding: const EdgeInsets.only(left: 1),
          child: Row(
            children: [
              Transform.scale(
                scale: 0.6,
                child: Image.asset(
                  'assets/images/opsen.png',
                  fit: BoxFit.contain,
                ),
              ),
              Expanded(
                child: FutureBuilder<dynamic>(
                  future: SharedPref().getObject('employee_data'),
                  builder: (context, snapshot) {
                    String name = "User";
                    if (snapshot.hasData && snapshot.data is Map) {
                      name = snapshot.data['name']?.toString().split(' ').first ?? "User";
                    }
                    return Text(
                      'Welcome, $name',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        letterSpacing: 0.5,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {
              // navigate to notifications page
            },
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: Colors.black87,
            ),
          ),

          // 👤 Profile Avatar
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: PopupMenuButton<String>(
              color: AppColors.white,
              offset: const Offset(0, 45), // position below avatar
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                if (value == "profile") {
                  Navigator.pushNamed(context, Routes.personalinf);
                } else if (value == "logout") {
                  // Logout logic here
                  // Navigator.pushReplacement(context,
                  //   MaterialPageRoute(builder: (_) => LoginPage()));
                  context.read<LoginCubit>().logout();
                    if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          Routes.login,
                          (route) => false,
                        );
                      }
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem<String>(
                  value: "profile",
                  child: Row(
                    children: [
                      Icon(Icons.person_outline),
                      SizedBox(width: 8),
                      Text("Go to Profile"),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: "logout",
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text("Logout", style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              child: FutureBuilder<String?>(
                future: SharedPref().getString('profile_pic'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.grey,
                      child: Padding(
                        padding: EdgeInsets.all(4.0),
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                    );
                  }
                  
                  final picData = snapshot.data;
                  debugPrint('Home Profile Pic Data Status: ${picData != null ? "Present (length: ${picData.length})" : "Null"}');

                  if (snapshot.hasData && picData != null && picData.length > 50 && picData != 'false') {
                    try {
                      // Clean the string (remove any newlines or spaces)
                      final cleanedPicData = picData.trim().replaceAll('\n', '').replaceAll('\r', '');
                      final bytes = base64Decode(cleanedPicData);
                      
                      return CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.lightPurple,
                        child: ClipOval(
                          child: Image.memory(
                            bytes,
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                            gaplessPlayback: true, // Prevents flickering
                            errorBuilder: (context, error, stackTrace) {
                              // If Image.memory fails to decode valid bytes
                              return const Icon(Icons.person, size: 22, color: AppColors.primaryPurple);
                            },
                          ),
                        ),
                      );
                    } catch (e) {
                      debugPrint('Error base64 decoding profile pic: $e');
                      return const CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.lightPurple,
                        child: Icon(Icons.person, size: 22, color: AppColors.primaryPurple),
                      );
                    }
                  } else {
                    return const CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.lightPurple,
                      child: Icon(Icons.person, size: 22, color: AppColors.primaryPurple),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.lavenderBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomSearchBar(),
              const SizedBox(height: 2),
              CheckInOutCard(),
              const SizedBox(height: 16),
              AttendanceActions(),
              const SizedBox(height: 16),
              CircularCardSection(),
              const SizedBox(height: 16),
              BirthdaySection(),
              const SizedBox(height: 16),
              AnniversarySection(),

              // _circularCard(),
              // const SizedBox(height: 20),
              // _whiteSection(title: 'Circulars', child: _circularCard()),
              // const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
