import 'package:client/features/community/presentation/widgets/carousel/time_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget({
    required DateTime time,
    DateTime? endTime,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: VerticalTimeAndDateIndicator(
          time: time,
          endTime: endTime,
        ),
      ),
    );
  }

  testWidgets('shows start time only when no endTime', (tester) async {
    final time = DateTime(2026, 5, 1, 14, 30);
    await tester.pumpWidget(buildTestWidget(time: time));

    expect(find.text('2:30p'), findsOneWidget);
    expect(find.textContaining('-'), findsNothing);
  });

  testWidgets('shows time range when endTime provided', (tester) async {
    final time = DateTime(2026, 5, 1, 14, 30);
    final endTime = DateTime(2026, 5, 1, 15, 30);
    await tester.pumpWidget(buildTestWidget(time: time, endTime: endTime));

    expect(find.text('2:30p - 3:30p'), findsOneWidget);
  });
}
