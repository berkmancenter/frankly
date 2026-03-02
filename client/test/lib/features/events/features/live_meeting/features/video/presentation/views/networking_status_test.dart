import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:client/features/events/features/live_meeting/features/video/presentation/views/networking_status.dart';

void main() {
  group('NetworkStatusAlert', () {
    testWidgets('mobile', (tester) async {
      onDismiss() {}

      await tester.pumpWidget(
        MaterialApp(
          home: NetworkStatusAlert(isMobile: true, onDismiss: onDismiss),
        ),
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

      await tester.pumpWidget(
        MaterialApp(
          home: NetworkStatusAlert(isMobile: false, onDismiss: onDismiss),
        ),
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
      await tester.pumpWidget(
        MaterialApp(home: LowBandwidth()),
      );

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
            (widget) => widget is Text && widget.data == 'Low Bandwidth',
          ),
        ),
        findsOneWidget,
      );
    });
  });

  group('ExplanationText', () {
    testWidgets('regular', (tester) async {
      onDismiss() {}

      await tester.pumpWidget(
        MaterialApp(
          home: ExplanationText(onDismiss: onDismiss),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(Row),
          matching: find.descendant(
            of: find.byType(Expanded),
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Text &&
                  widget.data ==
                      'Try turning off your camera for a smoother experience',
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
