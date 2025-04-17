import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:client/core/widgets/stream_utils.dart';

/// Build app with Text widget inside a MemoizedStreamBuilder
Widget makeWidgets({required String text, required List<String> keys}) =>
    MaterialApp(
      home: MemoizedStreamBuilder<String>(
        streamGetter: () => Stream.value(text),
        keys: keys,
        builder: (_, v) => Text(v!, key: Key('text')),
      ),
    );

/// Helper to get current Text widget contents
String? getTextData(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(Key('text'))).data;

void main() {
  testWidgets('when keys change, call getter', (tester) async {
    // initial build
    await tester.pumpWidget(makeWidgets(text: 'original', keys: ['original']));
    await tester.pumpAndSettle();
    expect(getTextData(tester), 'original');

    // update text and keys
    await tester.pumpWidget(makeWidgets(text: 'updated', keys: ['updated']));
    await tester.pumpAndSettle();
    expect(getTextData(tester), 'updated');
  });

  testWidgets('when keys are same, do not call getter', (tester) async {
    // initial build
    await tester.pumpWidget(makeWidgets(text: 'original', keys: ['original']));
    await tester.pumpAndSettle();
    expect(getTextData(tester), 'original');

    // update text only
    await tester.pumpWidget(makeWidgets(text: 'updated', keys: ['original']));
    await tester.pumpAndSettle();
    expect(getTextData(tester), 'original');
  });
}
