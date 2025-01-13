import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:client/features/events/features/live_meeting/features/video/presentation/widgets/colorful_meter.dart';
import '../../../../../../../../../test_utils.dart';

void main() {
  Finder getSizedBoxFinder(double width, double height) {
    return find.descendant(
      of: find.byType(Align),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is SizedBox &&
            widget.width == width &&
            widget.height == height,
      ),
    );
  }

  testWidgets('regular', (tester) async {
    await tester.pumpWidget(MaterialApp(home: ColorfulMeter(value: 0)));

    expect(getSizedBoxFinder(800, 800), findsOneWidget);
  });

  testWidgets('regular, size larger than max width', (tester) async {
    TestUtils.updateScreenSize(tester, 600, 900);
    await tester
        .pumpWidget(MaterialApp(home: ColorfulMeter(size: 750, value: 0)));

    expect(getSizedBoxFinder(600, 600), findsOneWidget);
  });

  testWidgets('regular, size larger than max height', (tester) async {
    TestUtils.updateScreenSize(tester, 600, 900);
    await tester
        .pumpWidget(MaterialApp(home: ColorfulMeter(size: 1000, value: 0)));

    expect(getSizedBoxFinder(600, 600), findsOneWidget);
  });

  testWidgets('regular, size lower than max width', (tester) async {
    TestUtils.updateScreenSize(tester, 600, 900);
    await tester
        .pumpWidget(MaterialApp(home: ColorfulMeter(size: 500, value: 0)));

    expect(getSizedBoxFinder(500, 500), findsOneWidget);
  });

  testWidgets('regular, size lower than max height', (tester) async {
    TestUtils.updateScreenSize(tester, 600, 900);
    await tester
        .pumpWidget(MaterialApp(home: ColorfulMeter(size: 700, value: 0)));

    expect(getSizedBoxFinder(600, 600), findsOneWidget);
  });

  testWidgets(
      'Row: Spacer - Expanded(child) - Spacer, width larger than height',
      (tester) async {
    TestUtils.updateScreenSize(tester, 900, 600);
    await tester.pumpWidget(
      MaterialApp(
        home: Row(
          children: const [
            Spacer(),
            Expanded(child: ColorfulMeter(value: 0)),
            Spacer(),
          ],
        ),
      ),
    );

    expect(getSizedBoxFinder(300, 300), findsOneWidget);
  });

  testWidgets(
      'Row: Spacer - Expanded(child) - Spacer, height larger than width',
      (tester) async {
    TestUtils.updateScreenSize(tester, 600, 900);
    await tester.pumpWidget(
      MaterialApp(
        home: Row(
          children: const [
            Spacer(),
            Expanded(child: ColorfulMeter(value: 0)),
            Spacer(),
          ],
        ),
      ),
    );

    expect(getSizedBoxFinder(200, 200), findsOneWidget);
  });

  testWidgets(
      'Column: Spacer - Expanded(child) - Spacer, width larger than height',
      (tester) async {
    TestUtils.updateScreenSize(tester, 900, 600);

    await tester.pumpWidget(
      MaterialApp(
        home: Column(
          children: const [
            Spacer(),
            Expanded(child: ColorfulMeter(value: 0.5)),
            Spacer(),
          ],
        ),
      ),
    );

    expect(getSizedBoxFinder(900, 900), findsOneWidget);
  });

  testWidgets(
      'Column: Spacer - Expanded(child) - Spacer, height larger than width',
      (tester) async {
    TestUtils.updateScreenSize(tester, 600, 900);

    await tester.pumpWidget(
      MaterialApp(
        home: Column(
          children: const [
            Spacer(),
            Expanded(child: ColorfulMeter(value: 0.5)),
            Spacer(),
          ],
        ),
      ),
    );

    expect(getSizedBoxFinder(600, 600), findsOneWidget);
  });

  group('assertion, value between -1 and 1.', () {
    Future<void> testAssertion(double value, bool doesPass) async {
      test('Value $value', () {
        if (doesPass) {
          expect(() => ColorfulMeter(value: value), returnsNormally);
        } else {
          expect(() => ColorfulMeter(value: value), throwsAssertionError);
        }
      });
    }

    testAssertion(-1.02, false);
    testAssertion(-1.01, false);
    testAssertion(-1, true);
    testAssertion(-0.99, true);
    testAssertion(0.99, true);
    testAssertion(1, true);
    testAssertion(1.01, false);
    testAssertion(1.02, false);
  });
}
