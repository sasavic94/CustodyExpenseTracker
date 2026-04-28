import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('ar', 'EG');

  Locale get locale => _locale;

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'ar';
    _locale = Locale(languageCode, languageCode == 'ar' ? 'EG' : 'US');
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    _locale = Locale(languageCode, languageCode == 'ar' ? 'EG' : 'US');
    notifyListeners();
  }

  String translate(String ar, String en) {
    return _locale.languageCode == 'ar' ? ar : en;
  }
}
