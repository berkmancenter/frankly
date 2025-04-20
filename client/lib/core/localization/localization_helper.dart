import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:client/services.dart';

/// Extension on BuildContext to easily access localizations
extension LocalizationExtension on BuildContext {
  /// Get the AppLocalizations instance
  /// Also sets the localization in appLocalizationService
  AppLocalizations get l10n {
    final localizations = AppLocalizations.of(this)!;
    // Set the localization in the app localization service
    appLocalizationService.setLocalization(localizations);
    return localizations;
  }
}