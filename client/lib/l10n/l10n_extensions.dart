import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Extension on [BuildContext] that makes it easy to access localization
extension LocalizationExtension on BuildContext {
  /// Access to the localization strings
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
