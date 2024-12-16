import 'package:junto/app/junto/utils.dart';

abstract class DiscussionPageView {
  void updateView();
  void showMessage(String message, {ToastType toastType});
}
