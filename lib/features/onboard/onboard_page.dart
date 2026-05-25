import 'package:flutter/material.dart';
import 'package:flutter_app/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_app/core/constants/app_images.dart';
import 'package:flutter_app/core/widget/custome_button.dart';
import 'package:flutter_app/core/utils/shared_pref.dart';
import 'package:flutter_app/features/auth/login_screen.dart';
import 'package:flutter_app/core/localization/locale_cubit.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  Future<void> _goToMain() async {
    final prefs = SharedPref();
    await prefs.saveBool('isFirstTime', false);
    
    if (!mounted) return;
    
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final langCode = context.watch<LocaleCubit>().state;
    final l10n = AppLocalizations.of(context)!;

    final List<OnboardingData> pages = [
      OnboardingData(
        title: l10n.welcome_title,
        subtitle: l10n.welcome_subtitle,
        image: AppImages.land,
      ),
      OnboardingData(
        title: l10n.attendance_payroll,
        subtitle: l10n.attendance_payroll_subtitle,
        image: AppImages.land2,
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // 🎨 Background Decoration
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFFFFF), Color(0xFFF0F7FF)],
                ),
              ),
            ),
          ),
          Positioned(
            top: -100,
            right: -100,
            child: _buildCircle(300, Colors.blue.withOpacity(0.05)),
          ),
          Positioned(
            bottom: 50,
            left: -50,
            child: _buildCircle(200, Colors.blue.withOpacity(0.03)),
          ),

          SafeArea(
            child: Column(
              children: [
                // ⏭️ Skip Button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: TextButton(
                      onPressed: _goToMain,
                      child: Text(
                        l10n.skip,
                        style: const TextStyle(
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),

                // 📄 PageView Content
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemCount: pages.length,
                    itemBuilder: (context, index) {
                      return _buildPage(pages[index]);
                    },
                  ),
                ),

                // 🎛️ Bottom Controls
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          pages.length,
                          (index) => _buildIndicator(index, langCode),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        child: CustomGradientButton(
                          text: _currentPage == pages.length - 1
                              ? l10n.get_started
                              : l10n.next_step,
                          onPressed: () {
                            if (_currentPage < pages.length - 1) {
                              _controller.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              _goToMain();
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _buildIndicator(int index, String langCode) {
    bool isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF1976D2) : Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image Container with Shadow
              Container(
                height: MediaQuery.of(context).size.height * 0.35,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  // Optional shadow for the image area
                ),
                child: Image.asset(
                  data.image,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),

              // Text Content
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                data.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blueGrey.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final String image;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.image,
  });
}
