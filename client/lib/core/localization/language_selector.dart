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
    
    Locale currentLocale = localeProvider.locale ?? const Locale('en');
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _buildLanguageOption(
          context, 
          'English', 
          const Locale('en'), 
          currentLocale, 
          localeProvider,
        ),
        const SizedBox(height: 8),
        _buildLanguageOption(
          context, 
          '简体中文', 
          const Locale('zh'), 
          currentLocale, 
          localeProvider,
        ),
        const SizedBox(height: 8),
        _buildLanguageOption(
          context, 
          '臺灣華文', 
          const Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hant',
            countryCode: 'TW',
          ), 
          currentLocale, 
          localeProvider,
        ),
        const SizedBox(height: 8),
        _buildLanguageOption(
          context, 
          'Español', 
          const Locale('es'), 
          currentLocale, 
          localeProvider,
        ),
      ],
    );
  }
  
  Widget _buildLanguageOption(
    BuildContext context, 
    String label, 
    Locale locale, 
    Locale currentLocale, 
    LocaleProvider localeProvider,
  ) {
    final isSelected = _localesEqual(locale, currentLocale);
    
    return InkWell(
      onTap: () => localeProvider.setLocale(locale),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
  
  bool _localesEqual(Locale a, Locale b) {
    if (a.languageCode != b.languageCode) return false;
    if (a.scriptCode != b.scriptCode) return false;
    if (a.countryCode != b.countryCode) return false;
    return true;
  }
}
