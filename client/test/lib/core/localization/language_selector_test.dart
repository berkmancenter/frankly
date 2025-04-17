import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:client/core/localization/language_selector.dart';
import 'package:client/core/localization/locale_provider.dart';

void main() {
  group('LanguageSelector', () {
    late LocaleProvider localeProvider;

    setUp(() {
      localeProvider = LocaleProvider();
    });

    Widget createTestWidget() {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: localeProvider.locale ?? const Locale('en'),
        home: ChangeNotifierProvider<LocaleProvider>.value(
          value: localeProvider,
          child: Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: LanguageSelector(),
            ),
          ),
        ),
      );
    }

    testWidgets('renders all language options', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('English'), findsOneWidget);
      expect(find.text('简体中文'), findsOneWidget);
      expect(find.text('臺灣華文'), findsOneWidget);
      expect(find.text('Español'), findsOneWidget);
    });

    testWidgets('selecting language updates locale', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Español'));
      await tester.pumpAndSettle();

      expect(localeProvider.locale?.languageCode, equals('es'));
    });

    testWidgets('selecting complex locale (zh_Hant_TW) updates locale', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('臺灣華文'));
      await tester.pumpAndSettle();

      expect(localeProvider.locale?.languageCode, equals('zh'));
      expect(localeProvider.locale?.scriptCode, equals('Hant'));
      expect(localeProvider.locale?.countryCode, equals('TW'));
    });
  });
}
