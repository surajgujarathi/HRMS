  import 'package:flutter/material.dart';
  import 'package:flutter_app/core/constants/app_colors.dart';

  class AppTheme {
    // Light Theme Setup
    static ThemeData get lightTheme {
      return ThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.primaryPurple,
        dividerColor: Colors.grey.withOpacity(0.2),
        scaffoldBackgroundColor: AppColors.white,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryPurple,
          secondary: AppColors.brightBlue,
          surface: Colors.white,
          onSurface: AppColors.textDark,
          error: AppColors.dangerRed,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.textDark,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          shadowColor: AppColors.shadow,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.textDark),
          bodyMedium: TextStyle(color: AppColors.textGrey),
        ),
        dividerTheme: DividerThemeData(
          color: Colors.grey.withOpacity(0.2),
          thickness: 1,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.iconGrey,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.inputBg,
          hintStyle: const TextStyle(color: AppColors.iconGrey),
          labelStyle: const TextStyle(color: AppColors.textGrey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.indigo,
          unselectedItemColor: AppColors.textGrey,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.white,
          indicatorColor: AppColors.primaryPurple.withOpacity(0.1),
          iconTheme: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const IconThemeData(color: AppColors.primaryPurple);
            }
            return const IconThemeData(color: AppColors.textGrey);
          }),
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.bold);
            }
            return const TextStyle(color: AppColors.textGrey);
          }),
        ),
      );
    }

    // Dark Theme Setup
    static ThemeData get darkTheme {
      const Color darkBg = Color(0xFF0F172A); // Slate 900
      const Color darkSurface = Color(0xFF1E293B); // Slate 800
      const Color darkTextPrimary = Color(0xFFF8FAFC); // Slate 50
      const Color darkTextSecondary = Color(0xFF94A3B8); // Slate 400

      return ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primaryPurple,
        dividerColor: Colors.white.withOpacity(0.1),
        scaffoldBackgroundColor: darkBg,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryPurple,
          secondary: AppColors.brightBlue,
          surface: darkSurface,
          onSurface: darkTextPrimary,
          error: AppColors.dangerRed,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: darkBg,
          foregroundColor: darkTextPrimary,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: darkSurface,
          shadowColor: Colors.black.withOpacity(0.4),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: darkTextPrimary),
          bodyMedium: TextStyle(color: darkTextSecondary),
        ),
        dividerTheme: DividerThemeData(
          color: Colors.white.withOpacity(0.1),
          thickness: 1,
        ),
        iconTheme: const IconThemeData(
          color: darkTextSecondary,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          hintStyle: TextStyle(color: darkTextSecondary.withOpacity(0.5)),
          labelStyle: const TextStyle(color: darkTextSecondary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2),
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: darkSurface,
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: darkSurface,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: darkSurface,
          selectedItemColor: AppColors.indigo,
          unselectedItemColor: darkTextSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: darkSurface,
          indicatorColor: AppColors.primaryPurple.withOpacity(0.2),
          iconTheme: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const IconThemeData(color: AppColors.primaryPurple);
            }
            return const IconThemeData(color: darkTextSecondary);
          }),
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.bold);
            }
            return const TextStyle(color: darkTextSecondary);
          }),
        ),
      );
    }
  }
