import 'package:client/features/auth/presentation/views/sign_in_dialog.dart';
import 'package:client/services.dart';

Future<T?> guardSignedIn<T>(
  Future<T> Function() action, {
  bool isPurchasingSubscription = false,
}) async {
  if (!userService.isSignedIn) {
    await SignInDialog.show(isPurchasingSubscription: isPurchasingSubscription);
  }

  if (userService.isSignedIn) {
    return action();
  }

  return null;
}
