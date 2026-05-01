import 'package:flutter/material.dart';
import 'package:flutter_app/core/widget/custome_search_bar.dart';
import 'package:flutter_app/features/chat/chat_list_screen.dart';
import 'package:flutter_app/features/chat/tabs.dart';
import 'package:flutter_app/features/chat/vertical_page.dart';

class chatPage extends StatelessWidget {
  const chatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: CustomAppBar(
      //   title: 'Payroll',
      //   subtitle: 'View your salary details',
      //   assetImage: AppImages.person,
      // ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              CustomSearchBar(),
              SizedBox(height: 2),
              TeamHorizontalList(),
              SizedBox(height: 16),
              TeamVerticalList(),
              // SalaryBreakdownCard(),
              // SizedBox(height: 16),
              // Anniversary(),
              // SizedBox(height: 12),
              // Tax_Paln(),
            ],
          ),
        ),
      ),
    );
  }
}
