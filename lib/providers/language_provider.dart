import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('ro'); // Default: Română

  Locale get locale => _locale;

  LanguageProvider() {
    _loadLanguage();
  }

  // Încarcă limba salvată
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'ro';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  // Schimbă limba
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    
    _locale = locale;
    notifyListeners();

    // Salvează în SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
  }

  // Lista limbilor disponibile
  static const List<Map<String, String>> availableLanguages = [
    {'code': 'ro', 'name': 'Română', 'flag': '🇷🇴'},
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'it', 'name': 'Italiano', 'flag': '🇮🇹'},
    {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺'},
    {'code': 'hu', 'name': 'Magyar', 'flag': '🇭🇺'},
  ];
}
