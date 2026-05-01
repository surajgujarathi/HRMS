import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/core/constants/app_images.dart';
import 'package:flutter_app/core/utils/shared_pref.dart';
import 'package:flutter_app/features/onboard/onboard_page.dart';
import 'package:flutter_app/features/auth/login/cubit/login_cubit.dart';
import 'package:flutter_app/features/auth/login/cubit/login_state.dart';
import 'package:flutter_app/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: Routes.getAll(),
        home: const SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Start checking login status
    context.read<LoginCubit>().checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) async {
        if (state.status == LoginStatus.success) {
          Navigator.pushReplacementNamed(context, Routes.main);
        } else if (state.status == LoginStatus.initial || state.status == LoginStatus.failure) {
          // If not logged in, check if user has seen onboarding
          final prefs = SharedPref();
          final hasSeenOnboarding = await prefs.getBool('hasSeenOnboarding') ?? false;
          
          if (!context.mounted) return;

          if (hasSeenOnboarding) {
            // Already seen onboarding, go to Login
            Navigator.pushReplacementNamed(context, Routes.login);
          } else {
            // New user, go to Onboarding
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 180,
                height: 180,
                child: Image.asset(AppImages.logo, fit: BoxFit.fill),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8F7AE6)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
