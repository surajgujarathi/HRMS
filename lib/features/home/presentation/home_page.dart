// import 'dart:math' as math;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/routes.dart';
import 'package:flutter_app/core/utils/shared_pref.dart';
import 'package:flutter_app/core/widget/custome_search_bar.dart';
import 'package:flutter_app/features/home/widgets/action_card.dart';
import 'package:flutter_app/features/home/widgets/anniversary.dart';
import 'package:flutter_app/features/home/widgets/birth_days.dart';

import 'package:flutter_app/features/home/widgets/check_in_out.dart';
import 'package:flutter_app/features/home/widgets/circular.dart';

class HomePage extends StatelessWidget {
  static const Color bgColor = Color(0xFFF3EEFC); // light lavender
  static const Color primaryPurple = Color(0xFF8F7AE6);
  static const Color lightPurple = Color(0xFFEDE9FF);

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 200,

        leading: Padding(
          padding: const EdgeInsets.only(left: 1),
          child: Row(
            children: [
              Transform.scale(
                scale: 0.6, // 👈 reduce size
                child: Image.asset(
                  'assets/images/opsen.png',
                  fit: BoxFit.contain,
                ),
              ),
              Text(
                'OpzentoHR',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  letterSpacing: 0.5,
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
              color: Colors.white,
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
                  
                  ImageProvider profileImage;
                  final picData = snapshot.data;
                  debugPrint('Home Profile Pic Data Status: ${picData != null ? "Present (length: ${picData.length})" : "Null"}');

                  if (snapshot.hasData && picData != null && picData.isNotEmpty && picData != 'false') {
                    try {
                      profileImage = MemoryImage(base64Decode(picData));
                    } catch (e) {
                      debugPrint('Error decoding profile pic: $e');
                      profileImage = const AssetImage('assets/images/praveen.png');
                    }
                  } else {
                    profileImage = const AssetImage('assets/images/praveen.png');
                  }
                  return CircleAvatar(
                    radius: 18,
                    backgroundImage: profileImage,
                  );
                },
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF4F2FB),
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
