import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Extensions on [BuildContext]
extension BuildContextExtensions on BuildContext {
  /// Access to the localization strings
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
