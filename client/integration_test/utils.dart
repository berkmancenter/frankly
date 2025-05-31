import 'package:flutter_test/flutter_test.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/features/auth/presentation/widgets/sign_in_options_content.dart';
import 'package:client/features/auth/presentation/widgets/sign_in_widget.dart';

Future<void> signUpForApp(
  WidgetTester tester, {
  required String email,
  required String name,
  required String password,
}) async {
  final nameFieldFinder = find.byKey(SignInOptionsContent.nameTextFieldKey);

  await waitAndTap(tester, find.byKey(SignInWidget.signUpKey));
  await wait(tester, timeout: Duration(seconds: 1));

  // Name field goes away if switching to login
  expect(nameFieldFinder.hitTestable(), isNot(findsOneWidget));

  // Return to sign up
  await waitAndTap(tester, find.byKey(SignInOptionsContent.buttonSubmitKey));
  await wait(tester, timeout: Duration(seconds: 1));

  expect(nameFieldFinder.hitTestable(), findsOneWidget);

  // Note: Putting in text by setting hte controller directly due to flutter bug:
  // https://github.com/flutter/flutter/issues/89749

  await wait(tester, timeout: Duration(seconds: 3));
  final emailFieldFinder = find.byKey(SignInOptionsContent.emailTextFieldKey);
  await waitAndAction(tester, emailFieldFinder, () async {
    print('putting in email: $email');
    (tester.firstWidget(emailFieldFinder) as CustomTextField).controller?.text =
        email;
  });

  await wait(tester, timeout: Duration(seconds: 2));
  final passwordFieldFinder =
      find.byKey(SignInOptionsContent.passwordTextFieldKey);
  await waitAndAction(tester, passwordFieldFinder, () async {
    print('putting in password: $password');
    (tester.firstWidget(passwordFieldFinder) as CustomTextField)
        .controller
        ?.text = password;
  });

  await wait(tester, timeout: Duration(seconds: 1));
  await waitAndTap(tester, find.byKey(SignInOptionsContent.buttonSubmitKey));
}

Future<bool> waitAndTap(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  return await waitAndAction(
    tester,
    finder,
    () => tester.tap(finder),
    timeout: timeout,
  );
}

Future<bool> waitAndAction(
  WidgetTester tester,
  Finder finder,
  Future<void> Function() action, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  const checkDuration = Duration(seconds: 1);
  Duration timeWaited = Duration.zero;

  while (timeWaited < timeout) {
    if (tester.any(finder)) {
      print('waitAndTap: Widget found, running action...');
      await action();
      return true;
    } else {
      print('waitAndTap: Widget not found, waiting...');
      timeWaited += checkDuration;
      await tester.pump(checkDuration);
    }
  }
  return false;
}

Future<void> wait(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  const checkDuration = Duration(seconds: 1);
  Duration timeWaited = Duration.zero;

  while (timeWaited < timeout) {
    timeWaited += checkDuration;
    await tester.pump(checkDuration);
  }
}
