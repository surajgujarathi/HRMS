import 'package:flutter/material.dart';
import 'package:flutter_app/core/constants/app_colors.dart';
import 'package:flutter_app/features/chat/presentation/chat_list_page.dart';
import 'package:flutter_app/features/home/presentation/home_page.dart';
import 'package:flutter_app/features/main/cubit/main_cubit.dart';
import 'package:flutter_app/features/main/state/main_state.dart';
import 'package:flutter_app/features/payroll/payroll_screen.dart';
import 'package:flutter_app/features/profile/profile_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MainCubit(),
              child: BlocBuilder<MainCubit, MainState>(
                builder: (context, state) {
                  final l10n = AppLocalizations.of(context)!;
                  return Scaffold(
                    body: IndexedStack(
                      index: state.selectedIndex,
                      children: [
                        HomePage(),
                        PayrollScreen(), // My Pay
                        ChatListPage(),
                        ProfileScreen(), // Profile
                      ],
                    ),

                    extendBody: true,
                    bottomNavigationBar: SafeArea(
                      child: Container(
                        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.brightBlue.withOpacity(0.15),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildNavItem(context, state, 0, Icons.home_outlined, Icons.home, l10n.home),
                            _buildNavItem(context, state, 1, Icons.payment_outlined, Icons.payment, l10n.my_pay),
                            _buildNavItem(context, state, 2, Icons.chat_bubble_outline, Icons.chat_bubble, l10n.chat),
                            _buildNavItem(context, state, 3, Icons.person_outline, Icons.person, l10n.profile),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildNavItem(BuildContext context, MainState state, int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = state.selectedIndex == index;
    return GestureDetector(
      onTap: () => context.read<MainCubit>().changeTab(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuint,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brightBlue.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.brightBlue : AppColors.textGrey,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.brightBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
