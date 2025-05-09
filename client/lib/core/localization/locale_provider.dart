import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';

  Locale? _locale;

  Locale? get locale => _locale;

  // Initialize the locale from shared preferences
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final String? localeString = prefs.getString(_localeKey);

    if (localeString != null) {
      final parts = localeString.split('_');
      if (parts.length == 1) {
        _locale = Locale(parts[0]);
      } else if (parts.length == 2) {
        _locale = Locale(parts[0], parts[1]);
      } else if (parts.length >= 3) {
        _locale = Locale.fromSubtags(
          languageCode: parts[0],
          scriptCode: parts[1],
          countryCode: parts[2],
        );
      }
    }

    notifyListeners();
  }

  // Set a new locale
  Future<void> setLocale(Locale locale) async {
    _locale = locale;

    String localeString;
    if (locale.countryCode != null && locale.scriptCode != null) {
      localeString =
          '${locale.languageCode}_${locale.scriptCode}_${locale.countryCode}';
    } else if (locale.countryCode != null) {
      localeString = '${locale.languageCode}_${locale.countryCode}';
    } else {
      localeString = locale.languageCode;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, localeString);

    notifyListeners();
  }

  // Clear the saved locale
  Future<void> clearLocale() async {
    _locale = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localeKey);

    notifyListeners();
  }
}
