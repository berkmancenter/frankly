import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';

/// Service for accessing localizations without requiring a BuildContext
class AppLocalizationService {
  AppLocalizations? _currentLocalizations;

  /// Set the current localizations instance
  /// This should be called when the app's locale changes
  void setLocalization(AppLocalizations localizations) {
    _currentLocalizations = localizations;
  }

  /// Get the current localizations
  AppLocalizations getLocalization() {
    if (_currentLocalizations == null) {
      throw Exception('Localizations not initialized. Make sure to call setLocalization first.');
    }
    return _currentLocalizations!;
  }
}
