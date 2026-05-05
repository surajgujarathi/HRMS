import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/core/utils/shared_pref.dart';

class LocaleCubit extends Cubit<String> {
  LocaleCubit() : super('en') {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = SharedPref();
    final lang = await prefs.getString('language_code') ?? 'en';
    emit(lang);
  }

  Future<void> changeLanguage(String langCode) async {
    final prefs = SharedPref();
    await prefs.saveString('language_code', langCode);
    emit(langCode);
  }
}
