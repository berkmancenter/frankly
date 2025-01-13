import 'package:client/core/utils/toast_utils.dart';

abstract class DiscussionThreadView {
  void updateView();
  void showMessage(String message, {ToastType toastType});
  void scrollToComments();
}
