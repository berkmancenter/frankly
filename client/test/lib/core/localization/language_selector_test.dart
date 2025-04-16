import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:client/core/localization/language_selector.dart';
import 'package:client/core/localization/locale_provider.dart';

void main() {
  group('LanguageSelector', () {
    late LocaleProvider mockLocaleProvider;

    setUp(() {
      mockLocaleProvider = LocaleProvider();
    });

    Widget createTestWidget() {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: mockLocaleProvider.locale ?? const Locale('en'),
        home: ChangeNotifierProvider<LocaleProvider>.value(
          value: mockLocaleProvider,
          child: Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: LanguageSelector(),
            ),
          ),
        ),
      );
    }

    testWidgets('renders language selector button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Find the language icon button
      expect(find.byIcon(Icons.language), findsOneWidget);
    });

    testWidgets('shows language options on tap', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Tap the language selector
      await tester.tap(find.byIcon(Icons.language));
      await tester.pumpAndSettle();
      
      // Verify all four languages are shown
      expect(find.text('English'), findsOneWidget);
      expect(find.text('简体中文'), findsOneWidget);
      expect(find.text('臺灣華文'), findsOneWidget);
      expect(find.text('Español'), findsOneWidget);
    });

    testWidgets('selecting language updates locale', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Tap the language selector
      await tester.tap(find.byIcon(Icons.language));
      await tester.pumpAndSettle();
      
      // Select Spanish
      await tester.tap(find.text('Español'));
      await tester.pumpAndSettle();
      
      // Verify locale was updated
      expect(mockLocaleProvider.locale?.languageCode, equals('es'));
    });

    testWidgets('selecting complex locale (zh_Hant_TW) works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Tap the language selector
      await tester.tap(find.byIcon(Icons.language));
      await tester.pumpAndSettle();
      
      // Select Traditional Chinese
      await tester.tap(find.text('臺灣華文'));
      await tester.pumpAndSettle();
      
      // Verify locale was updated correctly
      expect(mockLocaleProvider.locale?.languageCode, equals('zh'));
      expect(mockLocaleProvider.locale?.scriptCode, equals('Hant'));
      expect(mockLocaleProvider.locale?.countryCode, equals('TW'));
    });
  });
}
