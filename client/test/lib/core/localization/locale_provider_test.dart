import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:client/core/localization/locale_provider.dart';

void main() {
  group('LocaleProvider', () {
    late LocaleProvider localeProvider;

    setUp(() {
      localeProvider = LocaleProvider();
      SharedPreferences.setMockInitialValues({});
    });

    test('locale is initially null', () {
      expect(localeProvider.locale, isNull);
    });

    test('setLocale sets a simple locale correctly', () async {
      // Arrange
      final testLocale = const Locale('en');
      
      // Act
      await localeProvider.setLocale(testLocale);
      
      // Assert
      expect(localeProvider.locale, equals(testLocale));
      
      // Verify SharedPreferences was updated
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale'), equals('en'));
    });

    test('setLocale sets a locale with country code correctly', () async {
      // Arrange
      final testLocale = const Locale('en', 'US');
      
      // Act
      await localeProvider.setLocale(testLocale);
      
      // Assert
      expect(localeProvider.locale, equals(testLocale));
      
      // Verify SharedPreferences was updated
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale'), equals('en_US'));
    });

    test('setLocale sets a complex locale with script correctly', () async {
      // Arrange
      final testLocale = const Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hant',
        countryCode: 'TW',
      );
      
      // Act
      await localeProvider.setLocale(testLocale);
      
      // Assert
      expect(localeProvider.locale?.languageCode, equals('zh'));
      expect(localeProvider.locale?.scriptCode, equals('Hant'));
      expect(localeProvider.locale?.countryCode, equals('TW'));
      
      // Verify SharedPreferences was updated
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale'), equals('zh_Hant_TW'));
    });

    test('clearLocale clears locale', () async {
      // Arrange
      await localeProvider.setLocale(const Locale('en'));
      
      // Act
      await localeProvider.clearLocale();
      
      // Assert
      expect(localeProvider.locale, isNull);
      
      // Verify SharedPreferences was cleared
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale'), isNull);
    });

    test('init loads locale from SharedPreferences - simple locale', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({'app_locale': 'es'});
      
      // Act
      await localeProvider.init();
      
      // Assert
      expect(localeProvider.locale?.languageCode, equals('es'));
      expect(localeProvider.locale?.countryCode, isNull);
    });

    test('init loads locale from SharedPreferences - locale with country code', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({'app_locale': 'en_US'});
      
      // Act
      await localeProvider.init();
      
      // Assert
      expect(localeProvider.locale?.languageCode, equals('en'));
      expect(localeProvider.locale?.countryCode, equals('US'));
    });

    test('init loads locale from SharedPreferences - complex locale', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({'app_locale': 'zh_Hant_TW'});
      
      // Act
      await localeProvider.init();
      
      // Assert
      expect(localeProvider.locale?.languageCode, equals('zh'));
      expect(localeProvider.locale?.scriptCode, equals('Hant'));
      expect(localeProvider.locale?.countryCode, equals('TW'));
    });
  });
}
