import 'package:junto/app/junto/utils.dart';

abstract class DiscussionThreadView {
  void updateView();
  void showMessage(String message, {ToastType toastType});
  void scrollToComments();
}
