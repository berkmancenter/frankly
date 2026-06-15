import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  group('Localization Testing', () {
    testWidgets('English localization works', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: Scaffold(body: SizedBox()),
        ),
      );

      final l10n = AppLocalizations.of(tester.element(find.byType(SizedBox)))!;

      // Test some key strings in English
      expect(l10n.appTitle, equals('Frankly'));
      expect(l10n.anonymous, equals('Anonymous'));
      expect(l10n.yes, equals('Yes'));
      expect(l10n.no, equals('No'));
      expect(l10n.selectLanguage, isNotEmpty);

      // Test error messages
      expect(
        l10n.avErrorNotFound,
        equals('Audio/video devices not found. Please check permissions.'),
      );
    });

    testWidgets('Spanish localization works', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('es'),
          home: Scaffold(body: SizedBox()),
        ),
      );

      final l10n = AppLocalizations.of(tester.element(find.byType(SizedBox)))!;

      // Verify that Spanish translations are loaded
      expect(
        l10n.appTitle,
        equals('Frankly'),
      ); // App name should remain the same
      expect(l10n.yes, isNot('Yes')); // Should be translated
      // Note: In Spanish, 'No' is also 'No', so we don't check this
      expect(l10n.anonymous, isNot('Anonymous')); // Should be translated
      expect(l10n.selectLanguage, isNotEmpty);

      // Error messages should be translated
      expect(
        l10n.avErrorNotFound,
        isNot('Audio/video devices not found. Please check permissions.'),
      );
    });

    testWidgets('Simplified Chinese localization works',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('zh'),
          home: Scaffold(body: SizedBox()),
        ),
      );

      final l10n = AppLocalizations.of(tester.element(find.byType(SizedBox)))!;

      // Verify that Chinese translations are loaded
      expect(
        l10n.appTitle,
        equals('Frankly'),
      ); // App name should remain the same
      expect(l10n.yes, isNot('Yes')); // Should be translated
      expect(l10n.no, isNot('No')); // Should be translated
      expect(l10n.anonymous, isNot('Anonymous')); // Should be translated
      expect(l10n.selectLanguage, isNotEmpty);

      // Error messages should be translated
      expect(
        l10n.avErrorNotFound,
        isNot('Audio/video devices not found. Please check permissions.'),
      );
    });

    testWidgets('Traditional Chinese (Taiwan) localization works',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hant',
            countryCode: 'TW',
          ),
          home: Scaffold(body: SizedBox()),
        ),
      );

      final l10n = AppLocalizations.of(tester.element(find.byType(SizedBox)))!;

      // Verify that Traditional Chinese translations are loaded
      expect(
        l10n.appTitle,
        equals('Frankly'),
      ); // App name should remain the same
      expect(l10n.yes, isNot('Yes')); // Should be translated
      expect(l10n.no, isNot('No')); // Should be translated
      expect(l10n.anonymous, isNot('Anonymous')); // Should be translated
      expect(l10n.selectLanguage, isNotEmpty);

      // Error messages should be translated
      expect(l10n.avErrorNotFound,
          isNot('Audio/video devices not found. Please check permissions.'));
    });

    testWidgets(
        'Fallback to base language when script/country is not available',
        (WidgetTester tester) async {
      // First get the base simplified Chinese translations
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('zh'), // Base Simplified Chinese
          home: Scaffold(body: SizedBox()),
        ),
      );

      final baseZhL10n =
          AppLocalizations.of(tester.element(find.byType(SizedBox)))!;
      final baseYesText = baseZhL10n.yes;

      // Now test with a locale that doesn't exist but should fall back to 'zh'
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale.fromSubtags(
            languageCode: 'zh',
            countryCode: 'SG', // Singapore Chinese (not explicitly supported)
          ),
          home: Scaffold(body: SizedBox()),
        ),
      );

      final l10n = AppLocalizations.of(tester.element(find.byType(SizedBox)))!;

      // Should fall back to Simplified Chinese
      expect(l10n.yes, isNot('Yes')); // Should be translated
      expect(l10n.yes, equals(baseYesText)); // Should match base 'zh'
    });

    testWidgets('UI with localization updates when locale changes',
        (WidgetTester tester) async {
      // This test creates a simple widget that displays localized text
      // and verifies it updates when locale changes

      Widget buildLocalizedWidget(Locale locale) {
        return MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: locale,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Scaffold(
                body: Column(
                  children: [
                    Text('yes-text: ${l10n.yes}'),
                    Text('no-text: ${l10n.no}'),
                  ],
                ),
              );
            },
          ),
        );
      }

      // Start with English
      await tester.pumpWidget(buildLocalizedWidget(const Locale('en')));
      expect(find.text('yes-text: Yes'), findsOneWidget);
      expect(find.text('no-text: No'), findsOneWidget);

      // Switch to Spanish
      await tester.pumpWidget(buildLocalizedWidget(const Locale('es')));
      await tester.pumpAndSettle();

      // Should now show Spanish translations
      expect(find.text('yes-text: Yes'), findsNothing); // 'Yes' should change
      // In Spanish, 'yes' becomes 'Sí' but 'no' remains 'No'
      expect(find.textContaining('yes-text:'), findsOneWidget);
      // Make sure text is updated, even if 'No' might stay the same in some languages
      expect(find.textContaining('no-text:'), findsOneWidget);
    });
  });

  group('Newly localized strings', () {
    // English source values for the strings localized in this chunk.
    const englishValues = <String, String>{
      'back': 'Back',
      'breakouts': 'Breakouts',
      'cancelHelpNeeded': 'Cancel Help Needed',
      'confirmCancelQuestion': 'Are you sure you want to cancel?',
      'confirmDiscardChanges': 'Are you sure you want to discard changes?',
      'enterRoom': 'Enter Room',
      'enterWord': 'Enter word',
      'headline': 'Headline',
      'imageUrl': 'Image URL',
      'jumpTo': 'Jump To',
      'leaveRoom': 'Leave Room',
      'learnMore': 'Learn more',
      'muteAll': 'Mute All',
      'needMoreHelp': 'Need more help? ',
      'pollQuestion': 'Poll Question',
      'ready': 'Ready',
      'rewatch': 'Rewatch',
      'saveTemplate': 'Save template',
      'showQuestions': 'Show Questions',
      'showResults': 'Show Results',
      'troubleshootingGuide': 'Troubleshooting Guide',
      'viewCurrentRoom': 'View Current Room',
      'viewMoreTemplates': 'View more templates',
      'vimeoUrl': 'Vimeo URL',
      'youtubeUrl': 'YouTube URL',
    };

    // Resolve each key to its generated getter on AppLocalizations.
    Map<String, String> resolveAll(AppLocalizations l10n) => {
          'back': l10n.back,
          'breakouts': l10n.breakouts,
          'cancelHelpNeeded': l10n.cancelHelpNeeded,
          'confirmCancelQuestion': l10n.confirmCancelQuestion,
          'confirmDiscardChanges': l10n.confirmDiscardChanges,
          'enterRoom': l10n.enterRoom,
          'enterWord': l10n.enterWord,
          'headline': l10n.headline,
          'imageUrl': l10n.imageUrl,
          'jumpTo': l10n.jumpTo,
          'leaveRoom': l10n.leaveRoom,
          'learnMore': l10n.learnMore,
          'muteAll': l10n.muteAll,
          'needMoreHelp': l10n.needMoreHelp,
          'pollQuestion': l10n.pollQuestion,
          'ready': l10n.ready,
          'rewatch': l10n.rewatch,
          'saveTemplate': l10n.saveTemplate,
          'showQuestions': l10n.showQuestions,
          'showResults': l10n.showResults,
          'troubleshootingGuide': l10n.troubleshootingGuide,
          'viewCurrentRoom': l10n.viewCurrentRoom,
          'viewMoreTemplates': l10n.viewMoreTemplates,
          'vimeoUrl': l10n.vimeoUrl,
          'youtubeUrl': l10n.youtubeUrl,
        };

    Future<AppLocalizations> pumpAndGet(
      WidgetTester tester,
      Locale locale,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: locale,
          home: const Scaffold(body: SizedBox()),
        ),
      );
      return AppLocalizations.of(tester.element(find.byType(SizedBox)))!;
    }

    testWidgets('English values match the source strings',
        (WidgetTester tester) async {
      final values = resolveAll(await pumpAndGet(tester, const Locale('en')));
      for (final entry in englishValues.entries) {
        expect(
          values[entry.key],
          equals(entry.value),
          reason: 'English ${entry.key} should match the source string',
        );
      }
    });

    testWidgets('Spanish values are present and translated',
        (WidgetTester tester) async {
      final values = resolveAll(await pumpAndGet(tester, const Locale('es')));
      for (final key in englishValues.keys) {
        expect(values[key], isNotEmpty, reason: 'Spanish $key is empty');
        expect(
          values[key],
          isNot(englishValues[key]),
          reason: 'Spanish $key should be translated',
        );
      }
    });

    testWidgets('Simplified Chinese values are present and translated',
        (WidgetTester tester) async {
      final values = resolveAll(await pumpAndGet(tester, const Locale('zh')));
      for (final key in englishValues.keys) {
        expect(values[key], isNotEmpty, reason: 'Chinese $key is empty');
        expect(
          values[key],
          isNot(englishValues[key]),
          reason: 'Simplified Chinese $key should be translated',
        );
      }
    });

    testWidgets('Traditional Chinese (Taiwan) values are present and translated',
        (WidgetTester tester) async {
      final values = resolveAll(
        await pumpAndGet(
          tester,
          Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hant',
            countryCode: 'TW',
          ),
        ),
      );
      for (final key in englishValues.keys) {
        expect(values[key], isNotEmpty, reason: 'Traditional Chinese $key is empty');
        expect(
          values[key],
          isNot(englishValues[key]),
          reason: 'Traditional Chinese $key should be translated',
        );
      }
    });
  });
}
