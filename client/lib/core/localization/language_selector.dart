import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client/core/localization/locale_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final l10n = AppLocalizations.of(context)!;
    
    return PopupMenuButton<Locale>(
      tooltip: l10n.selectLanguage,
      icon: const Icon(Icons.language),
      onSelected: (Locale locale) {
        localeProvider.setLocale(locale);
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<Locale>(
          value: const Locale('en'),
          child: Text(l10n.locale_en),
        ),
        PopupMenuItem<Locale>(
          value: const Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hant',
            countryCode: 'TW',
          ),
          child: Text(l10n.locale_zh_Hant_TW),
        ),
      ],
    );
  }
}
