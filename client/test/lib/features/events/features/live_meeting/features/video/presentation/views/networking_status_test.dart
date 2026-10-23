import 'package:client/core/localization/app_localization_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:client/features/events/features/live_meeting/features/video/presentation/views/networking_status.dart';
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

  Future<void> pumpStatus(WidgetTester tester, Widget widget) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: widget,
      ),
    );
  }

  group('NetworkStatusAlert', () {
    testWidgets('mobile', (tester) async {
      onDismiss() {}

      await pumpStatus(
        tester,
        NetworkStatusAlert(isMobile: true, onDismiss: onDismiss),
      );

      expect(
        find.descendant(
          of: find.byType(Column),
          matching: find.byType(LowBandwidth),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(Column),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is ExplanationText && widget.onDismiss == onDismiss,
          ),
        ),
        findsOneWidget,
      );
    });

    testWidgets('desktop', (tester) async {
      onDismiss() {}

      await pumpStatus(
        tester,
        NetworkStatusAlert(isMobile: false, onDismiss: onDismiss),
      );

      expect(
        find.descendant(
          of: find.byType(Row),
          matching: find.byType(LowBandwidth),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(Row),
          matching: find.descendant(
            of: find.byType(Flexible),
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is ExplanationText && widget.onDismiss == onDismiss,
            ),
          ),
        ),
        findsOneWidget,
      );
    });
  });

  group('LowBandwidth', () {
    testWidgets('regular', (tester) async {
      await pumpStatus(tester, LowBandwidth());

      expect(
        find.descendant(
          of: find.byType(Row),
          matching: find.byType(SvgPicture),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(Row),
          matching: find.byWidgetPredicate(
            (widget) => widget is Text && widget.data == l10n.lowBandwidth,
          ),
        ),
        findsOneWidget,
      );
    });
  });

  group('ExplanationText', () {
    testWidgets('regular', (tester) async {
      onDismiss() {}

      await pumpStatus(tester, ExplanationText(onDismiss: onDismiss));

      expect(
        find.descendant(
          of: find.byType(Row),
          matching: find.descendant(
            of: find.byType(Expanded),
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Text &&
                  widget.data == l10n.lowBandwidthExplanation,
            ),
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) => widget is GestureDetector && widget.onTap == onDismiss,
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(Row),
          matching: find.descendant(
            of: find.byType(GestureDetector),
            matching: find.byType(SvgPicture),
          ),
        ),
        findsOneWidget,
      );
    });
  });
}
