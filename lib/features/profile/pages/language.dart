import 'package:flutter/material.dart';
import 'package:flutter_app/core/constants/app_colors.dart';
import 'package:flutter_app/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/core/localization/locale_cubit.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLang = context.watch<LocaleCubit>().state;
    final l10n = AppLocalizations.of(context)!;

    final List<Map<String, String>> languages = [
      {"native": "English", "english": "English", "code": "en"},
      {"native": "हिन्दी", "english": "Hindi", "code": "hi"},
      {"native": "తెలుగు", "english": "Telugu", "code": "te"},
    ];

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.language,
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "Choose your preferred language",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView.builder(
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    final lang = languages[index];
                    final isSelected = currentLang == lang["code"];

                    return GestureDetector(
                      onTap: () {
                        context.read<LocaleCubit>().changeLanguage(lang["code"]!);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryPurple.withOpacity(0.1)
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryPurple
                                : AppColors.grey.withOpacity(0.2),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lang["native"]!,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                        isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected
                                        ? AppColors.primaryPurple
                                        : AppColors.textDark,
                                  ),
                                ),
                                Text(
                                  lang["english"]!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.primaryPurple,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
