import 'package:client/core/widgets/delete_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpDialog(
    WidgetTester tester, {
    required ValueChanged<bool?> onResult,
    String content = 'Are you sure?',
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => onResult(
              await showDialog<bool>(
                context: context,
                builder: (_) => DeleteDialog(
                  title: 'Delete Post',
                  content: content,
                  cancelText: 'Cancel',
                  confirmText: 'Delete',
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows title, content, and no close icon', (tester) async {
    await pumpDialog(tester, onResult: (_) {});

    expect(find.text('Delete Post'), findsOneWidget);
    expect(find.text('Are you sure?'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing);
  });

  testWidgets('is capped at the design width on wide screens', (tester) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await pumpDialog(
      tester,
      onResult: (_) {},
      content: 'Are you sure you want to delete all agenda items from this '
          'event? This action cannot be undone.',
    );

    expect(
      tester.getSize(find.byType(AlertDialog)).width,
      DeleteDialog.maxWidth,
    );
  });

  testWidgets('shrinks to fit narrow screens', (tester) async {
    tester.view.physicalSize = const Size(300, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await pumpDialog(
      tester,
      onResult: (_) {},
      content: 'Are you sure you want to delete this post? This action '
          'cannot be undone.',
    );

    expect(
      tester.getSize(find.byType(AlertDialog)).width,
      lessThanOrEqualTo(252),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('delete button uses the error color', (tester) async {
    await pumpDialog(tester, onResult: (_) {});

    final button = tester.widget<TextButton>(
      find.byKey(DeleteDialog.confirmButtonKey),
    );
    final color = button.style?.foregroundColor?.resolve({});
    expect(color, ThemeData().colorScheme.error);
  });

  testWidgets('confirm resolves true', (tester) async {
    bool? result;
    await pumpDialog(tester, onResult: (r) => result = r);

    await tester.tap(find.byKey(DeleteDialog.confirmButtonKey));
    await tester.pumpAndSettle();

    expect(result, isTrue);
  });

  testWidgets('cancel resolves false', (tester) async {
    bool? result;
    await pumpDialog(tester, onResult: (r) => result = r);

    await tester.tap(find.byKey(DeleteDialog.cancelButtonKey));
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });

  testWidgets('tab moves focus from Cancel to Delete', (tester) async {
    await pumpDialog(tester, onResult: (_) {});

    Key? focusedButtonKey() => FocusManager.instance.primaryFocus?.context
        ?.findAncestorWidgetOfExactType<TextButton>()
        ?.key;

    expect(focusedButtonKey(), DeleteDialog.cancelButtonKey);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();

    expect(focusedButtonKey(), DeleteDialog.confirmButtonKey);
  });
}
