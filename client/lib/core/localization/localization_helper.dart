import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Extension on BuildContext to easily access localizations
extension LocalizationExtension on BuildContext {
  /// Get the AppLocalizations instance
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

/// This is a helper class that shows how to use localized strings in widgets
/// throughout the application.
class LocalizationHelper {
  /// Get the AppLocalizations instance from the current BuildContext
  static AppLocalizations of(BuildContext context) {
    return AppLocalizations.of(context)!;
  }
  
  /// Example of how to use localized strings in a StatelessWidget
  static Widget exampleWidget(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
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
