import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension LocalizationExtension on BuildContext {
  /// 獲取當前上下文的 AppLocalizations
  AppLocalizations get l10n => AppLocalizations.of(this)!;
} 