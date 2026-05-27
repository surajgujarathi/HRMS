import 'package:flutter/material.dart';
import 'package:flutter_app/core/widget/custome_textfield.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/l10n/app_localizations.dart';
import 'package:flutter_app/core/constants/app_images.dart';
import 'package:flutter_app/core/constants/app_colors.dart';
import 'package:flutter_app/features/auth/login/cubit/login_cubit.dart';
import 'package:flutter_app/features/auth/login/cubit/login_state.dart';
import 'package:flutter_app/features/main/presentation/main_page.dart';
import 'package:flutter_app/core/localization/locale_cubit.dart';
import 'package:flutter_app/features/profile/cubit/profile_cubit.dart';
import 'package:flutter_app/core/utils/responsive_util.dart';
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<LoginCubit, LoginState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.status == LoginStatus.success) {
          context.read<ProfileCubit>().fetchProfile();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainPage()),
          );
        } else if (state.status == LoginStatus.failure) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Login failed'),
              backgroundColor: AppColors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            // 🎨 Top Decorative Header Background
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.5,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.indigo,
                      AppColors.brightBlue,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(60),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -50,
                      right: -50,
                      child: CircleAvatar(
                        radius: 100,
                        backgroundColor: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 🚀 Main Scrollable Content
            Positioned.fill(
              child: ResponsiveUtil.buildConstrained(
                context,
                CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                slivers: [
                  // Header Content
                  SliverToBoxAdapter(
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0, bottom: 30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Image.asset(AppImages.logo, width: 40, height: 40),
                                ),
                                _buildLanguageSelector(context, langCode),
                              ],
                            ),
                            const SizedBox(height: 40),
                            Text(
                              l10n.welcome_title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.sign_in_continue,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Login Card
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(60),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).shadowColor.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.login,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Username Field
                          BlocBuilder<LoginCubit, LoginState>(
                            buildWhen: (p, c) => p.usernameError != c.usernameError || p.username != c.username,
                            builder: (context, state) {
                              return CustomTextFormField(
                                initialValue: state.username.isNotEmpty ? state.username : null,
                                label: l10n.username,
                                hintText: "Enter your ${l10n.username}",
                                prefixIcon: Icons.alternate_email_rounded,
                                onChanged: (v) => context.read<LoginCubit>().onUsernameChanged(v),
                                errorText: state.usernameError,
                              );
                            },
                          ),
                          const SizedBox(height: 20),

                          // Password Field
                          BlocBuilder<LoginCubit, LoginState>(
                            buildWhen: (p, c) => p.obscurePassword != c.obscurePassword || p.passwordError != c.passwordError || p.password != c.password,
                            builder: (context, state) {
                              return CustomTextFormField(
                                initialValue: state.password.isNotEmpty ? state.password : null,
                                label: l10n.password,
                                hintText: "Enter your ${l10n.password}",
                                prefixIcon: Icons.lock_outline_rounded,
                                obscureText: state.obscurePassword,
                                onChanged: (v) => context.read<LoginCubit>().onPasswordChanged(v),
                                errorText: state.passwordError,
                                suffixIcon: IconButton(
                                  icon: Icon(state.obscurePassword ? Icons.visibility_off : Icons.visibility, color: Theme.of(context).iconTheme.color),
                                  onPressed: () => context.read<LoginCubit>().togglePasswordVisibility(),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 12),

                          // Forgot Password & Remember Me
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              BlocBuilder<LoginCubit, LoginState>(
                                buildWhen: (p, c) => p.rememberMe != c.rememberMe,
                                builder: (context, state) {
                                  return Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: Checkbox(
                                          value: state.rememberMe,
                                          activeColor: AppColors.brightBlue,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                          onChanged: (v) => context.read<LoginCubit>().toggleRememberMe(v!),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(l10n.remember_me, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 14)),
                                    ],
                                  );
                                },
                              ),
                              // TextButton(
                              //   onPressed: () {},
                              //   child: Text(
                              //     l10n.forgot_password,
                              //     style: const TextStyle(color: AppColors.brightBlue, fontWeight: FontWeight.w600),
                              //   ),
                              // ),
                            ],
                          ),

                          const SizedBox(height: 40),

                          // Login Button
                          BlocBuilder<LoginCubit, LoginState>(
                            builder: (context, state) {
                              if (state.status == LoginStatus.loading) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              return SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: () => _handleLogin(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.indigo,
                                    foregroundColor: Colors.white,
                                    elevation: 4,
                                    shadowColor: AppColors.indigo.withOpacity(0.5),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: Text(
                                    l10n.sign_in,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 40),

                          // Footer
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  l10n.powered_by,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Srivyn",
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
          ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogin(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    context.read<LoginCubit>().login(
          usernameErrorMsg: l10n.error_enter_username,
          passwordErrorMsg: l10n.error_enter_password,
        );
  }


  Widget _buildLanguageSelector(BuildContext context, String langCode) {
    return PopupMenuButton<String>(
      onSelected: (code) => context.read<LocaleCubit>().changeLanguage(code),
      itemBuilder: (context) => [
        _buildPopupMenuItem('English', 'en', langCode == 'en'),
        _buildPopupMenuItem('हिंदी (Hindi)', 'hi', langCode == 'hi'),
        _buildPopupMenuItem('తెలుగు (Telugu)', 'te', langCode == 'te'),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
             Icon(Icons.language, color: AppColors.white, size: 18),
            const SizedBox(width: 8),
            Text(langCode.toUpperCase(), style:  TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
             Icon(Icons.arrow_drop_down, color: AppColors.white),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(String label, String code, bool isActive) {
    return PopupMenuItem<String>(
      value: code,
      child: Row(
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.circle_outlined,
            color: isActive ? AppColors.indigo : AppColors.grey,
            size: 18,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppColors.indigo : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
