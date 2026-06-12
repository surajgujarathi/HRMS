import 'package:flutter/material.dart';
import 'package:flutter_app/core/constants/app_colors.dart';
import 'package:flutter_app/core/widget/custome_textfield.dart';
import 'package:flutter_app/features/profile/cubit/change_password_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/l10n/app_localizations.dart';
import 'package:flutter_app/core/utils/responsive_util.dart';
import 'package:flutter_app/routes.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool hideCurrent = true;
  bool hideNew = true;
  bool hideConfirm = true;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSubmit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<ChangePasswordCubit>().changePassword(
            currentPassword: currentPasswordController.text,
            newPassword: newPasswordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => ChangePasswordCubit(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: BlocListener<ChangePasswordCubit, ChangePasswordState>(
          listener: (context, state) {
            if (state.status == ChangePasswordStatus.success) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  icon: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.successGreen,
                      size: 40,
                    ),
                  ),
                  title: Text(
                    l10n.password_updated_success,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  content: Text(
                    l10n.session_expired_relogin,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  actionsAlignment: MainAxisAlignment.center,
                  actions: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            Routes.login,
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.indigo,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          l10n.okay,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (state.status == ChangePasswordStatus.failure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            state.errorMessage ?? l10n.failed_to_update_password,
                            style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: AppColors.dangerRed,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
            }
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context, l10n),
                ResponsiveUtil.buildConstrained(
                  context,
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: _buildForm(context, l10n),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.indigo, AppColors.brightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
              ),
              Expanded(
                child: Text(
                  l10n.change_password,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_reset_rounded, color: Colors.white, size: 48),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              l10n.security_settings,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.enter_new_password_info,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            
            /// Current Password
            _buildPasswordField(
              context: context,
              label: l10n.current_password,
              hintText: l10n.please_enter_current_password,
              errorEmpty: l10n.please_enter_current_password,
              errorLength: l10n.password_min_length,
              controller: currentPasswordController,
              isObscure: hideCurrent,
              onToggle: () => setState(() => hideCurrent = !hideCurrent),
            ),
            const SizedBox(height: 20),

            /// New Password
            _buildPasswordField(
              context: context,
              label: l10n.new_password,
              hintText: l10n.please_enter(l10n.new_password),
              errorEmpty: l10n.please_enter(l10n.new_password),
              errorLength: l10n.password_min_length,
              controller: newPasswordController,
              isObscure: hideNew,
              onToggle: () => setState(() => hideNew = !hideNew),
            ),
            const SizedBox(height: 20),

            /// Confirm Password
            _buildPasswordField(
              context: context,
              label: l10n.confirm_password,
              hintText: l10n.please_enter(l10n.confirm_password),
              errorEmpty: l10n.please_enter(l10n.confirm_password),
              errorLength: l10n.password_min_length,
              controller: confirmPasswordController,
              isObscure: hideConfirm,
              onToggle: () => setState(() => hideConfirm = !hideConfirm),
              validator: (value) {
                if (value != newPasswordController.text) {
                  return l10n.passwords_do_not_match;
                }
                return null;
              },
            ),
            const SizedBox(height: 40),

            BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
              builder: (context, state) {
                return SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: state.status == ChangePasswordStatus.loading
                        ? null
                        : () => _handleSubmit(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.indigo,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: state.status == ChangePasswordStatus.loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            l10n.update_password,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.cancel,
                  style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required BuildContext context,
    required String label,
    required String hintText,
    required String errorEmpty,
    required String errorLength,
    required TextEditingController controller,
    required bool isObscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return CustomTextFormField(
      controller: controller,
      label: label,
      hintText: hintText,
      prefixIcon: Icons.vpn_key_outlined,
      obscureText: isObscure,
      suffixIcon: IconButton(
        icon: Icon(isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.iconGrey),
        onPressed: onToggle,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return errorEmpty;
        }
        if (value.length < 4) {
          return errorLength;
        }
        if (validator != null) return validator(value);
        return null;
      },
    );
  }
}
