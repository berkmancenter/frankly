import 'package:client/features/events/features/live_meeting/features/meeting_guide/presentation/widgets/agenda_item_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression test for https://github.com/berkmancenter/frankly/issues/477
///
/// The agenda item timer renders inside a fixed-width cell. Long formatted
/// times (e.g. negative values with hours) or larger user text scales must
/// scale the text down instead of wrapping onto a second line.
void main() {
  Widget harness({required String time, required double textScale}) {
    return MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Scaffold(
        body: Center(
          child: AgendaItemTimer(formattedTime: time, negative: true),
        ),
      ),
    );
  }

  Future<double> oneLineHeight(WidgetTester tester, double textScale) async {
    // A time short enough that it never needs to shrink or wrap; its height is
    // the natural single-line height at this text scale.
    await tester.pumpWidget(harness(time: '5:03', textScale: textScale));
    return tester.getSize(find.text('5:03')).height;
  }

  testWidgets('long negative timer stays on one line at normal text scale', (tester) async {
    const time = '-1:05:30';
    final oneLine = await oneLineHeight(tester, 1.0);
    await tester.pumpWidget(harness(time: time, textScale: 1.0));
    final size = tester.getSize(find.text(time));
    expect(size.height, lessThanOrEqualTo(oneLine + 0.1),
        reason: 'Timer text should scale down, not wrap to a second line');
  });

  testWidgets('short negative timer stays on one line at 2x text scale', (tester) async {
    const time = '-0:24';
    final oneLine = await oneLineHeight(tester, 2.0);
    await tester.pumpWidget(harness(time: time, textScale: 2.0));
    final size = tester.getSize(find.text(time));
    expect(size.height, lessThanOrEqualTo(oneLine + 0.1),
        reason: 'Timer text should scale down, not wrap to a second line');
  });
}
