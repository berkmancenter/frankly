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

/// This is a helper class that shows how to use localized strings in widgets
/// throughout the application.
class LocalizationHelper {
  /// Get the AppLocalizations instance from the current BuildContext
  /// Also sets the localization in appLocalizationService
  static AppLocalizations of(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    // Set the localization in the app localization service
    appLocalizationService.setLocalization(localizations);
    return localizations;
  }

  /// Example of how to use localized strings in a StatelessWidget
  static Widget exampleWidget(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Set the localization in the app localization service
    appLocalizationService.setLocalization(l10n);

    return Column(
      children: [
        Text(l10n.appTitle),
        Text(l10n.appDescription),
        ElevatedButton(
          onPressed: () {},
          child: Text(l10n.login),
        ),
      ],
    );
  }
}
