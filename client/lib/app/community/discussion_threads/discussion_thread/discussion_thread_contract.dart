import 'package:client/app/community/utils.dart';

abstract class DiscussionThreadView {
  void updateView();
  void showMessage(String message, {ToastType toastType});
  void scrollToComments();
}
