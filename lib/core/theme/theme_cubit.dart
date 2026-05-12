import 'package:flutter/material.dart';
import 'package:flutter_app/core/utils/shared_pref.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  Future<void> loadTheme() async {
    final prefs = SharedPref();
    final isDark = await prefs.getString('isDarkMode');
    if (isDark != null) {
      emit(isDark == 'true' ? ThemeMode.dark : ThemeMode.light);
    } else {
      emit(ThemeMode.system);
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    final prefs = SharedPref();
    await prefs.saveString('isDarkMode', isDark.toString());
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> setSystemTheme() async {
    final prefs = SharedPref();
    await prefs.saveString('isDarkMode', 'system');
    emit(ThemeMode.system);
  }
}
