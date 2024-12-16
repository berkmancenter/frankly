import 'package:client/app/community/utils.dart';

abstract class TwillioFlutterMeetingView {
  void updateView();
  void showMessage(String message, {ToastType toastType = ToastType.neutral});
}
