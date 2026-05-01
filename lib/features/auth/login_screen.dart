import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/core/constants/app_images.dart';
import 'package:flutter_app/core/widget/custome_button.dart';
import 'package:flutter_app/core/widget/custome_textfield.dart';
import 'package:flutter_app/features/auth/login/cubit/login_cubit.dart';
import 'package:flutter_app/features/auth/login/cubit/login_state.dart';
import 'package:flutter_app/features/home/presentation/home_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool rememberMe = true;
  bool obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildDynamicTextField({
    required String hintText,
    required IconData prefixIcon,
    required TextEditingController controller,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return CustomTextFormField(
      hintText: hintText,
      prefixIcon: prefixIcon,
      controller: controller,
      obscureText: obscureText,
      suffixIcon: suffixIcon,
      keyboardType: keyboardType,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state.status == LoginStatus.success) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          } else if (state.status == LoginStatus.failure) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Error'),
                content: Text(state.errorMessage ?? 'Login failed'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              /// 🔵 Background Image
              Positioned.fill(
                child: Image.asset(
                  AppImages.image,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Container(color: Colors.black.withOpacity(0.0)),
              ),

              Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      const Text(
                        "Opzento HR",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Card
                      LayoutBuilder(
                        builder: (context, constraints) {
                          double maxWidth = constraints.maxWidth;

                          return Container(
                            width: maxWidth > 500 ? 360 : maxWidth * 0.88,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.80),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 40,
                                  spreadRadius: 5,
                                  offset: const Offset(0, 20),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 15),

                                // Username
                                _buildDynamicTextField(
                                  hintText: 'Username',
                                  prefixIcon: Icons.person_outline,
                                  controller: _usernameController,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 15),

                                // Password
                                _buildDynamicTextField(
                                  hintText: 'Password',
                                  prefixIcon: Icons.lock_outline,
                                  controller: _passwordController,
                                  obscureText: obscurePassword,
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        obscurePassword = !obscurePassword;
                                      });
                                    },
                                    icon: Icon(
                                      obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Remember me + Forgot
                                Row(
                                  children: [
                                    Checkbox(
                                      value: rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          rememberMe = value!;
                                        });
                                      },
                                    ),
                                    const Text("Remember me"),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: () {},
                                      child: const Text("Forgot password?"),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),
                                // Sign In Button
                                BlocBuilder<LoginCubit, LoginState>(
                                  builder: (context, state) {
                                    if (state.status == LoginStatus.loading) {
                                      return const Center(child: CircularProgressIndicator());
                                    }
                                    return CustomGradientButton(
                                      onPressed: () {
                                        context.read<LoginCubit>().login(
                                          _usernameController.text,
                                          _passwordController.text,
                                        );
                                      },
                                      text: "Sign In",
                                      borderRadius: 20,
                                      height: 50,
                                    );
                                  },
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      const Center(
                        child: Text.rich(
                          TextSpan(
                            text: "Powered by ",
                            style: TextStyle(color: Colors.grey),
                            children: [
                              TextSpan(
                                text: "FastTrackProjects",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
