import 'package:flutter/material.dart';
import 'package:flutter_app/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/core/localization/locale_cubit.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguagePage> {
  final List<Map<String, String>> languages = [
    {"native": "English", "english": "English", "code": "en"},
    {"native": "हिन्दी", "english": "Hindi", "code": "hi"},
    {"native": "తెలుగు", "english": "Telugu", "code": "te"},
  ];

  @override
  Widget build(BuildContext context) {
    final currentLang = context.watch<LocaleCubit>().state;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.language),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              /// Language List
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
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFE3F2FD) : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF1976D2) : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF1976D2) : Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.language,
                                color: isSelected ? Colors.white : Colors.blueGrey,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lang["native"]!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? const Color(0xFF1976D2) : Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    lang["english"]!,
                                    style: TextStyle(
                                      color: Colors.blueGrey.withOpacity(0.6),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// Check Icon
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF1976D2),
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
