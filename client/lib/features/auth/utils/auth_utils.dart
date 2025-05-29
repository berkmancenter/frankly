import 'package:client/features/auth/presentation/views/sign_in_dialog.dart';
import 'package:client/services.dart';

Future<T?> guardSignedIn<T>(
  Future<T> Function() action,) async {
  if (!userService.isSignedIn) {
    await SignInDialog.show();
  }

  if (userService.isSignedIn) {
    return action();
  }

  return null;
}
