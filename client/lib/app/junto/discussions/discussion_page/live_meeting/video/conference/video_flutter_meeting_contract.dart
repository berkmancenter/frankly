import 'package:junto/app/junto/utils.dart';

abstract class TwillioFlutterMeetingView {
  void updateView();
  void showMessage(String message, {ToastType toastType = ToastType.neutral});
}
