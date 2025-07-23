import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:client/core/localization/app_localization_service.dart';

/// Test helper functions for setting up common test dependencies
class TestHelpers {
  /// Initialize GetIt and AppLocalizationService for tests
  static void setupLocalizationForTests() {
    // Check if already registered, if so skip setup
    if (GetIt.instance.isRegistered<AppLocalizationService>()) {
      try {
        // Create a minimal mock localization and set it
        final mockLocalizations = _MockAppLocalizations();
        GetIt.instance.get<AppLocalizationService>().setLocalization(mockLocalizations);
      } catch (e) {
        // If error setting localization, service might be in bad state, reset and try again
        GetIt.instance.unregister<AppLocalizationService>();
        GetIt.instance.registerSingleton<AppLocalizationService>(AppLocalizationService());
        final mockLocalizations = _MockAppLocalizations();
        GetIt.instance.get<AppLocalizationService>().setLocalization(mockLocalizations);
      }
      return;
    }
    
    // Register AppLocalizationService
    GetIt.instance.registerSingleton<AppLocalizationService>(AppLocalizationService());
    
    // Create a minimal mock localization and set it
    final mockLocalizations = _MockAppLocalizations();
    GetIt.instance.get<AppLocalizationService>().setLocalization(mockLocalizations);
  }
  
  /// Clean up GetIt registrations after tests
  static Future<void> cleanupAfterTests() async {
    await GetIt.instance.reset();
  }
}

/// Minimal mock implementation of AppLocalizations for testing
class _MockAppLocalizations extends AppLocalizations {
  _MockAppLocalizations() : super('en');
  
  // Override the noSuchMethod to return empty string for any missing getters
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.isGetter) {
      return 'Mock String';
    }
    return super.noSuchMethod(invocation);
  }
} 