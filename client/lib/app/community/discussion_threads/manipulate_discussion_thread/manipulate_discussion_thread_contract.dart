import 'package:client/app/community/utils.dart';

abstract class ManipulateDiscussionThreadView {
  void updateView();
  void showMessage(String message, {ToastType toastType = ToastType.neutral});
  void updateTextEditingController();
  void requestTextFocus();
}
