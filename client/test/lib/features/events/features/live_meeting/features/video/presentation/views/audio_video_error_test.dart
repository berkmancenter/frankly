import 'package:client/core/localization/app_localization_service.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/features/events/features/live_meeting/features/video/presentation/views/audio_video_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    GetIt.instance.registerSingleton(AppLocalizationService());
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
    GetIt.instance<AppLocalizationService>().setLocalization(l10n);
  });

  tearDownAll(() async {
    await GetIt.instance.reset();
  });

  Future<void> pumpError(WidgetTester tester, String error) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(body: AudioVideoErrorDisplay(error: error)),
      ),
    );
  }

  Finder linkifyWithText(String text) => find.byWidgetPredicate(
        (widget) => widget is Linkify && widget.text == text,
      );

  group('AudioVideoErrorDisplay', () {
    testWidgets(
      'maps a backgrounded-tab JSON.parse FormatException to the network message',
      (tester) async {
        await pumpError(
          tester,
          'FormatException: SyntaxError: JSON.parse: unexpected end of data '
          'at line 1 column 1 of the JSON data',
        );

        expect(linkifyWithText(l10n.avErrorNetwork), findsOneWidget);
        // The raw JS error must not leak through to the user.
        expect(
          find.byWidgetPredicate(
            (widget) => widget is Linkify && widget.text.contains('JSON.parse'),
          ),
          findsNothing,
        );
        expect(
          find.byWidgetPredicate(
            (widget) => widget is ActionButton && widget.text == l10n.refresh,
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('shows an unrecognized error verbatim', (tester) async {
      await pumpError(tester, 'Some unexpected failure');

      expect(linkifyWithText('Some unexpected failure'), findsOneWidget);
    });
  });
}
